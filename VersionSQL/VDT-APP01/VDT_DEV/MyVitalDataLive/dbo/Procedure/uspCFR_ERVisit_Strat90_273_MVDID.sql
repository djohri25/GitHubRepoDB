/****** Object:  Procedure [dbo].[uspCFR_ERVisit_Strat90_273_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_ERVisit_Strat90_273_MVDID] 
AS
/*
	CustID:			16
	RuleID:			273
	ProductID:		2
	OwnerGroup:		168

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to use new merge process
Scott		2021-05-25	Add Universal Exclusion for hourly and no benefit

EXEC uspCFR_ERVisit_Strat90_273_MVDID (13\:00) (13\:00)

This procedure will call us Merge as:

EXEC uspCFR_Merge @MVDProcedureName 'uspCFR_ERVisit_Strat_273_MVDID', @CustID=16, @RuleID = 273, ProductID=2, @OwnerGroup = 168

*/

BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int
	DECLARE @OwnerGroup int = 168

CreateLocalTempTable:
	--the local temp table will persist between the calls of three stored procedures
	IF NOT EXISTS (SELECT 1 FROM dbo.CFR_Strat90_Tmp)
		BEGIN	
			select mvdid, count(distinct claimnumber) as cnt
			  into CFR_Strat90_Tmp
			  from FinalClaimsHeader
			  where IsNull(EmergencyIndicator,0) = 1
				and datediff(day,StatementFromDate, GetDate()) < 91
				and IsNull(AdjustmentCode,'O') != 'A'
			  group by MVDID
		END

CareFlowRule273:
	
	-- ER visit count between > 9
	set @RuleID = 273
	set @OwnerGroup = 168

	DROP TABLE IF EXISTS #ExcludedMVDID
	CREATE TABLE #ExcludedMVDID (MVDID varchar(30))

	INSERT INTO #ExcludedMVDID (MVDID)
	SELECT DISTINCT em.MVDID
	  FROM CFR_Rule_Exclusion re
	  JOIN HPWorkFlowRule wfr ON wfr.Rule_ID = re.RuleID
	  JOIN CFR_ExcludedMVDID em ON em.ExclusionID = re.ExclusionID
	  JOIN CFR_Exclusion e ON em.ExclusionID = e.ID
	 WHERE wfr.Body = OBJECT_NAME(@@PROCID)

	-- member is active (a) has no case manager (b) no personal harm (i) high prediction for top 10% hi ratio of Rx to Med
		 SELECT DISTINCT ER1.MVDID
		   FROM CFR_Strat90_Tmp ER1
		   JOIN ComputedCareQueue CCQ on CCQ.MVDID = ER1.MVDID
	  LEFT JOIN ComputedMemberAlert CA on CA.MVDID = CCQ.MVDID
	  LEFT JOIN FinalMember FM on FM.MVDID = CCQ.MVDID
		  WHERE CCQ.IsActive = 1 
		    AND ISNULL(FM.CompanyKey,'0000') != '1338'
		    AND ISNULL(CCQ.CaseOwner,'--') = '--'
		    AND ISNULL(CA.PersonalHarm,0) = 0
		    AND ISNULL(FM.COBCD,'U') in ('S','N','U')
		    AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
		    AND ER1.cnt > 9
			AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)


END