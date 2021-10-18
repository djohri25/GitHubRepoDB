/****** Object:  Procedure [dbo].[uspCFR_ERVisit_Strat270_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_ERVisit_Strat270_MVDID] 
AS
/*
	CustID:			16
	RuleID:			270
	ProductID:		2
	OwnerGroup:		170

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to use new merge process
Scott		2021-05-31	Add Universal Exclusion for hourly and no benefit.
Scott		2021-07-29	Add new exclusion method
Scott		2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_ERVisit_Strat270_MVDID --(272/:0) (272/:0)

This procedure may be called as

EXEC uspCFR_Merge @MVDProcedureName 'uspCFR_ERVisit_Strat270_MVDID', @CustID=16, @RuleID = 270, ProductID=2,@OwnerGroup = 170

EXEC uspCFR_MapRuleExclusion @RuleID = '270', @Action = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;
	-- ER visit count between > 9
	DECLARE @RuleID int = 270
	DECLARE @OwnerGroup int = 170

IF ISNULL(OBJECT_ID('dbo.CFR_Strat_Tmp'),0) = 0
	BEGIN 
		 --This local temp table is expensive and should have been CREATEd by uspCFR_ERVisit_Strat_Master
		 CREATE TABLE dbo.CFR_Strat_Tmp (MVDID varchar(30), Cnt int)

         INSERT INTO dbo.CFR_Strat_Tmp (MVDID, Cnt)
		 SELECT MVDID, COUNT(DISTINCT claimnumber) AS cnt
		   FROM FinalClaimsHeader
		  WHERE ISNULL(EmergencyIndicator,0) = 1
			AND DATEDIFF(day,StatementFromDate, GETDATE()) < 365
			AND ISNULL(AdjustmentCode,'O') != 'A'
		  GROUP BY MVDID
	END

CareFlowRule270:
		
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

			 SELECT DISTINCT ER1.MVDID
			   FROM CFR_Strat_Tmp ER1
			   JOIN ComputedCareQueue (READUNCOMMITTED) CCQ ON CCQ.MVDID = ER1.MVDID
		  LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA ON CA.MVDID = CCQ.MVDID
		  LEFT JOIN FinalMember (READUNCOMMITTED) FM ON FM.MVDID = CCQ.MVDID
			  WHERE CCQ.IsActive = 1 
			    AND ISNULL(FM.CompanyKey,'0000') != '1338'
			    AND ISNULL(CCQ.CaseOwner,'--') = '--'
			    AND ISNULL(CA.PersonalHarm,0) = 0
			    AND ER1.cnt > 9
			    AND ISNULL(FM.COBCD,'U') IN ('S','N','U')
			    AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
				AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

END