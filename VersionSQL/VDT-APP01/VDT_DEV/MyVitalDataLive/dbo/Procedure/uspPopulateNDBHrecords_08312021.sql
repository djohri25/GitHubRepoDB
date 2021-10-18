/****** Object:  Procedure [dbo].[uspPopulateNDBHrecords_08312021]    Committed by VersionSQL https://www.versionsql.com ******/

/* =============================================
Author:	Deepank Johri
Create date: 08-12-2021
Description:	Populate New Directions data based on requirements from NDBH
Example: EXEC dbo.uspPopulateNDBHrecords_08312021 

Modifications
Date			Name			Comments	
08/12/2021      Deepank         Initial Version
08/30/2021		Deepank, Ed		Added All 13 JSON fields
============================================= */
CREATE PROCEDURE [dbo].[uspPopulateNDBHrecords_08312021]

AS
BEGIN

SET NOCOUNT ON;

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
) CF
JOIN [dbo].[ABCBS_ReferraltoNewDirections_Form] Ref with (readuncommitted)
ON CF.MVDID = Ref.MVDID
AND Ref.LoadDate > GETDATE() - 100
AND (Ref.q2MemFirstName IS NOT NULL OR Ref.q2MemFirstName != '')
AND (Ref.q2MemLastName IS NOT NULL OR Ref.q2MemLastName != '')
AND (Ref.MemID IS NOT NULL OR Ref.MemID != '')
AND Ref.FormAuthor IS NOT NULL
WHERE
-- Get the CareFlow Rules. This is simply the lowest rownum
CF.rownum = 1

CREATE INDEX IX_CareFlowNormalized ON #CareFlowNormalized( MVDID );


DROP TABLE IF EXISTS #CareFlow;

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
	JOIN [dbo].[ABCBS_ReferraltoNewDirections_Form] Ref1 with (readuncommitted)
	ON Rx.MemberID = Ref1.MemID
	 WHERE (ClaimStatus = '1' OR ClaimStatus IS NULL) 	           --> 
	 AND PaidAmount >= 0										   --> 
	 AND CAST(DaysSupply AS float) > 0                          --> Same as the filter in generating main Rx features 
	 AND LOB IN ('US', 'BH', 'BC', 'BX', 'HA')          -->
	 AND DATEDIFF( DAY, ServiceDate, GetUTCDate() ) <= 365
	 AND Ref1.LoadDate > GETDATE() - 100
	 AND (Ref1.q2MemFirstName IS NOT NULL OR Ref1.q2MemFirstName != '')
	AND (Ref1.q2MemLastName IS NOT NULL OR Ref1.q2MemLastName != '')
	AND (Ref1.MemID IS NOT NULL OR Ref1.MemID != '')
	AND Ref1.FormAuthor IS NOT NULL
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
'{"PrescriptionName":"' + OpioidPrescriptionName + '", "MetricDecimalQuantity":"' + CONVERT(VARCHAR(10),MetricDecimalQuantity) + '", "UOM":"' + DrugStrengthUnitOfMeasure + '", "RefillAuthorizedCount:"' + CONVERT(VARCHAR(5),RefillsAuthorizedCount ) + '", "NDC:"' + NDCCode + '"}' Opioid
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
--and fch.MVDID = '16FFBE96B44D0892AB18'

CREATE INDEX IX_OpioidPrescriptionNormalized ON #OpioidNormalized( MVDID );

--SELECT * FROM #OpioidNormalized;

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
JOIN [dbo].[ABCBS_ReferraltoNewDirections_Form] Ref with (readuncommitted)
ON fch.MemberID = Ref.MemID
AND Ref.LoadDate > GETDATE() - 100
AND (Ref.q2MemFirstName IS NOT NULL OR Ref.q2MemFirstName != '')
AND (Ref.q2MemLastName IS NOT NULL OR Ref.q2MemLastName != '')
AND (Ref.MemID IS NOT NULL OR Ref.MemID != '')
AND Ref.FormAuthor IS NOT NULL
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
JOIN [dbo].[ABCBS_ReferraltoNewDirections_Form] Ref with (readuncommitted)
ON fch.MemberID = Ref.MemID
AND Ref.LoadDate > GETDATE() - 100
AND (Ref.q2MemFirstName IS NOT NULL OR Ref.q2MemFirstName != '')
AND (Ref.q2MemLastName IS NOT NULL OR Ref.q2MemLastName != '')
AND (Ref.MemID IS NOT NULL OR Ref.MemID != '')
AND Ref.FormAuthor IS NOT NULL
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
JOIN [dbo].[ABCBS_ReferraltoNewDirections_Form] Ref with (readuncommitted)
ON fch.MemberID = Ref.MemID
AND Ref.LoadDate > GETDATE() - 100
AND (Ref.q2MemFirstName IS NOT NULL OR Ref.q2MemFirstName != '')
AND (Ref.q2MemLastName IS NOT NULL OR Ref.q2MemLastName != '')
AND (Ref.MemID IS NOT NULL OR Ref.MemID != '')
AND Ref.FormAuthor IS NOT NULL
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

