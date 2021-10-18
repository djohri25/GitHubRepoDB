/****** Object:  Procedure [dbo].[uspCFR_Covid19_10Day_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Covid19_10Day_MVDID] 
AS
/*
    CustID:  16
    RuleID:  241
 ProductID:  2
OwnerGroup:  159	--clinical support

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	ALTERd by refactor of original to call uspCFR_Merge
Scott	2020-11-21	Applied changes from original
Scott	2021-04-14	Add company and hourly exclusions line 79
Scott	2021-08-03	Add new exclusion code.
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_Covid19_10Day_MVDID		--(422/4:05)
 
EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Covid19_10Day_MVDID', @CustID = 16, @RuleID = 241, @ProductID = 2, @OwnerGroup= 159

EXEC uspCFR_MapRuleExclusion @RuleID = '241', @Action = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;
	DECLARE @RuleID int = 241

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

-- Covid-19 Careflow Rule
	DROP TABLE IF EXISTS #CovidCode
	DROP TABLE IF EXISTS #Contact1
	   
-- collect the first and last diagnosis date for each member
SELECT DISTINCT MVDID, MIN(StatementFromDate) AS FirstDxDate, MAX(StatementFromDate) AS LastDxDate, MAX(CompanyKey) CompanyKey  
  INTO #CovidCode 
  FROM (SELECT C.MVDID, CodeType, CodeValue, C.ClaimNumber, H.StatementFromDate, FM.CompanyKey
		  FROM FinalClaimsHeaderCode C
		  JOIN FinalClaimsHeader H on H.ClaimNumber = C.ClaimNumber
		  JOIN FinalMember FM on FM.MVDID = H.MVDID
		 WHERE CodeType='DIAG' and CodeValue in ('U071')
		   AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
		   AND ISNULL(FM.COBCD,'U') in ('S','N','U')
		   AND ISNULL(FM.CompanyKey,'0000') != '1338'
		   AND DATEDIFF(DAY,H.StatementFromDate,GetDate()) <= 10
		 UNION
		SELECT C.MVDID, CodeType, CodeValue, C.ClaimNumber , H.StatementFromDate, FM.CompanyKey
		  FROM FinalClaimsDetailCode C
		  JOIN FinalClaimsHeader H on H.ClaimNumber = C.ClaimNumber
		  JOIN FinalMember FM on FM.MVDID = H.MVDID
		 WHERE CodeType='DIAG' and CodeValue in ('U071')
		   --AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
		   AND ISNULL(FM.COBCD,'U') in ('S','N','U')
		   AND ISNULL(FM.CompanyKey,'0000') != '1338'
		   AND DATEDIFF(DAY,H.StatementFromDate,GetDate()) <= 10
	   ) a
 GROUP BY MVDID

-- collect the contact forms for identified members
SELECT DISTINCT CF.MVDID, C.FirstDxDate, C.LastDxDate, CF.FormDate, CF.q7ContactSuccess, CF.q4ContactType
  INTO #Contact1
  FROM #CovidCode C
  JOIN ARBCBS_Contact_Form CF on CF.MVDID = C.MVDID and CF.FormDate >= C.FirstDxDate

INSERT INTO #Contact1 (MVDID, FirstDxDate, LastDxDate, FormDate)
SELECT MMF.MVDID,C.FirstDxDate, C.LastDxDate,MMF.FormDate
  FROM #CovidCode C
  JOIN ABCBS_MemberManagement_Form MMF on MMF.MVDID = C.MVDID and MMF.FormDate >= C.FirstDxDate

    SELECT DISTINCT MVDID 
      FROM #CovidCode cc 
     WHERE MVDID NOT IN (SELECT MVDID FROM #Contact1) 
       AND MVDID NOT IN (SELECT MVDID FROM ComputedCareQueue (READUNCOMMITTED) WHERE ISNULL(CaseID,-1) > 0)
	   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = cc.MVDID)

DROP TABLE IF EXISTS #CovidCode
DROP TABLE IF EXISTS #Contact1
	
END