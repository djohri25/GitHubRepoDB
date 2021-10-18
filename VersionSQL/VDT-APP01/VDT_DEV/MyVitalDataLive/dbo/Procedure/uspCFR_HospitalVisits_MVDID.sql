/****** Object:  Procedure [dbo].[uspCFR_HospitalVisits_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HospitalVisits_MVDID] 
AS
/*
    CustID:  16
    RuleID:  207
 ProductID:  2
OwnerGroup:  159

Changes
WHO		WHEN		WHAT
Scott	2020-11-20	ALTERd by refactor of original to call uspCFR_Merge
Scott	2020-11-21  Updated with changes from original
Scott	2021-05-25  Add Universal Exclustions for hourly and no benefit
Scott	2021-08-03	Add new exclusion code.  Waiting for response on H.ClaimStatus < 20 error.
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_HospitalVisits_MVDID   --(0/:55)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HospitalVisits_MVDID', @CustID = 16, @RuleID = 207, @ProductID = 2, @OwnerGroup= 159

EXEC uspCFR_MapRuleExclusion @RuleID = '207', @Action = 'DISPLAY'

*/

BEGIN
	SET NOCOUNT ON;

DECLARE @R12Month varchar(10)
DECLARE @RuleID int = 207

SELECT @R12Month=MAX(monthid) FROM ComputedMemberTotalPaidClaimsRollling12
--PRINT @R12Month

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

	CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)

			SELECT DISTINCT H.MVDID
			  FROM FinalClaimsHeader (READUNCOMMITTED) H
			  JOIN FinalClaimsHeaderCode (READUNCOMMITTED) HC on HC.ClaimNumber = H.ClaimNumber
			  JOIN ComputedMemberTotalPaidClaimsRollling12 (READUNCOMMITTED) R12 on R12.MVDID = H.MVDID
			  JOIN FinalEligibilityETL (READUNCOMMITTED) E on E.MVDID = H.MVDID
			  JOIN FinalMember (READUNCOMMITTED) FM on FM.MVDID = H.MVDID
			 WHERE AdmissionDate >= DATEADD(YEAR,-1,CAST(@R12Month+'01' AS date))
			   AND ISNULL(FM.CompanyKey,'0000') != '1338'
			   AND SUBSTRING(ISNULL(BillType,'000'),1,1) = '1' 
			   AND SUBSTRING(ISNULL(BillType,'000'),2,1) in ('1','2','5','6','8')
			   AND PlaceOfService NOT IN ('11','12','22','23','81''24','41','62','65')
			   AND DATEDIFF(dd,ISNULL(DischargeDate,AdmissionDate),AdmissionDate) >= 7
			   AND HighDollarClaim > 0 
			   AND MonthID = @R12Month
  			   AND (ISNUMERIC(H.ClaimStatus) = 1 AND CAST(H.ClaimStatus AS int) < 20) -- only approved and manual override claims
			   AND HC.CodeType = 'DIAG' AND ISNULL(HC.ICDVersion,'5')='0'   -- just ICD10
			   AND HC.CodeValue IN (SELECT ICD10 FROM [dbo].[ABCBS_RobustDx])
			   AND E.MemberTerminationDate >= @R12Month +'01'
			   AND E.RiskGroupId > 2
			   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = H.MVDID)
			 			 
END