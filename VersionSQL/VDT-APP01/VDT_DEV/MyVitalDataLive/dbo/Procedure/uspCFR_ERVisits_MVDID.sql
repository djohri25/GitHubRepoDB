/****** Object:  Procedure [dbo].[uspCFR_ERVisits_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_ERVisits_MVDID] 
AS
/*
    CustID:  16
    RuleID:  200
 ProductID:  2
OwnerGroup:  159

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	ALTERd by refactor of original to call uspCFR_Merge
Scott	2021-05-25	Added Universal Exclusion for hourly and no benefit.
Scott	2021-07-30  Add new exclusion method
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_ERVisits_MVDID  (0/:01) (0/:04)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_ERVisits_MVDID', @CustID = 16, @RuleID = 200, @ProductID = 2, @OwnerGroup= 159

EXEC uspCFR_MapRuleExclusion @pRuleID = 200, @pAction = 'ADD', @pFamily = 'Universal'

*/
BEGIN
	SET NOCOUNT ON;

DECLARE @r12date VARCHAR(6)

SELECT @r12date = MAX(monthid) FROM ComputedMemberTotalPaidClaimsRollling12


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

	;WITH ERVisits AS
		(
		   SELECT FinalMember.MVDID, COUNT(visitdate) as cnt
			 FROM FinalMember
			 LEFT OUTER JOIN ComputedMemberEncounterHistory (READUNCOMMITTED) EC on EC.MVDID = FinalMember.MVDID   
			 LEFT OUTER JOIN ComputedCareQueue  (READUNCOMMITTED) ON ComputedCareQueue.MVDID = FinalMember.MVDID
			 LEFT OUTER JOIN ComputedMemberTotalPaidClaimsRollling12 (READUNCOMMITTED) r12 on r12.MVDID = FinalMember.MVDID
			WHERE ComputedCareQueue.Isactive = 1 
			  AND FinalMember.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
			  AND ISNULL(FinalMember.COBCD,'U') in ('S','N','U')
			  AND ISNULL(FinalMember.CompanyKey,'0000') != '1338'
			  AND EC.VisitType = 'ER' 
			  AND EC.VisitDate > DATEADD(YEAR,-1,GetDate()) 
			  AND FinalMember.CustID = 16 
			  AND r12.MonthID=@r12date 
			  AND r12.HighDollarClaim=1
			GROUP BY FinalMember.MVDID
		   HAVING COUNT(visitdate) > 3
		)
		SELECT DISTINCT ER.MVDID
		  FROM ErVisits ER
		 WHERE NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = ER.MVDID)

END