/****** Object:  Procedure [dbo].[uspCFR_Various_MA_Master]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Various_MA_Master]
AS
/*
	This procedure will create and populate CFR_ComplexCareBase for use by six other procedures to be called by uspCFR_Merge.

		uspCFR_Various_MA_CAD_MVDID
		uspCFR_Various_MA_COPD_MVDID
		uspCFR_Various_MA_Asthma_MVDID
		uspCFR_Various_MA_Diabetes_MVDID
		uspCFR_Various_MA_CHF_MVDID
		uspCFR_Various_MA_ReAdmit_MVDID

Changes
WHO		WHEN		WHAT
Scott	2020-11-20	Created to call uspCFR_Merge with other procedures
Mike G	2021-06-03	Relax Pharmacy to just 1 and limit to Risk score in (0,5,6,7,8,9,10) per TFS 5491
Scott	2021-08-19	Add new exclusion code and optimize base query. Add MVDID Index.
                    All of the rules are mapped to the "Admin" exclusion family so use the mapping for
					RuleID = 262 for this one. 
Scott	2021-09-07	Add query hints for Computed Care Queue
Scott	2021-09-20	Enable PFFS (Final Eligibility Plan Identifier = H4213).
Scott	2021-10-06	Add five new rules for non MA patients.  TFS 6157.

EXEC uspCFR_Various_MA_Master

EXEC uspCFR_MapRuleExclusion @RuleID = 262, @Action = 'DISPLAY'

--new non MA rules
INSERT INTO HPWorkflowRule (Cust_ID, Name, Description, Body, Action_ID, Action_Days, Active, CreatedDate, Query, AdminUseOnly, [Group])
VALUES (16,'Complex Care CAD','Members with high rx count and CAD (Non MA)','uspCFR_Various_CAD_MVDID',-1,0,1,'2021-10-06','SP',1,'MA'),
(16,'Complex Care COPD','Members with high Rx count and COPD (Non MA)','uspCFR_Various_COPD_MVDID',-1,0,1,'2021-10-06','SP',1,'MA'),
(16,'Complex Care CHF','Members with high rx count and CHF (Non MA)','uspCFR_Various_CHF_MVDID',-1,0,1,'2021-10-06','SP',1,'MA'),
(16,'Complex Care Diabetes','Members with high rx count and Diabetes (Non MA)','uspCFR_Various_Diabetes_MVDID',-1,0,1,'2021-10-06','SP',1,'MA'),
(16,'Complex Care Asthma','Members with high rx count and Asthma (Non MA)','uspCFR_Various_Asthma_MVDID',-1,0,1,'2021-10-06','SP',1,'MA')

SELECT * FROM HPWorkflowRule
*/
BEGIN
SET NOCOUNT ON;

