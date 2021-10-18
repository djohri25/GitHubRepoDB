/****** Object:  Procedure [dbo].[uspCFR_ERVisit_Strat90_272_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_ERVisit_Strat90_272_MVDID] 
AS
/*
	CustID:			16
	RuleID:			272
	ProductID:		2
	OwnerGroup:		168

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to use new merge process
Scott		2021-05-13	Add Universal Exclusion for hourly or no benefit
Scott		2021-07-29	Add new exclusion method
Scott		2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_ERVisit_Strat90_272_MVDID (163\:01) (163\:03)

This procedure will call the following three careflow rules

EXEC uspCFR_Merge @MVDProcedureName 'uspCFR_ERVisit_272_Strat_MVDID', @CustID=16, @RuleID = 272, ProductID=2,@OwnerGroup = 168

EXEC uspCFR_MapRuleExclusion @RuleID = '272', @Action = 'DISPLAY'


*/

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @RuleID int
	DECLARE @OwnerGroup int = 168

CREATELocalTempTable:
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

CareFlowRule272:	
	-- ER visit count between 5 and 9
	set @RuleID = 272
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

CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)

		 -- member is active (a) has no case manager (b) no personal harm (i) high prediction for top 10% hi ratio of Rx to Med
			 SELECT DISTINCT ER1.MVDID
			   FROM CFR_Strat90_Tmp ER1
			   JOIN ComputedCareQueue (READUNCOMMITTED) CCQ on CCQ.MVDID = ER1.MVDID
		  LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA on CA.MVDID = CCQ.MVDID
		  LEFT JOIN FinalMember (READUNCOMMITTED) FM on FM.MVDID = CCQ.MVDID
			  WHERE CCQ.IsActive = 1 
			    AND ISNULL(FM.CompanyKey,'0000') != '1338'
			    AND ISNULL(CCQ.CaseOwner,'--') = '--'
			    AND ISNULL(CA.PersonalHarm,0) = 0
			    AND ISNULL(FM.COBCD,'U') in ('S','N','U')
			    AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
			    AND ER1.cnt BETWEEN 5 AND 9
				AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)


END