DROP TABLE IF EXISTS #Prescriber;

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
'{"CompositionDisability":"' + CONVERT(VARCHAR(5),SDOH_Vulnerable_HH_ComposiitonDisability) + '", "Language":"' + CONVERT(VARCHAR(5),SDOH_Vulnerable_Language) + '", "OverAll":"' + CONVERT(VARCHAR(5),SDOH_Vulnerable_OverAll) + '", "Socioeconomic":"' + CONVERT(VARCHAR(5),SDOH_Vulnerable_Socioeconomic) + '", "Transportation":"' + CONVERT(VARCHAR(5),SDOH_Vulnerable_Transportation) + '"}' SDOH
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
JOIN [dbo].[ABCBS_ReferraltoNewDirections_Form] Ref with (readuncommitted)
ON PP.MVDID = Ref.MVDID
WHERE Ref.LoadDate > GETDATE() - 100
AND (Ref.q2MemFirstName IS NOT NULL OR Ref.q2MemFirstName != '')
AND (Ref.q2MemLastName IS NOT NULL OR Ref.q2MemLastName != '')
AND (Ref.MemID IS NOT NULL OR Ref.MemID != '')
AND Ref.FormAuthor IS NOT NULL
AND
-- Get the CareFlow Rules. This is simply the lowest rownum
PP.rownum = 1

CREATE INDEX IX_SDOHNormalized ON #SDOHNormalized( MVDID );

DROP TABLE IF EXISTS #SDOH;

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
JOIN [dbo].[ABCBS_ReferraltoNewDirections_Form] Ref with (readuncommitted)
ON fch.MemberID = Ref.MemID
AND Ref.LoadDate > GETDATE() - 100
AND (Ref.q2MemFirstName IS NOT NULL OR Ref.q2MemFirstName != '')
AND (Ref.q2MemLastName IS NOT NULL OR Ref.q2MemLastName != '')
AND (Ref.MemID IS NOT NULL OR Ref.MemID != '')
AND Ref.FormAuthor IS NOT NULL
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

JOIN [dbo].[ABCBS_ReferraltoNewDirections_Form] Ref with (readuncommitted)
ON RXCode.MVDID = Ref.MVDID
AND Ref.LoadDate > GETDATE() - 100
AND (Ref.q2MemFirstName IS NOT NULL OR Ref.q2MemFirstName != '')
AND (Ref.q2MemLastName IS NOT NULL OR Ref.q2MemLastName != '')
AND (Ref.MemID IS NOT NULL OR Ref.MemID != '')
AND Ref.FormAuthor IS NOT NULL
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
		JOIN [dbo].[ABCBS_ReferraltoNewDirections_Form] Ref2 with (readuncommitted)
		ON fch.MVDID = Ref2.MVDID
		WHERE DATEDIFF( DAY, AdmissionDate, GetUTCDate() ) <= 365
        AND EmergencyIndicator = 1 
		AND Ref2.LoadDate > GETDATE() - 100
		AND (Ref2.q2MemFirstName IS NOT NULL OR Ref2.q2MemFirstName != '')
		AND (Ref2.q2MemLastName IS NOT NULL OR Ref2.q2MemLastName != '')
		AND (Ref2.MemID IS NOT NULL OR Ref2.MemID != '')
		AND Ref2.FormAuthor IS NOT NULL
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

DROP TABLE IF EXISTS #ERVisit;

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

DROP TABLE IF EXISTS #ERDateofService;

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

DROP TABLE IF EXISTS #ERDetails;

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

DROP TABLE IF EXISTS #Pharmacy;

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

