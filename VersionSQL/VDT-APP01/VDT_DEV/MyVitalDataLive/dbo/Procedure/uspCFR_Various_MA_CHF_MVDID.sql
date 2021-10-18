/****** Object:  Procedure [dbo].[uspCFR_Various_MA_CHF_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Various_MA_CHF_MVDID]
AS
/*

	This procedure is called by uspCFR_Various_MA_Master.  
	This procedure requires a base table (CFR_ComplexCareBase) that is populated by uspCFR_Various_MA_Master.

    CustID:  16
    RuleID:  264
 ProductID:  2
OwnerGroup:  171

Changes
WHO		WHEN		WHAT
Scott	2020-11-20	Created by refactor of original to call uspCFR_Merge, called by uspCFR_Various_MA_Master
Scott	2021-05-24	Refactor to CTE and add Universal Exclusion for no benifit, hourly.
Scott	2021-08-03	Add granular exclusion code
Scott	2021-10-06  Modify query to CFR_ComplexCareBase to use LOB='MA' only

EXEC uspCFR_Various_MA_CHF_MVDID	 --(417/:02)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_MA_CHF_MVDID', @CustID = 16, @RuleID = 264, @ProductID = 2, @OwnerGroup= 171

EXEC uspCFR_MapRuleExclusion @RuleID = '264', @Action = 'ADD', @ExclusionID = '20,21'

*/
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM dbo.CFR_ComplexCareBase) 
		BEGIN
			RAISERROR ('Must be called from uspCFR_Various_MA_Master',16,1)
			GOTO ProcedureEnd	
		END

	DECLARE @RuleIDComplexCare int = 264
	DECLARE @OwnerGroupComplexCare int = 171
	DECLARE @Grp int = 1			-- 1= CHF, 10=COPD, 7 = Hypertension, 12 = Diabetes, 19 = Cancer, 9 = Chronic Neurolical condition

--Granular Exclusion Code
	DROP TABLE IF EXISTS #ExcludedMVDID
	CREATE TABLE #ExcludedMVDID (MVDID varchar(30))

	INSERT INTO #ExcludedMVDID (MVDID)
	SELECT DISTINCT em.MVDID
	  FROM CFR_Rule_Exclusion re
	  JOIN HPWorkFlowRule wfr ON wfr.Rule_ID = re.RuleID
	  JOIN CFR_ExcludedMVDID em ON em.ExclusionID = re.ExclusionID
	  JOIN CFR_Exclusion e ON em.ExclusionID = e.ID
	 WHERE wfr.Body = OBJECT_NAME(@@PROCID)
	
ComplexCareCHF:

		SELECT DISTINCT b.MVDID
		  FROM CFR_ComplexCareBase b
		  JOIN ElixMemberRisk ex on ex.mvdid = b.mvdid
		 WHERE b.LOB = 'MA'
		   AND ex.groupid=@Grp
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = b.MVDID)

ProcedureEnd:

	RETURN

END