DECLARE @RuleIDComplexCare int = 999
DECLARE @OwnerGroupComplexCare int = 171
DECLARE @MaxRolling12 varchar(6)
DECLARE @Top20Pct decimal
DECLARE @Top20PctMA decimal

	--add the new column to CFR_ComplexCareBase if it has not been edded.
	IF NOT EXISTS(SELECT * FROM syscolumns WHERE id = OBJECT_ID('CFR_ComplexCareBase') AND name = 'LOB')
        BEGIN
			ALTER TABLE CFR_ComplexCareBase ADD LOB varchar(2)
		END

	DROP TABLE IF EXISTS #RX
	SELECT MVDID, LOB, AVG(RxCnt) AS AvgRxCnt, AVG(PhmCnt) AS AvgPhmCnt 
	  INTO #RX
	  FROM (SELECT MVDID, LOB, DATEPART(month,ServiceDate) SvcMo, COUNT(DISTINCT ndccode) AS RxCnt, COUNT(DISTINCT PharmacyName) AS PhmCnt
		      FROM FinalRx READUNCOMMITTED
		     WHERE DATEDIFF(day,ServiceDate,GETDATE()) < 365 
			   --AND LOB='MA'
		     GROUP BY MVDID, LOB, DATEPART(month,ServiceDate)) a
	 GROUP BY MVDID, LOB
	HAVING AVG(RxCnt) >= 6 -- and avg(PhmCnt) >= 2

	-- Capture most recent rolling 12 computed and find the cutoff for top 20% for cost
	SELECT @MaxRolling12 = (SELECT TOP 1 MonthID FROM ComputedMemberTotalPaidClaimsRollling12 ORDER BY ID DESC)

	SELECT @Top20PctMA = MIN([TotalPaidAmount]) 
	  FROM (SELECT TOP 20 PERCENT [TotalPaidAmount]
	          FROM ComputedMemberTotalPaidClaimsRollling12
	         WHERE MonthID=@MaxRolling12 
			   AND LOB ='MA'
	         ORDER BY [TotalPaidAmount] DESC) a

	SELECT @Top20Pct = MIN([TotalPaidAmount]) 
	  FROM (SELECT TOP 20 PERCENT [TotalPaidAmount]
	          FROM ComputedMemberTotalPaidClaimsRollling12
	         WHERE MonthID=@MaxRolling12 
			   AND LOB !='MA'
	         ORDER BY [TotalPaidAmount] DESC) a

	    --Granular Exclusion Code
		DROP TABLE IF EXISTS #ExcludedMVDID
		CREATE TABLE #ExcludedMVDID (MVDID varchar(30))

		INSERT INTO #ExcludedMVDID (MVDID)
		SELECT DISTINCT em.MVDID
		  FROM CFR_Rule_Exclusion re
		  JOIN HPWorkFlowRule wfr ON wfr.Rule_ID = re.RuleID
		  JOIN CFR_ExcludedMVDID em ON em.ExclusionID = re.ExclusionID
		  JOIN CFR_Exclusion e ON em.ExclusionID = e.ID
		 WHERE wfr.Body = 'uspCFR_Various_MA_CAD_MVDID'		-- the Admin exclusion is mapped to this rule and all the others
		                                                    -- called by this proc.

	  DROP INDEX IF EXISTS IX_CFR_ComplexCareBaseMVDID ON CFR_ComplexCareBase
	  TRUNCATE TABLE CFR_ComplexCareBase
		--LOB = MA
	    INSERT INTO CFR_ComplexCareBase (MVDID, LOB)
		SELECT DISTINCT rx.MVDID, CCQ.LOB
		  FROM #RX rx
		  JOIN ComputedCareQueue CCQ (READUNCOMMITTED) ON CCQ.MVDID = RX.MVDID
		  JOIN FinalMember FM (READUNCOMMITTED) ON FM.MVDID = CCQ.MVDID
		  JOIN FinalEligibility FE (READUNCOMMITTED) ON FE.MVDID = FM.MVDID AND FE.MemberEffectiveDate <= GETDATE() 
		   AND ISNULL(FE.MemberTerminationDate,'9999-12-31') >= GetDate() 
		   AND ISNULL(FE.FakeSpanInd,'N') = 'N' 
		   AND ISNULL(FE.SpanVoidInd,'N') = 'N'
	 LEFT JOIN ComputedMemberAlert CA (READUNCOMMITTED) ON CA.MVDID = CCQ.MVDID
	 LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 CP (READUNCOMMITTED) ON CP.MVDID = CCQ.MVDID
	     WHERE CCQ.IsActive = 1 
		   AND rx.LOB='MA'
	       AND CCQ.LOB='MA'
	       AND ISNULL(CCQ.RiskGroupID,0) IN (0,5,6,7,8,9,10)
	       AND ISNULL(FM.CompanyKey,'0000') != '1338'
	       --AND FE.PlanIdentifier != 'H4213'		--TFS 6095
	       AND ISNULL(CCQ.CaseOwner,'--') = '--'
	       AND ISNULL(CA.PersonalHarm,0) = 0
	       AND CP.MonthID = @MaxRolling12
	       AND CP.TotalPaidAmount >= @Top20PctMA
	       AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

		--check to see if the exclusions are the same for MA and non MA members
		--LOB = NonMA
	    INSERT INTO CFR_ComplexCareBase (MVDID, LOB)
		SELECT DISTINCT rx.MVDID, CCQ.LOB
		  FROM #RX rx
		  JOIN ComputedCareQueue CCQ (READUNCOMMITTED) ON CCQ.MVDID = RX.MVDID
		  JOIN FinalMember FM (READUNCOMMITTED) ON FM.MVDID = CCQ.MVDID
		  JOIN FinalEligibility FE (READUNCOMMITTED) ON FE.MVDID = FM.MVDID AND FE.MemberEffectiveDate <= GETDATE() 
		   AND ISNULL(FE.MemberTerminationDate,'9999-12-31') >= GetDate() 
		   AND ISNULL(FE.FakeSpanInd,'N') = 'N' 
		   AND ISNULL(FE.SpanVoidInd,'N') = 'N'
	 LEFT JOIN ComputedMemberAlert CA (READUNCOMMITTED) ON CA.MVDID = CCQ.MVDID
	 LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 CP (READUNCOMMITTED) ON CP.MVDID = CCQ.MVDID
	     WHERE rx.LOB != 'MA'
		   AND CCQ.IsActive = 1 
	       AND ISNULL(CCQ.RiskGroupID,0) IN (0,5,6,7,8,9,10)
	       AND ISNULL(FM.CompanyKey,'0000') != '1338'
	       --AND FE.PlanIdentifier != 'H4213'		--TFS 6095
	       AND ISNULL(CCQ.CaseOwner,'--') = '--'
	       AND ISNULL(CA.PersonalHarm,0) = 0
	       AND CP.MonthID = @MaxRolling12
	       AND CP.TotalPaidAmount >= @Top20Pct
	       AND CCQ.LOB != 'MA'
	       AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

