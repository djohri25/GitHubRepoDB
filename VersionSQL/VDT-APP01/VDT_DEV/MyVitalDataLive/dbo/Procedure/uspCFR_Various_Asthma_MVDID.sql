/****** Object:  Procedure [dbo].[uspCFR_Various_Asthma_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Various_Asthma_MVDID]
AS
/*

	This procedure is called by uspCFR_Various_MA_Master.  
	This procedure requires a base table (CFR_ComplexCareBase) that is populated by uspCFR_Various_MA_Master.

    CustID:  16
    RuleID:  305 - may change in production
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Scott	2021-10-06	Created by refactor of uspCFR_Various_MA_Asthma_MVDID
Scott	2021-10-07	Add Chronic Conditions Exclusion Option

exec uspCFR_Various_Asthma_MVDID	 --(2/:01)(2/:19)

exec uspCFR_Merge @MVDProcedureName = 'uspCFR_Various_Asthma_MVDID', @CustID = 16, @RuleID = 305, @ProductID = 2, @OwnerGroup= 168

EXEC uspCFR_MapRuleExclusion @RuleID = '305', @Action = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;



	IF NOT EXISTS (SELECT 1 FROM dbo.CFR_ComplexCareBase) 
		BEGIN
			RAISERROR ('Must be called from uspCFR_Various_MA_Master',16,1)
			GOTO ProcedureEnd	
		END

	-- Asthma, Non MA

	DECLARE @RuleIDComplexCare int = 305
	DECLARE @OwnerGroupComplexCare int 
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

    --Members must be in CCM_6 for this group, so exclude all others
	MERGE INTO #ExcludedMVDID AS tgt
	USING (SELECT MVDID
	         FROM FinalMember (READUNCOMMITTED) fm
			 JOIN ABCBS_GrpCcmEligMbr ccm ON fm.MemberID = ccm.MRB_ID
            WHERE (CCM_GRP_ELIG_IND = 'N'				
			   OR ISNULL(CCM_TYPE,'') NOT IN ('CCM_6'))
			) src
		ON tgt.MVDID = src.MVDID
	  WHEN NOT MATCHED THEN INSERT (MVDID) VALUES (MVDID);

	 CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)

		SELECT DISTINCT	B.MVDID
		  FROM CFR_ComplexCareBase b
		  JOIN FinalClaimsHeader (READUNCOMMITTED) h on h.MVDID = b.MVDID
		  JOIN FinalClaimsHeaderCode (READUNCOMMITTED) dx on dx.MVDID = h.MVDID and h.ClaimNumber = dx.ClaimNumber
		 WHERE b.LOB !='MA'
		   AND dx.CodeValue IN ('J4521','J4522','J4530','J4531','J4532','J4540','J4541','J4542','J4550','J4551',
								'J4552','J45901','J45902','J45909','J45991','J45998')
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = B.MVDID)

ProcedureEnd:

	RETURN

END