/****** Object:  Procedure [dbo].[uspCFR_ERVisit_Strat268_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_ERVisit_Strat268_MVDID] 
AS
/*
	CustID:			16
	RuleID:			268
	ProductID:		2
	OwnerGroup:		168

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to use new merge process
Scott		2021-05-13	Add Universal Exclusion from no benefit and hourly
Scott		2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_ERVisit_Strat268_MVDID --(147,582/:12) (147,582/:10)

This procedure may be called using the Merge procedure:

EXEC uspCFR_Merge @MVDProcedureName 'uspCFR_ERVisit_Strat268_MVDID', @CustID=16, @RuleID = 268, ProductID=2,@OwnerGroup = 168

EXEC uspCFR_MapRuleExclusion @RuleID = '268', @Action = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @RuleID int
	DECLARE @OwnerGroup int
	DECLARE @ProcName varchar(255) =  OBJECT_NAME(@@PROCID)
	PRINT @ProcName 

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

CareFlowRule268:
	-- ER visit count between 1 and 4
	SET @RuleID = 268
	SET @OwnerGroup = 168

--Granular Exclusion Code
	DROP TABLE IF EXISTS #ExcludedMVDID
	CREATE TABLE #ExcludedMVDID (MVDID varchar(30))

	INSERT INTO #ExcludedMVDID (MVDID)
	SELECT DISTINCT em.MVDID
	  FROM CFR_Rule_Exclusion re
	  JOIN HPWorkFlowRule wfr ON wfr.Rule_ID = re.RuleID
	  JOIN CFR_ExcludedMVDID em ON em.ExclusionID = re.ExclusionID
	  JOIN CFR_Exclusion e ON em.ExclusionID = e.ID
	 WHERE wfr.Body = @ProcName
	 
CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)

      -- member is active (a) has no case manager (b) no personal harm (i) high prediction for top 10%  hi ratio of Rx to Med
		 SELECT DISTINCT er1.MVDID
		   FROM CFR_Strat_Tmp er1
		   JOIN ComputedCareQueue (READUNCOMMITTED) CCQ on CCQ.MVDID = ER1.MVDID
	  LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA on CA.MVDID = CCQ.MVDID
	  LEFT JOIN FinalMember (READUNCOMMITTED) FM on FM.MVDID = CCQ.MVDID
		  WHERE CCQ.IsActive = 1 
		    AND ISNULL(FM.CompanyKey,'0000') != '1338'
		    AND ISNULL(CCQ.CaseOwner,'--') = '--'
		    AND ISNULL(CA.PersonalHarm,0) = 0
		    AND ER1.cnt BETWEEN 1 AND 4
		    AND ISNULL(FM.COBCD,'U') in ('S','N','U')
		    AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
			AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = er1.MVDID)
			
END