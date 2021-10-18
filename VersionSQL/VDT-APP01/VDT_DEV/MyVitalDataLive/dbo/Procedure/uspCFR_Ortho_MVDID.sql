/****** Object:  Procedure [dbo].[uspCFR_Ortho_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Ortho_MVDID]
AS
/*
    CustID:  16
    RuleID:  215
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Scott	2020-10-29	ALTERd by refactor of original to call uspCFR_Merge
Scott	2020-11-21	Updated with changes to original
Scott	2021-04-19	Refactor to CTE format and add Universal Exclusion of No-Benefit and Hourly workers.
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_Ortho_MVDID (121/:13)(121/:02)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Ortho_MVDID', @CustID = 16, @RuleID = 215, @ProductID = 2, @OwnerGroup= 168

EXEC uspCFR_MapRuleExclusion @RuleID = '215', @Action = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;
	DECLARE @RuleID int = 215

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

			SELECT DISTINCT CCQ.MVDID
			  FROM ComputedCareQueue (READUNCOMMITTED) CCQ
		 LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA on CA.MVDID = CCQ.MVDID
		 LEFT JOIN FinalMember (READUNCOMMITTED) FM on FM.MVDID = CCQ.MVDID
			--left join [VD-RPT02].[Datalogy].[ds].[tags_for_high_risk_members] CP on CP.PartyKey = FM.PartyKey /*Removed*/
		 LEFT JOIN [tags_for_high_risk_members] (READUNCOMMITTED) CP on CP.PartyKey = FM.PartyKey /*Added*/
			 WHERE CCQ.IsActive = 1 
			   AND ISNULL(FM.CompanyKey,'0000') != '1338'
			   AND ISNULL(CCQ.CaseOwner,'--') = '--'
			   AND ISNULL(CA.PersonalHarm,0) = 0
			   AND ISNULL(CP.Is_Ortho3_predicted,0) = 1
			   AND ISNULL(CP.Has_Obesity_History,0) = 1
			   AND CCQ.RiskGroupID >= 5			--there are few in this risk group...
		       AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)
	
END