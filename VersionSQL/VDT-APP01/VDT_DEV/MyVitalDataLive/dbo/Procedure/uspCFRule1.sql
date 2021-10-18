/****** Object:  Procedure [dbo].[uspCFRule1]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFRule1]
AS
/* =================================================================
Author:	Deepank Johri
Create date: 09-23-2021
Description: Get distinct MVDID's for CFRule1
Example: EXEC dbo.uspCFRule1

Modifications
Date			Name			Comments	
09/23/2021      Deepank         Initial Version (TFS5856)

CREATE TABLE
	NDBHMember
	(
		MVDID varchar(30),
		MemberID varchar(30),
		MemberLastName varchar(255),
		MemberFirstName varchar(255),
		DateOfBirth date,
		Gender varchar(10),
		CMOrgRegion varchar(255),
		ERCount int,
		Category varchar(255)
	);

====================================================================*/
BEGIN

SET NOCOUNT ON;

-- Obtain the list of Members for whom we need to generate NDBH forms
-- Query for New Directions referrals based on ER visits and a behavioral health diagnosis
-- Exclude members that cannot be contacted or have been contacted or are in case management

DROP TABLE IF EXISTS #ExcludedMVDID
DROP TABLE IF EXISTS #ERVisit
CREATE TABLE #ExcludedMVDID (MVDID varchar(30))

	INSERT INTO #ExcludedMVDID (MVDID)

	SELECT DISTINCT em.MVDID
	  FROM CFR_Rule_Exclusion (readuncommitted) re
	  JOIN HPWorkFlowRule wfr (readuncommitted) ON wfr.Rule_ID = re.RuleID
	  JOIN CFR_ExcludedMVDID (readuncommitted) em ON em.ExclusionID = re.ExclusionID
	  JOIN CFR_Exclusion (readuncommitted) e ON em.ExclusionID = e.ID
	 WHERE wfr.Name = 'SUD with Depression and no Cancer';

	 CREATE INDEX IX_ExcludedMVIDID ON #ExcludedMVDID (MVDID);

-- accounts for more than 1 ER visit
-- accounts for having a New Directions benefit
	SELECT
		FCH.MVDID,
		COUNT(DISTINCT StatementFromDate) ERCount
	INTO
		#ERVisit
	FROM
		finalclaimsheader (readuncommitted) FCH
		JOIN ComputedCareQueue (readuncommitted) CCQ
			on CCQ.MVDID = FCH.MVDID
			AND CCQ.IsActive = 1 -- must currently be enrolled in plan
-- does not currently have a medical / SW case manager assigned
			AND ISNULL(CCQ.CaseOwner,'--') = '--'
		JOIN FinalMember (readuncommitted) FM
			on FM.MVDID = CCQ.MVDID
			AND ISNULL(FM.CompanyKey,'0000') != '1338' -- not assigned to ABCBS employee company
			AND ISNULL(FM.COBCD,'U') IN ('S','N','U') -- has primary coverage by ABCBS
			AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
			AND FM.NewDirSvcCd in ('CM','UMCM','UM') -- Serviced by New Directions
		LEFT JOIN ComputedMemberAlert (readuncommitted) CA on CA.MVDID = CCQ.MVDID
		LEFT JOIN #ExcludedMVDID EM ON EM.MVDID = CCQ.MVDID
	WHERE
		DATEDIFF( DAY, StatementFromDate, GetUTCDate() ) <= 365 -- rolling 12 month lookback
		AND ISNULL(EmergencyIndicator,0) = 1 -- include only ER visits per EBI definition
		AND ISNULL(AdjustmentCode,'O') != 'A' -- ignore adjustement claims
		AND ISNULL(CA.PersonalHarm,0) = 0 -- no Personal Harm / no contact alert
--Dev does not have data if we apply this filter
--but we need to uncomment in UAT & Live
/*
		AND NOT EXISTS
		(SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID) -- not in an excluded company for benefits
*/
	GROUP BY
		FCH.MVDID
	HAVING
		COUNT(DISTINCT StatementFromDate) > 1;

	TRUNCATE TABLE NDBHMember;

	INSERT INTO
	NDBHMember
	(
		MVDID,
		MemberID,
		MemberLastName,
		MemberFirstName,
		DateOfBirth,
		Gender,
		CMOrgRegion,
		ERCount,
		Category
	)
-- 1-Panic d/o & Anxiety disorders + 2,3,4 & 5 or more ER visits (does not have to be primary dx)