ComplexCareCAD:

	-- CAD
	SET  @RuleIDComplexCare = 262

	EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_MA_CAD_MVDID', @CustID = 16, @RuleID =  @RuleIDComplexCare, @ProductID = 2, @OwnerGroup= 171
	
	SET  @RuleIDComplexCare = 301

	EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_CAD_MVDID', @CustID = 16, @RuleID =  @RuleIDComplexCare, @ProductID = 2, @OwnerGroup= 168
	
ComplexCareCOPD:

	 --COPD
	SET  @RuleIDComplexCare = 263

	EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_MA_COPD_MVDID', @CustID = 16, @RuleID =  @RuleIDComplexCare, @ProductID = 2, @OwnerGroup= 171

	SET  @RuleIDComplexCare = 302

	EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_COPD_MVDID', @CustID = 16, @RuleID =  @RuleIDComplexCare, @ProductID = 2, @OwnerGroup= 168

ComplexCareCHF:

	 --CHF
	SET  @RuleIDComplexCare = 264

	EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_MA_CHF_MVDID', @CustID = 16, @RuleID =  @RuleIDComplexCare, @ProductID = 2, @OwnerGroup= 171

	SET  @RuleIDComplexCare = 303

	EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_CHF_MVDID', @CustID = 16, @RuleID =  @RuleIDComplexCare, @ProductID = 2, @OwnerGroup= 168

ComplexCareDiabetes:

	 --Diabetes
	SET  @RuleIDComplexCare = 265

	EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_MA_Diabetes_MVDID', @CustID = 16, @RuleID =  @RuleIDComplexCare, @ProductID = 2, @OwnerGroup= 171

	SET  @RuleIDComplexCare = 304

	EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_Diabetes_MVDID', @CustID = 16, @RuleID =  @RuleIDComplexCare, @ProductID = 2, @OwnerGroup= 168

ComplexCareAsthma:

	-- Asthma
	SET  @RuleIDComplexCare = 266

	EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_MA_Asthma_MVDID', @CustID = 16, @RuleID =  @RuleIDComplexCare, @ProductID = 2, @OwnerGroup= 171

	SET  @RuleIDComplexCare = 305

	EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_Asthma_MVDID', @CustID = 16, @RuleID =  @RuleIDComplexCare, @ProductID = 2, @OwnerGroup= 168
	
ComplexCareReAdmit:

	 -- Single Re-admission to Acute, same DRG
	SET  @RuleIDComplexCare = 267

	EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_MA_ReAdmit_MVDID', @CustID = 16, @RuleID =  @RuleIDComplexCare, @ProductID = 2, @OwnerGroup= 171

END