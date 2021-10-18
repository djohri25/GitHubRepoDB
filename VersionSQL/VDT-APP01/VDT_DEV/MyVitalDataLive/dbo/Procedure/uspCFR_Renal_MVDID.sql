/****** Object:  Procedure [dbo].[uspCFR_Renal_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Renal_MVDID] 
AS
/*
    CustID:  16
    RuleID:  205
 ProductID:  2
OwnerGroup:  162

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	Created by refactor of original to call uspCFR_Merge
Scott	2021-05-25	Refactor to CTE, add UniversalExclusion for hourly and no benefit.
Scott	2021-09-17	Add CCM Exclusions

EXEC uspCFR_Renal_MVDID  --(2512/1:32)(2512/1:34)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Renal_MVDID', @CustID = 16, @RuleID = 205, @ProductID = 2, @OwnerGroup= 162

EXEC uspCFR_MapRuleExclusion @pRuleID = '205', @pAction = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

--New Exclusion Code
	DROP TABLE IF EXISTS #ExcludedMVDID
	CREATE TABLE #ExcludedMVDID (MVDID varchar(30))

	INSERT INTO #ExcludedMVDID (MVDID)
	SELECT DISTINCT em.MVDID
	  FROM CFR_Rule_Exclusion re
	  JOIN HPWorkFlowRule wfr ON wfr.Rule_ID = re.RuleID
	  JOIN CFR_ExcludedMVDID em ON em.ExclusionID = re.ExclusionID
	  JOIN CFR_Exclusion e ON em.ExclusionID = e.ID
	 WHERE wfr.Body = OBJECT_NAME(@@PROCID)

	MERGE INTO #ExcludedMVDID AS tgt
	USING (SELECT MVDID
	         FROM FinalMember fm
			 JOIN ABCBS_GrpCcmEligMbr ccm ON fm.MemberID = ccm.MRB_ID
            WHERE CCM_GRP_ELIG_IND = 'N') src
		ON tgt.MVDID = src.MVDID
	  WHEN NOT MATCHED THEN INSERT (MVDID) VALUES (MVDID);

CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)

	;WITH Renal AS
		(
			SELECT DISTINCT h.MVDID, M.LastName, M.FirstName, MAX(H.StatementFromDate) as SvcDate
			  FROM MyVitalDataLive.dbo.FinalClaimsHeaderCode Dx
			  JOIN dbo.FinalClaimsHeader H ON H.MVDID = Dx.MVDID AND H.ClaimNumber = Dx.ClaimNumber
			  JOIN dbo.ComputedCareQueue M ON M.MVDID = H.MVDID
			  JOIN FinalMember FM ON FM.MVDID = H.MVDID
			 WHERE H.StatementFromDate >= DATEADD(month,-3,GetDate())
			   AND ISNULL(FM.COBCD,'U') IN ('S','N','U')
			   AND ISNULL(FM.CompanyKey,'0000') != '1338'
			   AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
			   AND M.RiskGroupId > 2
			   AND ((CodeType='PROC' AND CodeValue IN ('90945','90947','S9339','4055F','49421','49324','36830',
												   '36831','36832','36833','36870','36800','36810','36838',
												   '90935','90937','90940','90951','90993','90997','90987','90999')			
					)
					OR 
					(CodeType='DIAG' AND ICDVersion='0' AND CodeValue IN ('0389','25040','25041','25042','25043','40390',
											'40391','40493','5523','5831','5845','5848','5849','5851','5852','5853','5854',
											'5855','5856','5859','75312','7885','9961','99656','99668','99673','99674','99681',
											'I120','N186','N185','N184','N183','N182','N181','N189','E1121','E1122','E1129',
											'Q613','V4511','V4512','V560','V562','V568','T81502','T81512','T81522','T81532','T81592',
											'T824','T8241','T8242','T8243','T8249','T85611','T85621','T85631','T85691','T8571',
											'Z49','Z490','Z493','Z992')        
					 )       
				   )
           GROUP BY h.MVDID, M.LastName, M.FirstName
		)
		  SELECT DISTINCT r.MVDID 
			FROM Renal r
           WHERE NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = r.MVDID)

END