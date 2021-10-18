/****** Object:  Procedure [dbo].[Rpt_MemberEdVisitHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[Rpt_MemberEdVisitHistory]
(
	@IceNumber VARCHAR (20),
	@ReportType VARCHAR (15) = NULL 
)
AS  
BEGIN
	SET NOCOUNT ON  
  
	DECLARE @v_customer_id bigint;
	DECLARE @v_limit_date date;
	DECLARE @v_total_amount_paid decimal(18,2);


	DROP TABLE IF EXISTS
	#CMEH;

	SELECT
	@v_customer_id = MAX( CustID )
	FROM
	FinalMember
	WHERE
	MVDID = @IceNumber;

	IF ( ISNULL( @ReportType, '' ) != '' AND @ReportType = '21' )  
	BEGIN
		 SET @v_limit_date = DATEADD( YEAR, -1, GetDate() );
	END
	ELSE
	BEGIN
		SET @v_limit_date = '1/1/1900';
	END;
  
	SELECT
	fch.StatementFromDate VisitDate,
	fp.BusinessName FacilityName,
	fp.ProviderFirstName PhysicianFirstName,
	fp.ProviderLastName PhysicianLastName,
	dbo.fnInitCap( ISNULL( fp.ProviderFirstName, '' ) + ISNULL( fp.ProviderLastName, '' ) ) PhysicianFullName,
	dbo.fnFormatPhone( fp.ServicePhone ) PhysicianPhone,
	CASE
	WHEN ISNULL( fch.AdmissionDate, '' ) <> '' THEN 'Y'
	ELSE 'N'
	END IsHospitalAdmit,
	NULL ChiefComplaint,
	NULL Notes, -- take this from EMSNote table WHEN available
	'ABCBS : Claims' Source,
	pos.Name POS,
	NULL Specialty, -- take this from LookUpNPI Custom WHEN available
	CASE
	WHEN fch.EmergencyIndicator = 1 THEN 'ER'
	WHEN CAST( ISNULL( fch.AttendingProviderNPI, fch.RenderingProviderNPI ) AS varchar(10) ) = CAST( fe.PCPNPI AS varchar(10) ) THEN 'PHYSICIAN'
	ELSE 'OTHER'
	END VisitType,
	fch.TotalPaidAmount -- Legacy Code does not address this field. It remains null
	INTO
	#CMEH
	FROM
	FinalClaimsHeader fch
	OUTER APPLY
	(
		SELECT TOP 1 *
		FROM
		FinalProvider p
		WHERE
		p.NPI = fch.RenderingProviderNPI
		ORDER BY
		p.AffiliationEffectiveDate DESC
	) fp
	OUTER APPLY
	(
		SELECT TOP 1 *
		FROM
		FinalEligibility e
		WHERE
		e.MVDID = fch.MVDID
		AND e.MemberEffectiveDate <= fch.StatementFromDate
		ORDER BY
		MemberEffectiveDate DESC
	) fe
	LEFT OUTER JOIN LookupPOS pos
	ON pos.ID = fch.PlaceOfService
	WHERE
	fch.CustID = @v_customer_id
	AND fch.MVDID = @IceNumber
	AND fch.StatementFromDate >= @v_limit_date
	ORDER BY
	fch.StatementFromDate DESC;

	SELECT DISTINCT 
	CONVERT( varchar(10), VisitDate, 101 ) VisitDate,
	CAST( ISNULL( FacilityName, dbo.fnInitCap( ISNULL( PhysicianFirstName + ' ', '' ) + ISNULL( PhysicianLastName, '' ) ) ) AS nvarchar(max) ) FacilityName,
	CAST( PhysicianFirstName AS nvarchar(50) ) PhysicianFirstName,
	CAST( PhysicianLastName AS nvarchar(50) ) PhysicianLastName,
	CAST( dbo.fnInitCap( ISNULL( PhysicianFirstName + ' ', '' ) + ISNULL( PhysicianLastName, '' ) ) AS nvarchar(max) ) PhysicianFullName,
	CAST( PhysicianPhone AS varchar(100) ) PhysicianPhone,
	CAST( IsHospitalAdmit AS varchar(1) ) IsHospAdmit,
	CAST( ChiefComplaint AS nvarchar(100) ) ChiefComplaint,
	CAST( NULL AS nvarchar(1000) ) Notes, -- take this from EMSNote table when available
	CAST( [source] AS nvarchar(50) ) [source],
	POS,
	CAST( NULL AS varchar(100) ) Specialty, -- take this from LookUpNPI Custom when available
	CAST( VisitType AS varchar(50) ) VisitType,
	SUM( CAST ( TotalPaidAmount AS decimal(18,2) ) ) TotalAmountPaid -- Legacy Code does not address this field. It remains null
	FROM
	#CMEH
	GROUP BY
	VisitDate,
	FacilityName,
	PhysicianFirstName,
	PhysicianLastName,
	PhysicianFullName,
	PhysicianPhone,
	IsHospitalAdmit,
	ChiefComplaint,
	[Source],
	POS,
	Specialty,
	VisitType
	ORDER BY
	VisitDate DESC;

END;