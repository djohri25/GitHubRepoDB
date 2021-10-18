/****** Object:  Procedure [dbo].[uspCFR_Cancer_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Cancer_MVDID] 
AS
/*
    CustID:  16
    RuleID:  209
 ProductID:  2
OwnerGroup:  162

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	Created by refactor of original to call uspCFR_Merge
Scott	2021-02-09	Added dbo.LookupCodeCondition to store over 600 codes for procs and diags.
Scott	2021-04-14	Add company exclusions
Scott	2021-05-25	Add Universal Exclusions for hourly and no benefit

EXEC uspCFR_Cancer_MVDID --(7218/2:00)(7218/1:46)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Cancer_MVDID', @CustID = 16, @RuleID = 209, @ProductID = 2, @OwnerGroup= 162

SELECT * FROM LookupCodeTypeCondition

EXEC uspCFR_MapRuleExclusion @pRuleID = '209', @pAction = 'DISPLAY'

*/
BEGIN
SET NOCOUNT ON;

DECLARE @R12Date varchar(10)

SELECT @R12Date=MAX(monthid) FROM ComputedMemberTotalPaidClaimsRollling12

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


		   SELECT DISTINCT H.MVDID 
			 FROM FinalMember FM 
			 JOIN FinalClaimsHeader H ON FM.MVDID = H.MVDID
			 JOIN FinalClaimsHeaderCode HC ON H.ClaimNumber = HC.ClaimNumber
			 JOIN LookupCodeTypeCondition l		--The Proc Codes and Diag Codes are here.
			   ON l.CodeType = HC.CodeType
			  AND l.Code = HC.CodeValue
			  AND ISNULL(l.ICDVersion,'0') = HC.ICDVersion 
			  AND l.Cancer = 1
			WHERE FM.GrpInitvCd != 'GRD'									-- exclude members associated to Grand Rounds
			  AND ISNULL(FM.CompanyKey,'0000') != '1338'
			  AND ISNULL(FM.COBCD,'U') in ('S','N','U')
			  AND H.StatementFromDate >= DATEADD(MONTH,-2,@R12Date+'01')	-- Reported in last 60 days
			  AND H.PaidDate > = DATEADD(MONTH,-1,@R12Date+'01')			-- Paid in the last 30 days
			  AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = H.MVDID)

END