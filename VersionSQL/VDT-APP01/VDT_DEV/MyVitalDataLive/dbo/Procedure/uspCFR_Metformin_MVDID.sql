/****** Object:  Procedure [dbo].[uspCFR_Metformin_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Metformin_MVDID] 
AS
/*
    CustID:  16
    RuleID:  206
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	ALTERd by refactor of original to call uspCFR_Merge
Scott	2021-05-25	Refactor to CTE, add UniversalExclusion for hourly and no benefit.
Scott	2021-08-03	Add new exclusion code
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_Metformin_MVDID	

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Metformin_MVDID', @CustID = 16, @RuleID = 206, @ProductID = 2, @OwnerGroup= 168

EXEC uspCFR_MapRuleExclusion @RuleID = '206', @Action = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

DECLARE @CalcDate Date = GetDate()

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

DROP TABLE IF EXISTS #tempRx

	;WITH cteCCQ AS
		(
  		  SELECT c.[MVDID]
				,c.[MemberID]
				,c.LastName
				,c.FirstName
				,c.LOB
				,ServiceDate
				,SUM(CAST(Rx.DaysSupply AS decimal)) AS DaysSupply
			    ,SUM(CAST(Rx.MetricDecimalQuantity AS decimal)) AS Dose
		   FROM ComputedCareQueue (READUNCOMMITTED) C
		   JOIN FinalRX  (READUNCOMMITTED) RX ON RX.MVDID = C.MVDID
		   JOIN FinalMember  (READUNCOMMITTED) FM ON FM.MVDID = C.MVDID
		  WHERE ISNULL(C.IsActive,0) > 0
		    AND Rx.ClaimStatus = 1
		    AND RX.GenericProductID LIKE '27250050000%'
		    AND RX.ServiceDate > = DATEADD(YEAR,-1,@CalcDate)
		    AND ISNULL(FM.COBCD,'U') IN ('S','N','U')
		    AND ISNULL(FM.CompanyKey,'0000') != '1338'
		    AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
		  GROUP BY C.[MVDID]
			    ,c.[MemberID]
			    ,c.LastName
			    ,c.FirstName
			    ,c.LOB
			    ,ServiceDate
		),
		cteCCQ2 AS
		(
			SELECT MVDID, LastName, FirstName, sum(priorMonths) as PriorPeriod, sum(thisMonth) as ThisMonth 
              FROM (SELECT c.MVDID
					      ,c.MemberID
					      ,c.LastName
					      ,c.FirstName
					      ,c.LOB
					      ,CASE WHEN ServiceDate >= DATEADD(day,-60,@CalcDate) AND C.DaysSupply > 0 THEN 1 ELSE 0 END AS ThisMonth
					      ,CASE WHEN ServiceDate BETWEEN DATEADD(day,-90,@CalcDate) AND DATEADD(day,-61,@CalcDate) AND c.DaysSupply > 0 THEN 1 ELSE 0 END AS PriorMonths
                     FROM cteCCQ c
                   ) ss
             GROUP BY MVDID, LastName, FirstName
		)
		SELECT DISTINCT MVDID 
		  FROM cteCCQ2 ccq2
         WHERE ccq2.PriorPeriod < 1 and ccq2.ThisMonth > 0
	       AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = ccq2.MVDID)
		   
END