/****** Object:  Procedure [dbo].[uspCreateNDBHForms]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCreateNDBHForms]
AS
/* =================================================================
Author:	Deepank Johri
Create date: 08-12-2021
Description:	Create NDBH forms based on behavioral health factors
This program is meant to run as a job nightly after CFRs complete
Example: EXEC dbo.uspCreateNDBHForms 

Modifications
Date			Name			Comments	
08/12/2021      Deepank         Initial Version (TFS5856)
08/20/2021      Deepank         Created logic to add all JSON fields (TFS5856)
08/25/2021      Deepank,Ed      Modified logic for all JSON fields 
09/03/2021		Deepank			Added query for BH records (TFS6058)
09/06/2021		Deepank         Modified query to optimize 
09/06/2021		Deepank         Created new table to list all diagnosis codes (TFS6058)
                                Added logic to insert BH records into temp table 
09/17/2021		Deepank,Ed      Added logic to create HPAlertNote
09/22/2021      Deepank         Added logic for ERCount and CMOrgRegion for BH factors
                                Added logic to get members for Predicted SUD population 
								and mme overlap and opioid use disorder. Getting distinct
								MVDID from all 3 CF rules
09/23/2021		Deepank,Ed		Added filter for NDBH CFRs
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
		FinalClaimsHeader (readuncommitted) FCH
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
		AND NOT EXISTS
		(SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID) -- not in an excluded company for benefits
	GROUP BY
		FCH.MVDID
	HAVING
		COUNT(DISTINCT StatementFromDate) > 1;

	DROP TABLE IF EXISTS #NDBHMember;

	CREATE TABLE
	#NDBHMember
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

	INSERT INTO
	#NDBHMember
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

/********************************************
GET MVDID for Predicted SUD population
*********************************************/
DROP TABLE IF EXISTS #PredictedSUD_TopPercent
;
SELECT TOP 17 PERCENT *
INTO #PredictedSUD_TopPercent
FROM 
	(SELECT DISTINCT M.MVDID--,M.MemberID, M.MemberLastName,M.MemberFirstName, M.DateOfBirth,M.Gender, M.CmOrgRegion,0,'Predicted SUD population' AS Category
		, Member_HealthHxTable.PartyKey
		, Member_HealthHxTable.CFR_Indicator_MMEOverlap_p360d
		, Member_HealthHxTable.CFR_Indicator_OpioidUseDisorder_p360d
		, Member_HealthHxTable.CFR_Indicator_PredictedMMEOverlapSUDDx_f360d
		, Member_HealthHxTable.Prob_Predicted_SUD
	FROM Datalogy.NewDirections.pastMMEOverlap_predictedSUD_DemoDxMMERx__active_360d AS Member_HealthHxTable (readuncommitted)
	JOIN Final.dbo.FinalMember M (readuncommitted) on Member_HealthHxTable.Partykey = M.PartyKey
	WHERE CFR_Indicator_PredictedMMEOverlapSUDDx_f360d > 0 AND Member_HealthHxTable.CmOrgRegion = 'WALMART' 
	) AS PredictedSUD
ORDER BY Prob_Predicted_SUD DESC
;
--==========================================================================
-- GET MVDID for mme overlap and opioid use disorder
--==========================================================================
DROP TABLE IF EXISTS #MMEOverlapANDOpioidUseDisorder_p360d
;
SELECT 
	DISTINCT M.MVDID--,M.MemberID, M.MemberLastName,M.MemberFirstName, M.DateOfBirth,M.Gender, M.CmOrgRegion,0,'MMEOverlapANDOpioidUseDisorder' AS Category
	, Member_HealthHxTable.PartyKey
	, Member_HealthHxTable.CFR_Indicator_MMEOverlap_p360d
	, Member_HealthHxTable.CFR_Indicator_OpioidUseDisorder_p360d
	, Member_HealthHxTable.CFR_Indicator_PredictedMMEOverlapSUDDx_f360d
	, Member_HealthHxTable.Prob_Predicted_SUD
INTO #MMEOverlapANDOpioidUseDisorder_p360d
FROM Datalogy.NewDirections.pastMMEOverlap_predictedSUD_DemoDxMMERx__active_360d AS Member_HealthHxTable (readuncommitted)
JOIN Final.dbo.FinalMember M (readuncommitted) on Member_HealthHxTable.Partykey = M.PartyKey
WHERE (CFR_Indicator_MMEOverlap_p360d > 0 AND CFR_Indicator_OpioidUseDisorder_p360d > 0 AND Member_HealthHxTable.CmOrgRegion = 'WALMART')
;        


/**************************
GET DISITNCT MVDID
**************************/
DROP TABLE IF EXISTS #NDBHMember_Final
;
SELECT 
	DISTINCT NM.MVDID
 INTO #NDBHMember_Final 
 FROM #NDBHMember NM
 LEFT JOIN #PredictedSUD_TopPercent PSUD
 ON NM.MVDID = PSUD.MVDID
 LEFT JOIN #MMEOverlapANDOpioidUseDisorder_p360d MMEOverlap
 ON NM.MVDID = MMEOverlap.MVDID
 
-- We don't need to create forms for members who already have them
	MERGE INTO
	#NDBHMember_Final d
	USING
	(
		SELECT DISTINCT
		MVDID
		FROM
		ABCBS_ReferralToNewDirections_Form (readuncommitted) 
		WHERE DATEDIFF( DAY, LoadDate, GetUTCDate() ) <= 365 -- rolling 12 month lookback
	) s
	ON s.MVDID = d.MVDID
	WHEN MATCHED THEN DELETE;

/***************************
CareFlow Rule
****************************/
DROP TABLE IF EXISTS #CareFlowNormalized;

SELECT DISTINCT
CF.MVDID,
'{"CareFlow":"' + CF.Name + '"}' CareFlowRule
INTO
#CareFlowNormalized
FROM
(
	SELECT DISTINCT
	wfr.Name,
	cft.mvdid,
	cft.CreatedDate,
	FIRST_VALUE( cft.RuleId ) OVER ( PARTITION BY cft.ID ORDER BY cft.createddate ) CareFlowRuleId,
	ROW_NUMBER() OVER ( PARTITION BY cft.ID ORDER BY cft.createddate ) rownum
	FROM
    MyVitalDataLive.dbo.CareFlowTask cft with (readuncommitted)
	JOIN HPWorkFlowRule wfr with (readuncommitted) 
	ON cft.RuleID = wfr.Rule_ID
	AND wfr.Body LIKE '%NDBH%'
) CF
JOIN #NDBHMember_Final Ref with (readuncommitted)
ON CF.MVDID = Ref.MVDID
WHERE
-- Get the CareFlow Rules. This is simply the lowest rownum
CF.rownum = 1

CREATE INDEX IX_CareFlowNormalized ON #CareFlowNormalized( MVDID );

DROP TABLE IF EXISTS #CFRule;