select distinct HC.MVDID, FM.MemberID, FM.MemberLastName,FM.MemberFirstName, FM.DateOfBirth,FM.Gender, FM.CmOrgRegion, ER.ErCount,ND.Category
from FinalClaimsHeaderCode (readuncommitted) HC
join FinalClaimsHeader (readuncommitted) H on H.ClaimNumber = HC.ClaimNumber and H.MVDID = HC.MVDID
join FinalMember (readuncommitted) FM on FM.MVDID = HC.MVDID
join #ERVisit ER on ER. MVDID = HC.MVDID
join ABCBS_NDBHDiagnosis (readuncommitted) ND on HC.CodeValue = ND.Dx_Codes
where
DATEDIFF( DAY, H.StatementFromDate, GetUTCDate() ) <= 365 -- just claims in rolling 12 months
AND ND.Category = 'Panic d/o & Anxiety disorders'
AND ER.ERCount > 5
AND FM.CmOrgRegion = 'WALMART'

union

-- 2-Axis 2 personality disorders (Borderline PD or Dependent PD) + 2,3,4 & 5 or more ER visits (does not have to be primary dx)
select distinct HC.MVDID, FM.MemberID, FM.MemberLastName,FM.MemberFirstName, FM.DateOfBirth,FM.Gender, FM.CmOrgRegion,ER.ErCount,ND.Category
from FinalClaimsHeaderCode (readuncommitted) HC
join FinalClaimsHeader (readuncommitted) H on H.ClaimNumber = HC.ClaimNumber and H.MVDID = HC.MVDID
join FinalMember (readuncommitted) FM on FM.MVDID = HC.MVDID
join #ERVisit ER on ER. MVDID = HC.MVDID
join ABCBS_NDBHDiagnosis (readuncommitted) ND on HC.CodeValue = ND.Dx_Codes
where
DATEDIFF( DAY, H.StatementFromDate, GetUTCDate() ) <= 365 -- just claims in rolling 12 months
AND ND.Category = 'Axis 2 personality disorders'
AND ER.ERCount > 3
AND FM.CmOrgRegion = 'WALMART'

union

-- 3-Bipolar d/o +2,3,4 & 5 or more ER visits (does not have to be primary dx)
select distinct HC.MVDID, FM.MemberID, FM.MemberLastName,FM.MemberFirstName, FM.DateOfBirth,FM.Gender, FM.CmOrgRegion,ER.ErCount,ND.Category
from FinalClaimsHeaderCode (readuncommitted) HC
join FinalClaimsHeader (readuncommitted) H on H.ClaimNumber = HC.ClaimNumber and H.MVDID = HC.MVDID
join FinalMember (readuncommitted) FM on FM.MVDID = HC.MVDID
join #ERVisit ER on ER. MVDID = HC.MVDID
join ABCBS_NDBHDiagnosis (readuncommitted) ND on HC.CodeValue = ND.Dx_Codes
where
DATEDIFF( DAY, H.StatementFromDate, GetUTCDate() ) <= 365 -- just claims in rolling 12 months
AND ND.Category = 'Bipolar d/o'
AND ER.ERCount > 4
AND FM.CmOrgRegion = 'WALMART'

union

-- 4-Schizophrenia + 2,3,4 & 5 or more ER visits (does not have to be primary dx)
select distinct HC.MVDID, FM.MemberID, FM.MemberLastName,FM.MemberFirstName, FM.DateOfBirth,FM.Gender, FM.CmOrgRegion,ER.ErCount, ND.Category
from FinalClaimsHeaderCode (readuncommitted) HC
join FinalClaimsHeader (readuncommitted) H on H.ClaimNumber = HC.ClaimNumber and H.MVDID = HC.MVDID
join FinalMember (readuncommitted) FM on FM.MVDID = HC.MVDID
join #ERVisit ER on ER. MVDID = HC.MVDID
join ABCBS_NDBHDiagnosis (readuncommitted) ND on HC.CodeValue = ND.Dx_Codes
where
DATEDIFF( DAY, H.StatementFromDate, GetUTCDate() ) <= 365 -- just claims in rolling 12 months
AND ND.Category = 'Schizophrenia'
AND ER.ERCount > 2
AND FM.CmOrgRegion = 'WALMART'

union

-- 5-Suicidology + 2,3,4 & 5 or more ER visits (does not have to be primary dx)
select distinct HC.MVDID, FM.MemberID, FM.MemberLastName,FM.MemberFirstName, FM.DateOfBirth,FM.Gender, FM.CmOrgRegion,ER.ErCount,ND.Category
from FinalClaimsHeaderCode (readuncommitted) HC
join FinalClaimsHeader (readuncommitted) H on H.ClaimNumber = HC.ClaimNumber and H.MVDID = HC.MVDID
join FinalMember (readuncommitted) FM on FM.MVDID = HC.MVDID
join #ERVisit ER on ER. MVDID = HC.MVDID
join ABCBS_NDBHDiagnosis (readuncommitted) ND on HC.CodeValue = ND.Dx_Codes
where
DATEDIFF( DAY, H.StatementFromDate, GetUTCDate() ) <= 365 -- just claims in rolling 12 months
AND ND.Category = 'Suicidology' 
AND ER.ERCount > 2
AND FM.CmOrgRegion = 'WALMART'

