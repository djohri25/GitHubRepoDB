/****** Object:  Procedure [dbo].[uspCFR_Various_MA_Asthma_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Various_MA_Asthma_MVDID]
AS
/*

	This procedure is called by uspCFR_Various_MA_Master.  
	This procedure requires a base table (CFR_ComplexCareBase) that is populated by uspCFR_Various_MA_Master.

    CustID:  16
    RuleID:  266
 ProductID:  2
OwnerGroup:  171

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	Created by refactor of original to call uspCFR_Merge
Scott	2021-05-24	Refactor to CTE and add Universal Exclusion for no benifit, hourly.
Scott	2021-08-03  Add granular exclusion method
Scott	2021-10-06  Modify query to CFR_ComplexCareBase to use LOB='MA' only

exec uspCFR_Various_MA_Asthma_MVDID	 --(128/:03)(113/:05)

exec uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_MA_Asthma_MVDID', @CustID = 16, @RuleID = 266, @ProductID = 2, @OwnerGroup= 171

EXEC uspCFR_MapRuleExclusion @RuleID = '266', @Action = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM dbo.CFR_ComplexCareBase) 
		BEGIN
			RAISERROR ('Must be called from uspCFR_Various_MA_Master',16,1)
			GOTO ProcedureEnd	
		END

	DECLARE @RuleIDComplexCare int  = 266  -- Asthma
	DECLARE @OwnerGroupComplexCare int = 171
	DECLARE @Grp int					-- 1= CHF, 10=COPD, 7 = Hypertension, 12 = Diabetes, 19 = Cancer, 9 = Chronic Neurolical condition
	
ComplexCareAsthma:

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


		SELECT DISTINCT	b.MVDID
		  FROM CFR_ComplexCareBase b
		  JOIN FinalClaimsHeader h on h.MVDID = b.MVDID
		  JOIN FinalClaimsHeaderCode Dx on Dx.MVDID = h.MVDID and h.ClaimNumber = Dx.ClaimNumber
		 WHERE dx.CodeValue IN ('J4521','J4522','J4530','J4531','J4532','J4540','J4541','J4542','J4550','J4551',
								'J4552','J45901','J45902','J45909','J45991','J45998')
		   AND b.LOB = 'MA'
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = B.MVDID)

ProcedureEnd:

	RETURN

END