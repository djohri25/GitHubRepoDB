/****** Object:  Procedure [dbo].[uspCFR_Various_MA_ReAdmit_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Various_MA_ReAdmit_MVDID]
AS
/*

	This procedure is called by uspCFR_Various_MA_Master.  
	This procedure requires a base table (CFR_ComplexCareBase) that is populated by uspCFR_Various_MA_Master.

    CustID:  16
    RuleID:  267
 ProductID:  2
OwnerGroup:  171

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	Created by refactor of original to call uspCFR_Merge
Scott	2021-05-24	Refactor to CTE and add Universal Exclusion for no benifit, hourly.
Scott	2021-08-03	Add granular exclusion code
Scott	2021-10-06  modify to use only MA membes from CFR_ComplexCareBase.

EXEC uspCFR_Various_MA_ReAdmit_MVDID --(15/:02)	 

exec uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_MA_ReAdmit_MVDID', @CustID = 16, @RuleID = 267, @ProductID = 2, @OwnerGroup= 171

EXEC uspCFR_MapRuleExclusion @RuleID = '267'

*/
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM dbo.CFR_ComplexCareBase) 
		BEGIN
			RAISERROR ('Must be called from uspCFR_Various_MA_Master',16,1)
			GOTO ProcedureEnd	
		END

	DECLARE @RuleIDComplexCare int 
	DECLARE @OwnerGroupComplexCare int 
	DECLARE @Grp int		-- 1= CHF, 10=COPD, 7 = Hypertension, 12 = Diabetes, 19 = Cancer, 9 = Chronic Neurolical condition
	
ComplexCareReAdmit:

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
	
	 -- Single Re-admission to Acute, same DRG
	set  @RuleIDComplexCare = 267

	;WITH Admissions AS
		(
			SELECT MVDID,
			       DRG,
				   COUNT(DISTINCT AdmissionDate) AS Cnt 
			  FROM FinalClaimsHeader
			 WHERE LOB='MA'
			   AND DATEDIFF(day,AdmissionDate,GETDATE()) <= 365
			   AND (BillType = '111' OR BillType = '112')
			   AND ISNULL(DRG,-1) > -1
			 GROUP BY MVDID,DRG
			HAVING COUNT(DISTINCT AdmissionDate) > 1
		)
		SELECT DISTINCT	CCB.MVDID
		  FROM CFR_ComplexCareBase ccb
		  JOIN Admissions a ON CCB.MVDID = a.MVDID
		 WHERE ccb.LOB = 'MA'
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = ccb.MVDID)

ProcedureEnd:

	RETURN

END