union

-- 6-Eating d/o and 2,3,4 & 5 or more ER visits (does not have to be primary dx)
select distinct HC.MVDID, FM.MemberID, FM.MemberLastName,FM.MemberFirstName, FM.DateOfBirth,FM.Gender, FM.CmOrgRegion,ER.ErCount,ND.Category
from FinalClaimsHeaderCode (readuncommitted) HC
join FinalClaimsHeader (readuncommitted) H on H.ClaimNumber = HC.ClaimNumber and H.MVDID = HC.MVDID
join FinalMember (readuncommitted) FM on FM.MVDID = HC.MVDID
join #ERVisit ER on ER. MVDID = HC.MVDID
join ABCBS_NDBHDiagnosis (readuncommitted) ND on HC.CodeValue = ND.Dx_Codes
where
DATEDIFF( DAY, H.StatementFromDate, GetUTCDate() ) <= 365 -- just claims in rolling 12 months
AND ND.Category = 'Eating d/o'  
AND ER.ERCount > 2
AND FM.CmOrgRegion = 'WALMART'

union

-- 7-SUD dx and 2,3,4 & 5 or more ER visits (does not have to be primary dx)
select distinct HC.MVDID, FM.MemberID, FM.MemberLastName,FM.MemberFirstName, FM.DateOfBirth,FM.Gender, FM.CmOrgRegion,ER.ErCount,ND.Category
from FinalClaimsHeaderCode (readuncommitted) HC
join FinalClaimsHeader (readuncommitted) H on H.ClaimNumber = HC.ClaimNumber and H.MVDID = HC.MVDID
join FinalMember (readuncommitted) FM on FM.MVDID = HC.MVDID
join #ERVisit ER on ER. MVDID = HC.MVDID
join ABCBS_NDBHDiagnosis (readuncommitted) ND on HC.CodeValue = ND.Dx_Codes
where
DATEDIFF( DAY, H.StatementFromDate, GetUTCDate() ) <= 365 -- just claims in rolling 12 months
AND ND.Category = 'SUD dx' 
AND ER.ERCount > 3
AND FM.CmOrgRegion = 'WALMART'

union

select distinct HC.MVDID, FM.MemberID, FM.MemberLastName,FM.MemberFirstName, FM.DateOfBirth,FM.Gender, FM.CmOrgRegion,ER.ErCount, ND.Category
from FinalClaimsHeaderCode (readuncommitted) HC
join FinalClaimsHeader (readuncommitted) H on H.ClaimNumber = HC.ClaimNumber and H.MVDID = HC.MVDID
join FinalMember (readuncommitted) FM on FM.MVDID = HC.MVDID
join #ERVisit ER on ER. MVDID = HC.MVDID
join ABCBS_NDBHDiagnosis (readuncommitted) ND on HC.CodeValue = ND.Dx_Codes
where
DATEDIFF( DAY, H.StatementFromDate, GetUTCDate() ) <= 365 -- just claims in rolling 12 months
and IsNull(HC.PrimaryIndicator,'N') = 'Y'
AND ND.Category = 'ED visits with any primary BH dx'
AND FM.CmOrgRegion = 'WALMART'
AND ER.ERCount > 2

union

select distinct HC.MVDID, FM.MemberID, FM.MemberLastName,FM.MemberFirstName, FM.DateOfBirth,FM.Gender, FM.CmOrgRegion,ER.ErCount, ND.Category
from FinalClaimsHeaderCode (readuncommitted) HC
join FinalClaimsHeader (readuncommitted) H on H.ClaimNumber = HC.ClaimNumber and H.MVDID = HC.MVDID
join FinalMember (readuncommitted) FM on FM.MVDID = HC.MVDID
join #ERVisit ER on ER. MVDID = HC.MVDID
join ABCBS_NDBHDiagnosis (readuncommitted) ND on HC.CodeValue = ND.Dx_Codes
where
DATEDIFF( DAY, H.StatementFromDate, GetUTCDate() ) <= 365 -- just claims in rolling 12 months
and IsNull(HC.PrimaryIndicator,'N') = 'Y'
AND ND.Category = 'ED visits with any primary BH dx'
AND ER.ERCount > 2

END