SELECT 
	  'I' AS [Actions]
	  ,CASE WHEN MPD.LOB != 'MA' THEN LTRIM(RTRIM(left([MemID], len([MemID]) -2))) ELSE [MemID] END AS [Member Contract Number]
      ,CASE WHEN MPD.LOB = 'MA' THEN '01' ELSE RIGHT([MemID], 2) END AS [Member Suffix ID Number]
	  ,MPD.LOB
      ,[q2MemFirstName] AS [Member First Name]	
      ,[q2MemLastName] AS [Member Last Name]
	  ,MPD.Gender AS [Member Gender]
	  ,convert(varchar(10),convert(date,[qDOB1]),101) AS [Member DOB]
	  ,convert(varchar,FormDate,101) AS [Create Date]
      ,Ref.[phoneNumber] AS [Member Home Phone Number]
      ,LTRIM(RTRIM([DaytimePhone])) AS [Member Daytime Phone Number]
      ,LTRIM(RTRIM([CallPhoneNumber])) AS [Member Cell Phone Number]
      ,[qEmail] AS [Member Email]
      ,REPLACE([Addr1] + ' ' + [Addr2] + ' ' + [Addr3],'!','') AS [Member Address]
      ,LTRIM(RTRIM(REPLACE([AltAddr1] + ' ' + [AltAddr2] + ' ' + [AltAddr3],'!',''))) AS [Member Alternate Address]
      ,[qMemberGuardian] AS [Does member have a guardian]
      ,REPLACE([qGuardiansName],'!','') AS [Guardians (Name and phone number)]
      ,convert(varchar,[q1RefDate],101) AS [Referral date]
      ,[q1RefTo] AS [Referral to (Recipient)]
      ,[q1RefFrom] AS [Referral from (Sender)]
      ,[q2UrgentReview] AS [Urgent review needed]
      ,[q3ReferralSource] AS [Referral Source]
	  ,CASE WHEN Ref.FormAuthor = 'System' THEN NULL
        ELSE cfr.CareFlow END CareFlowRule
	  ,CASE WHEN Ref.FormAuthor = 'System' THEN NULL
        ELSE opiod.Prescription END OpiodPrescription
	  ,CASE WHEN Ref.FormAuthor = 'System' THEN NULL
        ELSE Behavior.DX END BehaviorDiagnosis
	  ,CASE WHEN Ref.FormAuthor = 'System' THEN NULL
        ELSE PrimaryDiag.DX END PrimaryDiagnosis
	  ,CASE WHEN Ref.FormAuthor = 'System' THEN NULL
        ELSE Pain.DX  END PainDiagnosis
	  ,CASE WHEN Ref.FormAuthor = 'System' THEN NULL
        ELSE Prescriber.Prescriber END Prescriber
	  ,CASE WHEN Ref.FormAuthor = 'System' THEN NULL
        ELSE SDOH.SDOH END SDOHFactors
	  ,CASE WHEN Ref.FormAuthor = 'System' THEN NULL
        ELSE Chronic.DX END ChronicDiagnosis
	  ,CASE WHEN Ref.FormAuthor = 'System' THEN NULL
        ELSE PP.Prescription END PsychotropicPrescription
	  ,CASE WHEN Ref.FormAuthor = 'System' THEN NULL
        ELSE ERVisits.ERVisit  END ERVisits
	  ,CASE WHEN Ref.FormAuthor = 'System' THEN NULL
        ELSE ERDates.ERDateofService END ERDates
	  ,CASE WHEN Ref.FormAuthor = 'System' THEN NULL
        ELSE ERDetail.ERDetails END ERDetails
	  ,CASE WHEN Ref.FormAuthor = 'System' THEN NULL
        ELSE Pharmacy.Pharmacy END Pharmacy

      ,LTRIM(RTRIM([q3OtherReferral])) AS [If other referral source, please explain]
      ,[q3ABCBSReferral1] AS [Is member currently open in ABCBS case management]
      ,LTRIM(RTRIM([q3BHReferral])) AS [Is member currently open in NDBH case management]
      ,LTRIM(RTRIM([q3BHReferral1])) AS [Member is currently engaged in]
      ,LTRIM(RTRIM(REPLACE([q3BHReferral2],'!',''))) AS [Was a GAP addressed prior to this referral]
      ,LTRIM(RTRIM(REPLACE([q3BHReferral3],'!',''))) AS [If yes, please explain GAPs addressed]
      ,REPLACE(REPLACE([q4CaseManager],'~',''''),'!','') AS [Referred by (Case Manager's name)]
      ,LTRIM(RTRIM([q5CaseManagerPhone])) AS [Case Manager's Phone]
      ,[q5CaseManageremail] AS [Case Manager's email]
      ,[q6ReqRefRecipient] AS [Does Case Manager request an update from the referral recipient]
      ,REPLACE([q8Notes],'!','') AS [Notes]
      ,[q9DiscussedBH] AS [Has case management been discussed with member]
      ,[qContactDiscussed] AS [What type of case management has been discussed]
      ,[q10CallfromABCBSCM] AS [Is member expecting a call from ABCBS CM]
      ,[q10CallfromNewDir] AS [Is member expecting a call from New Directions]
      ,[q11BestTimeToCallMember] AS [When is the best time to call the Member]
      ,REPLACE(REPLACE(REPLACE([qReasonReferral], '"', ''),'[' , ''),']' , '') AS [Reason for Referral]
      ,REPLACE([qOtherReferral],'!','') AS [If other, please explain]
      ,REPLACE([qDetailedReason],'!','') AS [Please provide a detailed reason for referral, including known diagnosis, symptoms, and concerns]
      ,REPLACE([q28MedHistory],'!','') AS [Brief History]
      ,[q27memberPregnant] AS [Is Member Pregnant]
      ,convert(varchar,[q27DueDate],101) AS [Due Date]
      ,REPLACE([q27OBProvider],'!','') AS [OB Provider]
      ,[q27SubstanceAbuse] AS [Substance Abuse]
      ,REPLACE([q27Substances],'!','') AS [If yes, what substances]
      ,REPLACE([q27ReferredFor],'!','') AS [Referred for]
      ,REPLACE([q27PCPRecord],'!','') AS [PCP on Record (Name and Phone Number)]
      ,REPLACE([q27CurrentTreatingPCP],'!','') AS [Current Treating Provider if different than PCP]
	  ,CASE WHEN AspNetUsers.FirstName IS NULL THEN COALESCE(AspNetUsers.FirstName,'None') 
	  WHEN AspNetUsers.FirstName = '' THEN 'None'
	  ELSE LTRIM(RTRIM(AspNetUsers.FirstName)) END AS FirstName
	  ,CASE WHEN AspNetUsers.LastName IS NULL THEN COALESCE(AspNetUsers.LastName,'None') 
	  WHEN AspNetUsers.LastName = '' THEN 'None'
	  ELSE LTRIM(RTRIM(AspNetUsers.LastName)) END AS LastName
	  ,LEFT(newid(),8) AS [Unique ID]
	  ,ref.LoadDate
  --INTO #FinalTable
  FROM [dbo].[ABCBS_ReferraltoNewDirections_Form] Ref with (readuncommitted)
  CROSS APPLY
  (
	SELECT DISTINCT
	MemberID,
	FIRST_VALUE( MVDID ) OVER ( PARTITION BY MemberID ORDER BY CASE WHEN MVDID LIKE '%TMP' THEN 2 ELSE 1 END ) MVDID,
	FIRST_VALUE( Gender ) OVER ( PARTITION BY MemberID ORDER BY CASE WHEN MVDID LIKE '%TMP' THEN 2 ELSE 1 END ) Gender,
	LOB
	FROM
	[dbo].[FinalMember] with (readuncommitted)
	WHERE MVDID = Ref.MVDID
  )MPD
  LEFT JOIN #CFRule cfr
  ON cfr.MVDID = MPD.MVDID
  LEFT JOIN #OpioidRule opiod
  ON opiod.MVDID = MPD.MVDID
  LEFT JOIN #BehaviorDiagnosis Behavior
  ON Behavior.MVDID = MPD.MVDID
  LEFT JOIN #PrimaryDiagnosis PrimaryDiag
  ON PrimaryDiag.MVDID = MPD.MVDID
  LEFT JOIN #PainDiagnosis Pain
  ON Pain.MVDID = MPD.MVDID
  LEFT JOIN #PrescriberRule Prescriber
  ON Prescriber.MVDID = MPD.MVDID
  LEFT JOIN #SDOHRule SDOH
  ON SDOH.MVDID = MPD.MVDID
  LEFT JOIN #ChronicDiagnosis Chronic
  ON Chronic.MVDID = MPD.MVDID
  LEFT JOIN #PsychoPrescription PP
  ON PP.MVDID = MPD.MVDID
  LEFT JOIN #ERVisitRule ERVisits
  ON ERVisits.MVDID = MPD.MVDID
  LEFT JOIN #ERDateofServiceRule ERDates
  ON ERDates.MVDID = MPD.MVDID
  LEFT JOIN #ERDetailsRule ERDetail
  ON ERDetail.MVDID = MPD.MVDID
  LEFT JOIN #PharmacyRule Pharmacy
  ON Pharmacy.MVDID = MPD.MVDID
  LEFT JOIN AspNetIdentity.dbo.AspNetUsers with (readuncommitted)
  ON UserName = Ref.FormAuthor
  WHERE 
  Ref.LoadDate > GETDATE() - 100
  AND (Ref.q2MemFirstName IS NOT NULL OR Ref.q2MemFirstName != '')
  AND (Ref.q2MemLastName IS NOT NULL OR Ref.q2MemLastName != '')
  AND (Ref.MemID IS NOT NULL OR Ref.MemID != '')
  AND Ref.FormAuthor IS NOT NULL
 
  
END