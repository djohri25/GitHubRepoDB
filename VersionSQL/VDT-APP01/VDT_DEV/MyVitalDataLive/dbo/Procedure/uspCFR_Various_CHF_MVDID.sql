/****** Object:  Procedure [dbo].[uspCFR_Various_CHF_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Various_CHF_MVDID]
AS
/*

	This procedure is called by uspCFR_Various_MA_Master.  
	This procedure requires a base table (CFR_ComplexCareBase) that is populated by uspCFR_Various_MA_Master.

    CustID:  16
    RuleID:  303		--may change in production
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Scott	2021-10-06	Created by refactor of uspCFR_Various_MA_CHF_MVDID
Scott	2021-10-07  Added Chronic Conditions Exxclusion Option

EXEC uspCFR_Various_CHF_MVDID	 --(5/:02)(5/:19)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_CHF_MVDID', @CustID = 16, @RuleID = 303, @ProductID = 2, @OwnerGroup= 168

EXEC uspCFR_MapRuleExclusion @RuleID = '303', @Action = 'ADD', @ExclusionID = '10,11,20,21'

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
	DECLARE @Grp int					-- 1= CHF, 10=COPD, 7 = Hypertension, 12 = Diabetes, 19 = Cancer, 9 = Chronic Neurolical condition
	 
		SET @Grp = 1 --CHF
		SET @RuleIDComplexCare = 264

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

    --Members must be in CCM_6 for this group, so exclude all others
	MERGE INTO #ExcludedMVDID AS tgt
	USING (SELECT MVDID
	         FROM FinalMember fm
			 JOIN ABCBS_GrpCcmEligMbr ccm ON fm.MemberID = ccm.MRB_ID
            WHERE (CCM_GRP_ELIG_IND = 'N'				
			   OR ISNULL(CCM_TYPE,'') NOT IN ('CCM_6'))
			) src
		ON tgt.MVDID = src.MVDID
	  WHEN NOT MATCHED THEN INSERT (MVDID) VALUES (MVDID);

	 CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)

	
ComplexCareCHF:

		SELECT DISTINCT b.MVDID
		  FROM CFR_ComplexCareBase b
		  JOIN ElixMemberRisk ex on ex.mvdid = b.mvdid
		 WHERE b.LOB != 'MA'
		   AND ex.groupid=@Grp
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = b.MVDID)

ProcedureEnd:

	RETURN

END