;WITH CareFlowCTE
(
	MVDID,
	CareFlowRule
)
AS
(
	SELECT DISTINCT
	pd.MVDID,
	STUFF
	(
		(
			SELECT
			',' + pdn.CareFlowRule
			FROM
			#CareFlowNormalized pdn
			WHERE
			pdn.MVDID = pd.MVDID
			ORDER BY
			pd.MVDID,
			pd.CareFlowRule
			FOR XML PATH( '' )
		), 1, 1, ''
	) AS CareFlowSerialized
	FROM
	#CareFlowNormalized pd
)
SELECT
MVDID,
CASE
WHEN CareFlowRule IS NULL THEN NULL
ELSE CONCAT( '[', CareFlowRule, ']' )
END CareFlow
INTO
#CFRule
FROM
CareFlowCTE;

CREATE INDEX IX_CFRule ON #CFRule( MVDID );

--Initial temp table

DROP TABLE IF EXISTS #OpioidPrescription

SELECT 
        
		  MVDID
		, OpioidPrescriptionName
		, PrescriberID
		, PrescriberName
		, PharmacyName
        , DrugStrengthUnitOfMeasure
		, RefillsAuthorizedCount
		, NDCCode
		, SUM(Total#UniqueOpioidPrescribed) as Total#UniqueOpioidPrescribed
		, SUM(MetricDecimalQuantity) AS MetricDecimalQuantity
	INTO #OpioidPrescription
FROM
        (    
	SELECT  Rx.MVDID
		, ISNULL(DrugProductName,'') as OpioidPrescriptionName
		, PrescriberID
		, PrescriberName
		, PharmacyName
        , ISNULL(DrugStrengthUnitOfMeasure,'') AS DrugStrengthUnitOfMeasure
		, ISNULL(RefillsAuthorizedCount,0) AS RefillsAuthorizedCount
		, NDCCode
		, COUNT(distinct DrugProductName) as Total#UniqueOpioidPrescribed
		, CAST(MetricDecimalQuantity AS float) AS MetricDecimalQuantity
	FROM Final.dbo.FinalRX Rx with (readuncommitted)
	JOIN #NDBHMember_Final Ref1 with (readuncommitted)
	ON Rx.MVDID = Ref1.MVDID
	 WHERE (ClaimStatus = '1' OR ClaimStatus IS NULL) 	           --> 
	 AND PaidAmount >= 0										   --> 
	 AND CAST(DaysSupply AS float) > 0                          --> Same as the filter in generating main Rx features 
	 AND LOB IN ('US', 'BH', 'BC', 'BX', 'HA')          -->
	 AND DATEDIFF( DAY, ServiceDate, GetUTCDate() ) <= 365
	GROUP BY  Rx.MVDID
		, DrugProductName
		, PrescriberID
		, PrescriberName
		, PharmacyName
        , DrugStrengthUnitOfMeasure
		, RefillsAuthorizedCount
		, MetricDecimalQuantity
		, NDCCode
	)x
  GROUP BY  MVDID
		, OpioidPrescriptionName
		, PrescriberID
		, PrescriberName
		, PharmacyName
        , DrugStrengthUnitOfMeasure
		, RefillsAuthorizedCount
		, NDCCode

CREATE INDEX IX_OpioidPrescriptione ON #OpioidPrescription(MVDID, OpioidPrescriptionName, PrescriberID, PrescriberName
                                                         , PharmacyName, DrugStrengthUnitOfMeasure, RefillsAuthorizedCount
														 , NDCCode, Total#UniqueOpioidPrescribed, MetricDecimalQuantity )

/***************************
  Opioid Prescriptions Names (Brand when available, else Generic)
, Metric Decimal Quantity
, Drug Strength Unit of Measure (if/when available)
, Refill Authorized Count (past 12 months)
****************************/

DROP TABLE IF EXISTS #OpioidNormalized;

SELECT DISTINCT
MVDID,
'{"PrescriptionName":"' + OpioidPrescriptionName + '", "MetricDecimalQuantity":"' + CONVERT(VARCHAR(10),MetricDecimalQuantity) + '", "UOM":"' 
+ DrugStrengthUnitOfMeasure + '", "RefillAuthorizedCount:"' + CONVERT(VARCHAR(5),RefillsAuthorizedCount ) + '", "NDC:"' + NDCCode + '"}' Opioid
INTO
#OpioidNormalized
FROM
(
	SELECT DISTINCT
	MVDID,
	OpioidPrescriptionName,
	MetricDecimalQuantity,
	DrugStrengthUnitOfMeasure,
	RefillsAuthorizedCount,
	NDCCode,
	FIRST_VALUE( op.OpioidPrescriptionName ) OVER ( PARTITION BY op.MVDID,op.OpioidPrescriptionName
	,op.PrescriberID,op.PrescriberName,op.PharmacyName,op.DrugStrengthUnitOfMeasure
	,op.RefillsAuthorizedCount,op.NDCCode
	ORDER BY op.MVDID ) CareFlowRuleId,
	ROW_NUMBER() OVER ( PARTITION BY op.OpioidPrescriptionName ORDER BY op.MVDID ) rownum
	FROM #OpioidPrescription op
) PP
WHERE
-- Get the CareFlow Rules. This is simply the lowest rownum
PP.rownum = 1

CREATE INDEX IX_OpioidPrescriptionNormalized ON #OpioidNormalized( MVDID );

DROP TABLE IF EXISTS #OpioidRule;

;WITH OpioidCTE
(
	MVDID,
	Opioid
)
AS
(
	SELECT DISTINCT
	pd.MVDID,
	STUFF
	(
		(
			SELECT
			',' + pdn.Opioid
			FROM
			#OpioidNormalized pdn
			WHERE
			pdn.MVDID = pd.MVDID
			ORDER BY
			pd.MVDID,
			pd.Opioid
			FOR XML PATH( '' )
		), 1, 1, ''
	) AS PrescriptionSerialized
	FROM
	#OpioidNormalized pd
)
SELECT
MVDID,
CASE
WHEN Opioid IS NULL THEN NULL
ELSE CONCAT( '[', Opioid, ']' )
END Prescription
INTO
#OpioidRule
FROM
OpioidCTE;

CREATE INDEX IX_OpioidRule ON #OpioidRule( MVDID );

/***************************
Behavioral Health dx (from claims) for past 12 months
***************************/
DROP TABLE IF EXISTS #BehavioralHealthDx

SELECT ICD10dx,dxCCS_DESC INTO #BehavioralHealthDx
FROM (
SELECT ICD10dx,dxCCS_DESC
FROM Datalogy.ds.NewDirections_ICD10_MentalHealth with (readuncommitted)
 
Union

SELECT ICD10dx, ICD10dx_shortDESC
FROM Datalogy.ds.Map_ICD10dx_to_dxCCS with (readuncommitted)
WHERE ICD10dx LIKE 'F%'
) x

CREATE INDEX IX_BehaviorDiagnosis ON #BehavioralHealthDx(ICD10dx,dxCCS_DESC);

DROP TABLE IF EXISTS #BehaviorDiagnosisNormalized;

SELECT DISTINCT
fch.MVDID,
'{"BehaviorDiagnosis":"' + luicd.MediumDesc + '", "ICD":"' + fchc.BehaviorDX + '"}' DX
INTO
#BehaviorDiagnosisNormalized
FROM
Final.dbo.FinalClaimsHeader fch with (readuncommitted)
OUTER APPLY
(
	SELECT DISTINCT
	hc.ClaimNumber,
	hc.SequenceNumber,
	FIRST_VALUE( hc.CodeValue ) OVER ( PARTITION BY hc.ClaimNumber ORDER BY hc.SequenceNumber ) BehaviorDX,
    bhd.dxCCS_DESC,
	ROW_NUMBER() OVER ( PARTITION BY hc.ClaimNumber ORDER BY hc.SequenceNumber ) rownum
	FROM
	Final.dbo.FinalClaimsHeaderCode hc with (readuncommitted)
	JOIN #BehavioralHealthDx bhd
	ON hc.CodeValue = bhd.ICD10dx
	WHERE
	hc.CodeType = 'DIAG'
	AND hc.ClaimNumber = fch.ClaimNumber
) fchc
LEFT OUTER JOIN MyVitalDataLive.dbo.LookupICD luicd with (readuncommitted)
ON luicd.CodeNoPeriod = fchc.BehaviorDX
JOIN #NDBHMember_Final Ref with (readuncommitted)
ON fch.MVDID = Ref.MVDID
WHERE
-- Lookback at claims for only one year
DATEADD( YEAR, -1, fch.AdmissionDate ) >= getDate()
-- Get the Behavior diagnosis. This is simply the lowest rownum
AND fchc.rownum = 1

CREATE INDEX IX_BehaviorDiagnosisNormalized ON #BehaviorDiagnosisNormalized( MVDID );

DROP TABLE IF EXISTS #BehaviorDiagnosis;

;WITH BehaviorDiagnosisCTE
(
	MVDID,
	DX
)
AS
(
	SELECT DISTINCT
	pd.MVDID,
	STUFF
	(
		(
			SELECT
			',' + pdn.DX
			FROM
			#BehaviorDiagnosisNormalized pdn
			WHERE
			pdn.MVDID = pd.MVDID
			ORDER BY
			pd.MVDID,
			pd.DX
			FOR XML PATH( '' )
		), 1, 1, ''
	) AS DXSerialized
	FROM
	#BehaviorDiagnosisNormalized pd
)
SELECT
MVDID,
CASE
WHEN DX IS NULL THEN NULL
ELSE CONCAT( '[', DX, ']' )
END DX
INTO
#BehaviorDiagnosis
FROM
BehaviorDiagnosisCTE;

CREATE INDEX IX_BehaviorDiagnosis ON #BehaviorDiagnosis( MVDID );

/***************************
Primary Medical Dx (from claims) for past 12 months
***************************/
DROP TABLE IF EXISTS #PrimaryDiagnosisNormalized;

SELECT DISTINCT
fch.MVDID,
'{"PrimaryDiagnosis":"' + luicd.MediumDesc + '", "ICD":"' + fchc.PrimaryDX + '"}' DX
INTO
#PrimaryDiagnosisNormalized
FROM
Final.dbo.FinalClaimsHeader fch with (readuncommitted)
OUTER APPLY
(
	SELECT DISTINCT
	hc.ClaimNumber,
	hc.SequenceNumber,
	FIRST_VALUE( hc.CodeValue ) OVER ( PARTITION BY hc.ClaimNumber ORDER BY hc.SequenceNumber ) PrimaryDX,
	ROW_NUMBER() OVER ( PARTITION BY hc.ClaimNumber ORDER BY hc.SequenceNumber ) rownum
	FROM
	Final.dbo.FinalClaimsHeaderCode hc with (readuncommitted)
	WHERE
	hc.CodeType = 'DIAG'
	AND hc.ClaimNumber = fch.ClaimNumber
) fchc
LEFT OUTER JOIN MyVitalDataLive.dbo.LookupICD luicd with (readuncommitted)
ON luicd.CodeNoPeriod = fchc.PrimaryDX
JOIN #NDBHMember_Final Ref with (readuncommitted)
ON fch.MVDID = Ref.MVDID
WHERE
-- Lookback at claims for only one year
DATEADD( YEAR, -1, fch.AdmissionDate ) >= getDate()
-- Get the primary diagnosis. This is simply the lowest rownum
AND fchc.rownum = 1

CREATE INDEX IX_PrimaryDiagnosisNormalized ON #PrimaryDiagnosisNormalized( MVDID );

DROP TABLE IF EXISTS #PrimaryDiagnosis;

;WITH PrimaryDiagnosisCTE
(
	MVDID,
	DX
)
AS
(
	SELECT DISTINCT
	pd.MVDID,
	STUFF
	(
		(
			SELECT
			',' + pdn.DX
			FROM
			#PrimaryDiagnosisNormalized pdn
			WHERE
			pdn.MVDID = pd.MVDID
			ORDER BY
			pd.MVDID,
			pd.DX
			FOR XML PATH( '' )
		), 1, 1, ''
	) AS DXSerialized
	FROM
	#PrimaryDiagnosisNormalized pd
)
SELECT
MVDID,
CASE
WHEN DX IS NULL THEN NULL
ELSE CONCAT( '[', DX, ']' )
END DX
INTO
#PrimaryDiagnosis
FROM
PrimaryDiagnosisCTE;

CREATE INDEX IX_PrimaryDiagnosis ON #PrimaryDiagnosis( MVDID );

/***************************
Pain related Health Dx (from claims) for past 12 months
***************************/
DROP TABLE IF EXISTS #PainRelatedDx

SELECT ICD10dx,ICD10dx_shortDESC INTO #PainRelatedDx
FROM (
SELECT ICD10dx,ICD10dx_shortDESC FROM Datalogy.ds.Map_ICD10dx_to_dxCCS with (readuncommitted)
WHERE ICD10dx_shortDESC LIKE '%Pain%'
OR dxCCS IN (251, 102)
) x

CREATE INDEX IX_PainDiagnosis ON #PainRelatedDx(ICD10dx,ICD10dx_shortDESC);

DROP TABLE IF EXISTS #PainDiagnosisNormalized;

SELECT DISTINCT
fch.MVDID,
'{"PainDiagnosis":"' + luicd.MediumDesc + '", "ICD":"' + fchc.PainDX + '"}' DX
INTO
#PainDiagnosisNormalized
FROM
Final.dbo.FinalClaimsHeader fch with (readuncommitted)
OUTER APPLY
(
	SELECT DISTINCT
	hc.ClaimNumber,
	hc.SequenceNumber,
	FIRST_VALUE( hc.CodeValue ) OVER ( PARTITION BY hc.ClaimNumber ORDER BY hc.SequenceNumber ) PainDX,
	ROW_NUMBER() OVER ( PARTITION BY hc.ClaimNumber ORDER BY hc.SequenceNumber ) rownum
	FROM
	Final.dbo.FinalClaimsHeaderCode hc with (readuncommitted)
	JOIN #PainRelatedDx bhd
	ON hc.CodeValue = bhd.ICD10dx
	WHERE
	hc.CodeType = 'DIAG'
	AND hc.ClaimNumber = fch.ClaimNumber
) fchc
LEFT OUTER JOIN MyVitalDataLive.dbo.LookupICD luicd with (readuncommitted)
ON luicd.CodeNoPeriod = fchc.PainDX
JOIN #NDBHMember_Final Ref with (readuncommitted)
ON fch.MVDID = Ref.MVDID
WHERE
-- Lookback at claims for only one year
DATEADD( YEAR, -1, fch.AdmissionDate ) >= getDate()
-- Get the Pain diagnosis. This is simply the lowest rownum
AND fchc.rownum = 1

CREATE INDEX IX_PainDiagnosisNormalized ON #PainDiagnosisNormalized( MVDID );

DROP TABLE IF EXISTS #PainDiagnosis;

;WITH PainDiagnosisCTE
(
	MVDID,
	DX
)
AS
(
	SELECT DISTINCT
	pd.MVDID,
	STUFF
	(
		(
			SELECT
			',' + pdn.DX
			FROM
			#PainDiagnosisNormalized pdn
			WHERE
			pdn.MVDID = pd.MVDID
			ORDER BY
			pd.MVDID,
			pd.DX
			FOR XML PATH( '' )
		), 1, 1, ''
	) AS DXSerialized
	FROM
	#PainDiagnosisNormalized pd
)
SELECT
MVDID,
CASE
WHEN DX IS NULL THEN NULL
ELSE CONCAT( '[', DX, ']' )
END DX
INTO
#PainDiagnosis
FROM
PainDiagnosisCTE;

CREATE INDEX IX_PainDiagnosis ON #PainDiagnosis( MVDID );

/***************************
Prescriber name, Prescriber ID (for any opioid RX)
, total # of unique opioid prescribed          
(over past 12 months) 
****************************/
DROP TABLE IF EXISTS #PrescriberNormalized;

SELECT DISTINCT
MVDID,
'{"PrescriberName":"' + PrescriberName + '", "PrescriberID":"' + PrescriberID + '", "TotalPrescribed":"' + CONVERT(VARCHAR(5),Total#UniqueOpioidPrescribed) + '"}' Prescriber
INTO
#PrescriberNormalized
FROM
(
	SELECT DISTINCT
	MVDID,
	PrescriberName,
	PrescriberID,
	Total#UniqueOpioidPrescribed,
	FIRST_VALUE( op.PrescriberName) OVER ( PARTITION BY op.MVDID,op.OpioidPrescriptionName
	,op.PrescriberID,op.PrescriberName,op.PrescriberName,op.DrugStrengthUnitOfMeasure
	,op.RefillsAuthorizedCount,op.NDCCode
	ORDER BY op.MVDID ) CareFlowRuleId,
	ROW_NUMBER() OVER ( PARTITION BY op.PrescriberName ORDER BY op.MVDID ) rownum
	FROM #OpioidPrescription op
) PP
WHERE
-- Get the CareFlow Rules. This is simply the lowest rownum
PP.rownum = 1

CREATE INDEX IX_PrescriberNormalized ON #PrescriberNormalized( MVDID );

DROP TABLE IF EXISTS #PrescriberRule;

;WITH PrescriberCTE
(
	MVDID,
	Prescriber
)
AS
(
	SELECT DISTINCT
	pd.MVDID,
	STUFF
	(
		(
			SELECT
			',' + pdn.Prescriber
			FROM
			#PrescriberNormalized pdn
			WHERE
			pdn.MVDID = pd.MVDID
			ORDER BY
			pd.MVDID,
			pd.Prescriber
			FOR XML PATH( '' )
		), 1, 1, ''
	) AS PrescriberSerialized
	FROM
	#PrescriberNormalized pd
)
SELECT
MVDID,
CASE
WHEN Prescriber IS NULL THEN NULL
ELSE CONCAT( '[', Prescriber, ']' )
END Prescriber
INTO
#PrescriberRule
FROM
PrescriberCTE;

CREATE INDEX IX_PrescriberRule ON #PrescriberRule( MVDID );

/***************************
SDOH Factors
***************************/
DROP TABLE IF EXISTS #SDOHNormalized;

SELECT DISTINCT
PP.MVDID,
'{"CompositionDisability":"' + CONVERT(VARCHAR(5),SDOH_Vulnerable_HH_ComposiitonDisability) + '", "Language":"' + CONVERT(VARCHAR(5),SDOH_Vulnerable_Language) 
+ '", "OverAll":"' + CONVERT(VARCHAR(5),SDOH_Vulnerable_OverAll) + '", "Socioeconomic":"' + CONVERT(VARCHAR(5),SDOH_Vulnerable_Socioeconomic) + '", "Transportation":"' 
+ CONVERT(VARCHAR(5),SDOH_Vulnerable_Transportation) + '"}' SDOH
INTO
#SDOHNormalized
FROM
(
	SELECT DISTINCT
	MVDID,
	tags.SDOH_Vulnerable_HH_ComposiitonDisability,
	tags.SDOH_Vulnerable_Language,
	tags.SDOH_Vulnerable_OverAll,
	tags.SDOH_Vulnerable_Socioeconomic,
	tags.SDOH_Vulnerable_Transportation,
	FIRST_VALUE(tags.PartyKey) OVER ( PARTITION BY tags.PartyKey,tags.SDOH_Vulnerable_HH_ComposiitonDisability,
	tags.SDOH_Vulnerable_Language,tags.SDOH_Vulnerable_OverAll,tags.SDOH_Vulnerable_Socioeconomic,
	tags.SDOH_Vulnerable_Transportation
	ORDER BY tags.PartyKey ) tagsId,
	ROW_NUMBER() OVER ( PARTITION BY tags.PartyKey,tags.SDOH_Vulnerable_HH_ComposiitonDisability,
	tags.SDOH_Vulnerable_Language,tags.SDOH_Vulnerable_OverAll,tags.SDOH_Vulnerable_Socioeconomic,
	tags.SDOH_Vulnerable_Transportation ORDER BY tags.PartyKey ) rownum
	FROM 
	tags_for_high_risk_members tags with (readuncommitted)
    join FinalMember fm with (readuncommitted)
    on tags.PartyKey = fm.PartyKey
) PP
JOIN #NDBHMember_Final Ref with (readuncommitted)
ON PP.MVDID = Ref.MVDID
WHERE
-- Get the CareFlow Rules. This is simply the lowest rownum
PP.rownum = 1

CREATE INDEX IX_SDOHNormalized ON #SDOHNormalized( MVDID );

DROP TABLE IF EXISTS #SDOHRule;

;WITH SDOHCTE
(
	MVDID,
	SDOH
)
AS
(
	SELECT DISTINCT
	pd.MVDID,
	STUFF
	(
		(
			SELECT
			',' + pdn.SDOH
			FROM
			#SDOHNormalized pdn
			WHERE
			pdn.MVDID = pd.MVDID
			ORDER BY
			pd.MVDID,
			pd.SDOH
			FOR XML PATH( '' )
		), 1, 1, ''
	) AS SDOHSerialized
	FROM
	#SDOHNormalized pd
)
SELECT
MVDID,
CASE
WHEN SDOH IS NULL THEN NULL
ELSE CONCAT( '[', SDOH, ']' )
END SDOH
INTO
#SDOHRule
FROM
SDOHCTE;

CREATE INDEX IX_SDOHRule ON #SDOHRule( MVDID );

/***************************
Chronic Medical Disease Dx (from claims) for past 12 months
***************************/
DROP TABLE IF EXISTS #ChronicHealthDx

SELECT ICD10dx,ICD10dx_DESC INTO #ChronicHealthDx
FROM (
SELECT ICD10dx
      ,ICD10dx_DESC
      ,CCI
  FROM Datalogy.ds.Map_ICD10dx_to_CCI_BSI with (readuncommitted)
  WHERE CCI = 1
) x

CREATE INDEX IX_ChronicDiagnosis ON #ChronicHealthDx(ICD10dx,ICD10dx_DESC);

DROP TABLE IF EXISTS #ChronicDiagnosisNormalized;

SELECT DISTINCT
fch.MVDID,
'{"ChronicDiagnosis":"' + luicd.MediumDesc + '", "ICD":"' + fchc.ChronicDX + '"}' DX
INTO
#ChronicDiagnosisNormalized
FROM
Final.dbo.FinalClaimsHeader fch with (readuncommitted)
OUTER APPLY
(
	SELECT DISTINCT
	hc.ClaimNumber,
	hc.SequenceNumber,
	FIRST_VALUE( hc.CodeValue ) OVER ( PARTITION BY hc.ClaimNumber ORDER BY hc.SequenceNumber ) ChronicDX,
	ROW_NUMBER() OVER ( PARTITION BY hc.ClaimNumber ORDER BY hc.SequenceNumber ) rownum
	FROM
	Final.dbo.FinalClaimsHeaderCode hc with (readuncommitted)
	JOIN #ChronicHealthDx bhd
	ON hc.CodeValue = bhd.ICD10dx
	WHERE
	hc.CodeType = 'DIAG'
	AND hc.ClaimNumber = fch.ClaimNumber
) fchc
LEFT OUTER JOIN MyVitalDataLive.dbo.LookupICD luicd with (readuncommitted)
ON luicd.CodeNoPeriod = fchc.ChronicDX
JOIN #NDBHMember_Final Ref with (readuncommitted)
ON fch.MVDID = Ref.MVDID
WHERE
-- Lookback at claims for only one year
DATEADD( YEAR, -1, fch.AdmissionDate ) >= getDate()
-- Get the Chronic diagnosis. This is simply the lowest rownum
AND fchc.rownum = 1

CREATE INDEX IX_ChronicDiagnosisNormalized ON #ChronicDiagnosisNormalized( MVDID );

DROP TABLE IF EXISTS #ChronicDiagnosis;

;WITH ChronicDiagnosisCTE
(
	MVDID,
	DX
)
AS
(
	SELECT DISTINCT
	pd.MVDID,
	STUFF
	(
		(
			SELECT
			',' + pdn.DX
			FROM
			#ChronicDiagnosisNormalized pdn
			WHERE
			pdn.MVDID = pd.MVDID
			ORDER BY
			pd.MVDID,
			pd.DX
			FOR XML PATH( '' )
		), 1, 1, ''
	) AS DXSerialized
	FROM
	#ChronicDiagnosisNormalized pd
)
SELECT
MVDID,
CASE
WHEN DX IS NULL THEN NULL
ELSE CONCAT( '[', DX, ']' )
END DX
INTO
#ChronicDiagnosis
FROM
ChronicDiagnosisCTE;

CREATE INDEX IX_ChronicDiagnosis ON #ChronicDiagnosis( MVDID );

/***************************
Psychotropic prescriptions and 
fill dates past 12 months (Brand when available, else Generic)
***************************/
DROP TABLE IF EXISTS #PsychotropicPrescription

SELECT NDC.NDC,NDC.BN
INTO #PsychotropicPrescription
FROM [FirstDataBankDB].[dbo].[RNDC14_NDC_MSTR] NDC with (readuncommitted)
JOIN [FirstDataBankDB].[dbo].[RGCNSEQ4_GCNSEQNO_MSTR] LNK with (readuncommitted) on LNK.GCN_SEQNO = NDC.GCN_SEQNO
JOIN [FirstDataBankDB].[dbo].[RGTCD0_GEN_THERAP_CLASS_DESC] GEN with (readuncommitted) on GEN.GTC = LNK.GTC
WHERE GEN.GTC = 80

CREATE INDEX IX_PsychotropicPrescription ON #PsychotropicPrescription(NDC,BN);

DROP TABLE IF EXISTS #PsychotropicPrescriptionNormalized;

SELECT DISTINCT
RXCode.MVDID,
'{"PsychotropicPrescription":"' + RXCode.BN + '", "ICD":"' + RXCode.PsychotropicPrescription + '", "FillDate":"' + convert(varchar(10),RXCode.ServiceDate) + '"}' PsychotropicPrescription
INTO
#PsychotropicPrescriptionNormalized
FROM
(
	SELECT DISTINCT
	pp.BN,
	rx.servicedate,
	rx.mvdid,
	FIRST_VALUE( rx.NDCCode ) OVER ( PARTITION BY rx.ClaimNumber ORDER BY rx.servicedate ) PsychotropicPrescription,
	ROW_NUMBER() OVER ( PARTITION BY rx.ClaimNumber ORDER BY rx.servicedate ) rownum
	FROM
	Final.dbo.FinalRX rx with (readuncommitted)
	JOIN #PsychotropicPrescription pp
	ON rx.NDCCode = pp.NDC
) RXCode

JOIN #NDBHMember_Final Ref with (readuncommitted)
ON RXCode.MVDID = Ref.MVDID
WHERE
-- Lookback at claims for only one year
DATEADD( YEAR, -1, RXCode.ServiceDate ) >= getDate()
-- Get the Psychotropic Prescription. This is simply the lowest rownum
AND RXCode.rownum = 1

CREATE INDEX IX_PsychotropicPrescriptionNormalized ON #PsychotropicPrescriptionNormalized( MVDID );

DROP TABLE IF EXISTS #PsychoPrescription;

;WITH PsychotropicPrescriptionCTE
(
	MVDID,
	Prescription
)
AS
(
	SELECT DISTINCT
	pd.MVDID,
	STUFF
	(
		(
			SELECT
			',' + pdn.PsychotropicPrescription
			FROM
			#PsychotropicPrescriptionNormalized pdn
			WHERE
			pdn.MVDID = pd.MVDID
			ORDER BY
			pd.MVDID,
			pd.PsychotropicPrescription
			FOR XML PATH( '' )
		), 1, 1, ''
	) AS PrescriptionSerialized
	FROM
	#PsychotropicPrescriptionNormalized pd
)
SELECT
MVDID,
CASE
WHEN Prescription IS NULL THEN NULL
ELSE CONCAT( '[', Prescription, ']' )
END Prescription
INTO
#PsychoPrescription
FROM
PsychotropicPrescriptionCTE;

CREATE INDEX #PsychoPrescription ON #PsychoPrescription( MVDID );

/************************
 --ER Counts     
 ************************/

        DROP TABLE IF EXISTS #ERVisitCount

		SELECT 
		       MVDID,SUM(ERCount) ERCount
		     , AdmissionDate, DischargeDate
			 , ERNames
			 , ERAddress1, ERAddress2
			 , ERCity, ERState, ERZip
        INTO #ERVisitCount
		FROM
		    (
		SELECT
		       fch.MVDID,COUNT(DISTINCT AdmissionDate) ERCount
		     , fch.AdmissionDate, fch.DischargeDate
			 , CASE WHEN fp.BusinessName IS NULL THEN CONCAT(fp.ProviderLastName, fp.ProviderFirstName) ELSE fp.BusinessName END as ERNames
			 , fp.BusinessAddress1 as ERAddress1, fp.BusinessAddress2 as ERAddress2
			 , fp.BusinessCity as ERCity, fp.BusinessState as ERState, fp.BusinessZip as ERZip
		FROM dbo.finalclaimsheader fch (readuncommitted)
		JOIN dbo.FinalProvider fp (readuncommitted)
		ON fch.AttendingProviderNPI = fp.NPI
		JOIN #NDBHMember_Final Ref2 with (readuncommitted)
		ON fch.MVDID = Ref2.MVDID
		WHERE DATEDIFF( DAY, AdmissionDate, GetUTCDate() ) <= 365
        AND EmergencyIndicator = 1 
		GROUP BY fch.MVDID,  fch.AdmissionDate, fch.DischargeDate, fp.BusinessName,fp.ProviderLastName
		        , fp.ProviderFirstName, fp.BusinessAddress1, fp.BusinessAddress2, fp.BusinessCity
				, fp.BusinessState, fp.BusinessZip
            )r
		GROUP BY MVDID, AdmissionDate, DischargeDate
		        , ERNames, ERAddress1, ERAddress2, ERCity, ERState, ERZip

CREATE INDEX IX_ERVisitCount ON #ERVisitCount( MVDID,ERCount,AdmissionDate,DischargeDate,ERNames
			                                 , ERAddress1, ERAddress2, ERCity, ERState, ERZip )

/***************************
Total number of ER visits past 12 months (Do not send dates)
****************************/
DROP TABLE IF EXISTS #ERVisitNormalized;

SELECT DISTINCT
MVDID,
'{"ERVisit":"' + CONVERT(VARCHAR(5),ERCount) + '"}' ERVisit
INTO
#ERVisitNormalized
FROM
(
	SELECT DISTINCT
	er.MVDID,
	SUM(er.ERCount) ERCount,
	FIRST_VALUE(er.MVDID) OVER ( PARTITION BY er.MVDID
	ORDER BY er.ERCount ) ERVisitId,
	ROW_NUMBER() OVER ( PARTITION BY er.MVDID ORDER BY er.ERCount ) rownum
	FROM #ERVisitCount er
	GROUP BY er.MVDID,er.ERCount
) PP
WHERE
-- Get the CareFlow Rules. This is simply the lowest rownum
PP.rownum = 1

CREATE INDEX IX_#ERVisitNormalized ON #ERVisitNormalized( MVDID );

DROP TABLE IF EXISTS #ERVisitRule

;WITH ERVisitCTE
(
	MVDID,
	ERVisit
)
AS
(
	SELECT DISTINCT
	pd.MVDID,
	STUFF
	(
		(
			SELECT
			',' + pdn.ERVisit
			FROM
			#ERVisitNormalized pdn
			WHERE
			pdn.MVDID = pd.MVDID
			ORDER BY
			pd.MVDID,
			pd.ERVisit
			FOR XML PATH( '' )
		), 1, 1, ''
	) AS ERVisitSerialized
	FROM
	#ERVisitNormalized pd
)
SELECT
MVDID,
CASE
WHEN ERVisit IS NULL THEN NULL
ELSE CONCAT( '[', ERVisit, ']' )
END ERVisit
INTO
#ERVisitRule
FROM
ERVisitCTE;

CREATE INDEX IX_ERVisitRule ON #ERVisitRule( MVDID );

/************************
ER dates of service, primary dx past 12 months
*************************/
DROP TABLE IF EXISTS #ERDateofServiceNormalized;

SELECT DISTINCT
MVDID,
'{"ERServiceFromDate":"' + CONVERT(VARCHAR(11),AdmissionDate,101) + '"}' ERDateofService
INTO
#ERDateofServiceNormalized
FROM
(
	SELECT DISTINCT
	MVDID,
	AdmissionDate,
	FIRST_VALUE(er.MVDID) OVER ( PARTITION BY er.MVDID
	ORDER BY er.ERCount ) ERDateofServiceId,
	ROW_NUMBER() OVER ( PARTITION BY er.MVDID ORDER BY er.ERCount ) rownum
	FROM #ERVisitCount er
	GROUP BY MVDID,ERCount,AdmissionDate
) PP

CREATE INDEX IX_ERDateofService ON #ERDateofServiceNormalized( MVDID );

DROP TABLE IF EXISTS #ERDateofServiceRule

;WITH ERDateofServiceCTE
(
	MVDID,
	ERDateofService
)
AS
(
	SELECT DISTINCT
	pd.MVDID,
	STUFF
	(
		(
			SELECT
			',' + pdn.ERDateofService
			FROM
			#ERDateofServiceNormalized pdn
			WHERE
			pdn.MVDID = pd.MVDID
			ORDER BY
			pd.MVDID,
			pd.ERDateofService
			FOR XML PATH( '' )
		), 1, 1, ''
	) AS ERDateofServiceSerialized
	FROM
	#ERDateofServiceNormalized pd
)
SELECT
MVDID,
CASE
WHEN ERDateofService IS NULL THEN NULL
ELSE CONCAT( '[', ERDateofService, ']' )
END ERDateofService
INTO
#ERDateofServiceRule
FROM
ERDateofServiceCTE;

CREATE INDEX IX_ERDateofServiceRule ON #ERDateofServiceRule( MVDID );

/***************************
ER names, addresses used over past 12 months
***************************/
DROP TABLE IF EXISTS #ERDetailsNormalized;

SELECT DISTINCT
MVDID,
'{"ERName":"' + ERNames + '", "ERAddress":"' + CONCAT(ERAddress1,' ',ERAddress2,' ',ERCity,' ',ERState,' ',ERZip) + '"}' ERDetails
INTO
#ERDetailsNormalized
FROM
(
	SELECT DISTINCT
	MVDID,
	ERNames,
	ERAddress1,
	ERAddress2,
	ERCity,
	ERState,
	ERZip,
	FIRST_VALUE(er.MVDID) OVER ( PARTITION BY er.MVDID
	ORDER BY er.ERCount ) ERDetailsId,
	ROW_NUMBER() OVER ( PARTITION BY er.MVDID ORDER BY er.ERCount ) rownum
	FROM #ERVisitCount er
	GROUP BY MVDID,ERCount--,AdmissionDate
	,ERNames,ERAddress1,ERAddress2,ERCity,ERState,ERZip
) PP

CREATE INDEX IX_ERDetailsNormalized ON #ERDetailsNormalized( MVDID );

DROP TABLE IF EXISTS #ERDetailsRule

;WITH ERDetailsCTE
(
	MVDID,
	ERDetails
)
AS
(
	SELECT DISTINCT
	pd.MVDID,
	STUFF
	(
		(
			SELECT
			',' + pdn.ERDetails
			FROM
			#ERDetailsNormalized pdn
			WHERE
			pdn.MVDID = pd.MVDID
			ORDER BY
			pd.MVDID,
			pd.ERDetails
			FOR XML PATH( '' )
		), 1, 1, ''
	) AS ERDetailsSerialized
	FROM
	#ERDetailsNormalized pd
)
SELECT
MVDID,
CASE
WHEN ERDetails IS NULL THEN NULL
ELSE CONCAT( '[', ERDetails, ']' )
END ERDetails
INTO
#ERDetailsRule
FROM
ERDetailsCTE;

CREATE INDEX IX_ERDetailsRule ON #ERDetailsRule( MVDID );

/***************************
Pharmacy names, address, phone number (past 12 months)
****************************/
DROP TABLE IF EXISTS #PharmacyNormalized;

SELECT DISTINCT
MVDID,
'{"PharmacyName":"' + PharmacyName + '", "PharmacyAddress":"' +  + '", "PharmacyNumber":"' +  + '"}' Pharmacy
INTO
#PharmacyNormalized
FROM
(
	SELECT DISTINCT
	MVDID,
	PharmacyName,
	FIRST_VALUE( op.PharmacyName) OVER ( PARTITION BY op.MVDID,op.OpioidPrescriptionName
	,op.PrescriberID,op.PrescriberName,op.PharmacyName,op.DrugStrengthUnitOfMeasure
	,op.RefillsAuthorizedCount,op.NDCCode
	ORDER BY op.MVDID ) CareFlowRuleId,
	ROW_NUMBER() OVER ( PARTITION BY op.PharmacyName ORDER BY op.MVDID ) rownum
	FROM #OpioidPrescription op
) PP
WHERE
-- Get the CareFlow Rules. This is simply the lowest rownum
PP.rownum = 1

CREATE INDEX IX_PharmacyNormalized ON #PharmacyNormalized( MVDID );

DROP TABLE IF EXISTS #PharmacyRule;

;WITH PharmacyCTE
(
	MVDID,
	Pharmacy
)
AS
(
	SELECT DISTINCT
	pd.MVDID,
	STUFF
	(
		(
			SELECT
			',' + pdn.Pharmacy
			FROM
			#PharmacyNormalized pdn
			WHERE
			pdn.MVDID = pd.MVDID
			ORDER BY
			pd.MVDID,
			pd.Pharmacy
			FOR XML PATH( '' )
		), 1, 1, ''
	) AS PharmacySerialized
	FROM
	#PharmacyNormalized pd
)
SELECT
MVDID,
CASE
WHEN Pharmacy IS NULL THEN NULL
ELSE CONCAT( '[', Pharmacy, ']' )
END Pharmacy
INTO
#PharmacyRule
FROM
PharmacyCTE;

CREATE INDEX IX_PharmacyRule ON #PharmacyRule( MVDID );

/*************************************
MAIN Query
*************************************/
	 INSERT INTO
	 ABCBS_ReferralToNewDirections_Form
	(
		MVDID,
		FormDate,
		FormAuthor,
		CaseID,
		Actions,
		q2MemFirstName,
		q2MemLastName,
		qDOB1,
		MemID,
		phoneNumber,
		DaytimePhone,
		CallPhoneNumber,
		qEmail,
		Addr1,
		Addr2,
		Addr3,
		AltAddr1,
		AltAddr2,
		AltAddr3,
		qMemberGuardian,
		qGuardiansName,
		q1RefDate,
		q1RefTo,
		q1RefFrom,
		q2UrgentReview,
		q3ReferralSource,
		qCareFlowRule,
		q1CareFlowRule,
		q2CareFlowRule,
		q3CareFlowRule,
		q4CareFlowRule,
		q5CareFlowRule,
		q6CareFlowRule,
		q7CareFlowRule,
		q8CareFlowRule,
		q9CareFlowRule,
		q10CareFlowRule,
		q11CareFlowRule,
		q12CareFlowRule,
		q3OtherReferral,
		q3ABCBSReferral1,
		q3BHReferral,
		q3BHReferral1,
		q3BHReferral2,
		q3BHReferral3,
		q4CaseManager,
		q5CaseManagerPhone,
		q5CaseManageremail,
		q6ReqRefRecipient,
		q8Notes,
		q9DiscussedBH,
		qContactDiscussed,
		q10CallfromABCBSCM,
		q10CallfromNewDir,
		q10CallfromABCBSDietitian,
		q10CallfromABCBSPharmacy,
		q10CallfromABCBSSW,
		q11BestTimeToCallMember,
		qReasonReferral,
		qOtherReferral,
		qDetailedReason,
		q28MedHistory,
		q27memberPregnant,
		q27DueDate,
		q27OBProvider,
		q27SubstanceAbuse,
		q27Substances,
		q27ReferredFor,
		q27PCPRecord,
		q27CurrentTreatingPCP,
		LoadDate,
		LastModifiedDate,
		IsLocked
	)

SELECT DISTINCT

	Ref.MVDID,
	getDate() FormDate,
	'SYSTEM' FormAuthor,
	NULL CaseID,
	NULL Actions,
	MPD.MemberFirstName q2MemFirstName,
	MPD.MemberLastName q2MemLastName,
	MPD.DateOfBirth qDOB1,
	MPD.MemberID MemID,
	MPD.HomePhone phoneNumber,
	MPD.WorkPhone DaytimePhone,
	ISNULL( MPD.HomePhone, MPD.WorkPhone ) CallPhoneNumber,
	MPD.Email qEmail,
	MPD.Address1 Addr1,
	MPD.Address2 Addr2,
	NULL Addr3,
	NULL AltAddr1,
	NULL AltAddr2,
	NULL AltAddr3,
	NULL qMemberGuardian,
	NULL qGuardiansName,
	getDate() q1RefDate,
	'NewDirections' q1RefTo,
	'ABCBS' q1RefFrom,
	NULL q2UrgentReview,
	'CareFlowRule' q3ReferralSource,
	cfr.CareFlow qCareFlowRule,
	opiod.Prescription q1CareFlowRule,
	Behavior.DX q2CareFlowRule,
	PrimaryDiag.DX q3CareFlowRule,
	Pain.DX q4CareFlowRule,
	Prescriber.Prescriber q5CareFlowRule,
	SDOH.SDOH q6CareFlowRule,
	Chronic.DX q7CareFlowRule,
	PP.Prescription q8CareFlowRule,
	ERVisits.ERVisit q9CareFlowRule,
	ERDates.ERDateofService q10CareFlowRule,
	ERDetail.ERDetails q11CareFlowRule,
	Pharmacy.Pharmacy q12CareFlowRule,
	NULL q3OtherReferral,
	NULL q3ABCBSReferral1,
	NULL q3BHReferral,
	NULL q3BHReferral1,
	NULL q3BHReferral2,
	NULL q3BHReferral3,
	NULL q4CaseManager,
	NULL q5CaseManagerPhone,
	NULL q5CaseManageremail,
	NULL q6ReqRefRecipient,
	NULL q8Notes,
	NULL q9DiscussedBH,
	NULL qContactDiscussed,
	NULL q10CallfromABCBSCM,
	NULL q10CallfromNewDir,
	NULL q10CallfromABCBSDietitian,
	NULL q10CallfromABCBSPharmacy,
	NULL q10CallfromABCBSSW,
	NULL q11BestTimeToCallMember,
	'CareFlowRule' qReasonReferral,
	NULL qOtherReferral,
	NULL qDetailedReason,
	NULL q28MedHistory,
	NULL q27memberPregnant,
	NULL q27DueDate,
	NULL q27OBProvider,
	NULL q27SubstanceAbuse,
	NULL q27Substances,
	NULL q27ReferredFor,
	NULL q27PCPRecord,
	NULL q27CurrentTreatingPCP,
	getDate() LoadDate,
	getDate() LastModifiedDate,
	NULL IsLocked
	FROM
	#NDBHMember_Final Ref with (readuncommitted)
	JOIN FinalMember (readuncommitted) MPD
		ON MPD.MVDID = Ref.MVDID
	LEFT JOIN #CFRule (readuncommitted) cfr
		ON cfr.MVDID = MPD.MVDID
	LEFT JOIN #OpioidRule (readuncommitted) opiod
		ON opiod.MVDID = MPD.MVDID
	LEFT JOIN #BehaviorDiagnosis (readuncommitted) Behavior
		ON Behavior.MVDID = MPD.MVDID
	LEFT JOIN #PrimaryDiagnosis (readuncommitted) PrimaryDiag
	    ON PrimaryDiag.MVDID = MPD.MVDID
	LEFT JOIN #PainDiagnosis (readuncommitted) Pain
		ON Pain.MVDID = MPD.MVDID
	LEFT JOIN #PrescriberRule (readuncommitted) Prescriber
		ON Prescriber.MVDID = MPD.MVDID
	LEFT JOIN #SDOHRule (readuncommitted) SDOH
		ON SDOH.MVDID = MPD.MVDID
	LEFT JOIN #ChronicDiagnosis (readuncommitted) Chronic
		ON Chronic.MVDID = MPD.MVDID
	LEFT JOIN #PsychoPrescription (readuncommitted) PP
		ON PP.MVDID = MPD.MVDID
	LEFT JOIN #ERVisitRule (readuncommitted) ERVisits
		ON ERVisits.MVDID = MPD.MVDID
	LEFT JOIN #ERDateofServiceRule (readuncommitted) ERDates
		ON ERDates.MVDID = MPD.MVDID
	LEFT JOIN #ERDetailsRule (readuncommitted) ERDetail
		ON ERDetail.MVDID = MPD.MVDID
	LEFT JOIN #PharmacyRule (readuncommitted) Pharmacy
		ON Pharmacy.MVDID = MPD.MVDID

/*********************
Create HP Alert Note
*********************/
    DECLARE @p_PrintOnlyYN bit = 0
	DECLARE @v_form_id bigint;
	DECLARE @v_mvdid nvarchar(255);
	DECLARE @v_member_id nvarchar(255);
	DECLARE @v_task_exists_yn bit = 0;
	DECLARE @ReferralTo nvarchar(255) 
	DECLARE @v_owner nvarchar(255) = 'NDBH';
	DECLARE @v_form_type nvarchar(255) = 'ABCBS_ReferraltoNewDirections';
	DECLARE @v_note nvarchar(255) = 'ABCBS and New Directions Referral Form Saved.';
	DECLARE @v_code_type nvarchar(255) = 'NoteType';
	DECLARE @v_label nvarchar(255) = 'DocumentNote';
	DECLARE @v_hp_alert_note_id bigint;

	--Get list of forms to process
	DECLARE form_cursor
	CURSOR FOR
	SELECT
	ID,
	MVDID,
	MemID,
	q1RefTo
	FROM
	ABCBS_ReferraltoNewDirections_Form
	WHERE
	LoadDate IS NOT NULL
	AND FormAuthor = 'SYSTEM';

	OPEN form_cursor;
  --Get the first record from the cursor
	FETCH NEXT FROM form_cursor INTO
		@v_form_id,
		@v_mvdid,
		@v_member_id,
		@ReferralTo;

	WHILE @@FETCH_STATUS = 0
	BEGIN
   --Iterate through the records
		SET @v_task_exists_yn = 0;

		IF ( @v_task_exists_yn = 0 )
		BEGIN
   --Process the form
			BEGIN TRANSACTION

			IF ( @p_PrintOnlyYN = 0 )
			BEGIN
   --Create the HP alert note
				EXEC Set_HPAlertNoteForForm
					@MVDID = @v_mvdid,
					@Owner = @v_owner,
					@Note = @v_note,
					@FormID = @v_form_type,
					@MemberFormID = @v_form_id,
					@StatusID = 0,
					@CodeType = @v_code_type,
					@Label = @v_label,
					@Result = @v_hp_alert_note_id;
			END
			ELSE
			BEGIN
				PRINT CONCAT( 'About to create HP alert note for MVDID = ', @v_mvdid, ' and ND form ID = ', @v_form_id, '.' );
			END;

	 		COMMIT TRANSACTION;
	END;

   --Get the next record from the cursor
		FETCH NEXT FROM form_cursor INTO
			@v_form_id,
			@v_mvdid,
			@v_member_id,
			@ReferralTo;
	END;

	CLOSE form_cursor;
	DEALLOCATE form_cursor;

END