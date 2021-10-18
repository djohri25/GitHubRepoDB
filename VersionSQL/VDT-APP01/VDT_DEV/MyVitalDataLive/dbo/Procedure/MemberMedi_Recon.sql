/****** Object:  Procedure [dbo].[MemberMedi_Recon]    Committed by VersionSQL https://www.versionsql.com ******/

/*===================================================================================
change:  ticket 3625
author: luna
date: 0916
cast(mm.MetricDecimalQuantity as varchar(50)) as HowMuch,
example: execute dbo.memberMedi_Recon '161FA17EB4DEDB286CCD','1',16
======================================================================================*/

CREATE PROCEDURE
[dbo].[MemberMedi_Recon]
--Declare
	@ICENUMBER varchar(30),
	@ReportType varchar(15) = null,
	@CustomerID int = 16
AS
BEGIN
-- Relax constraint on 6 months of history - MEG 5/15/20
SET NOCOUNT ON

-- Exec dbo.MemberMedi_Recon '168557779789'

	declare @limitDate datetime

	declare @tempMed table
	(
		typeName varchar(50),
		[StartDate] [datetime],
		[StopDate] [datetime],
		[RefillDate] [datetime],
		timesrefilled int,
		[PrescribedBy] [varchar](50),
		[RxDrug] [varchar](100) NULL,
		[RxPharmacy] [varchar](100) NULL,
		[HowMuch] [varchar](50) NULL,
		[HowOften] [varchar](50) NULL,
		[WhyTaking] [varchar](50) NULL,
		[CreatedBy] [nvarchar](250) NULL,
		[CreatedByOrganization] [varchar](250) NULL,
		[UpdatedBy] [nvarchar](250) NULL,
		[UpdatedByOrganization] [varchar](250) NULL,
		[UpdatedByContact] varchar(50),
		[PlanPaidAmount] decimal(18,2), 
		[NDC] varchar(25),
		[DaysSupply] int,
		[Strength] varchar(50),
		[Source] varchar(1)
	);

	if ( len( isnull( @ReportType, '' ) ) > 0 and @ReportType = '21' )
	begin
		set @limitDate = DATEADD(dd,-120, getdate())
	end
	else
	begin
		set @limitDate = '1/1/1900'
	end

-- We need to sort by refill date, so if blank then set it to start date

	insert into
	@tempMed
	(
		typeName,
		[StartDate],
		[StopDate],
		[RefillDate],
		timesrefilled,
		[PrescribedBy],
		[RxDrug],
		[RxPharmacy],
		[HowMuch],
		[HowOften],
		[WhyTaking],
		[CreatedBy],
		[CreatedByOrganization],
		[UpdatedBy],
		[UpdatedByOrganization],
		[UpdatedByContact],
		[NDC],
		[DaysSupply],
		[Strength],
		[Source],
		[PlanPaidAmount]
	)
	SELECT
--	(SELECT DrugName FROM LookupDrugType WHERE LookupDrugType.DrugId = mm.DrugTier) as TypeName,
	ldt.DrugName as TypeName,
	NULL as StartDate,
--	isnull(mm.ServiceDate,mm.WrittenDate) as StartDate, 
	NULL as StopDate, 
	isnull(mm.ServiceDate,mm.WrittenDate) as [RefillDate],
/*
	(
-- Newly created med is not considered "Refill", so subtract 1
-- If history record not created return 0
		select
		case count(RecordNumber)
		when 0 then 0
		else count(RecordNumber) - 1 
		end
		from MainMedicationHistory mh
		where mh.IceNumber = mm.MVDID and mh.RxDrug = mm.DrugProductName
	) as TimesRefilled,
*/
	mmh.num TimesRefilled,
	dbo.fnInitCap(mm.PrescriberName) as PrescribedBy, 
	dbo.fnInitCap( ISNULL( mm.DrugProductName, mm.GenericProductName ) ) as RxDrug, 
	dbo.fnInitCap(mm.PharmacyName) as RxPharmacy,
	cast(mm.MetricDecimalQuantity as varchar(50)) as HowMuch,
	NULL as HowOften,
	NULL as WhyTaking,
	NULL as CreatedBy,
	NULL as CreatedByOrganization,
	NULL as UpdatedBy,
	NULL as UpdatedByOrganization,
	NULL as UpdatedByContact,
	mm.NDCCode,
	CASE WHEN IsNumeric( mm.DaysSupply ) = 1 THEN mm.DaysSupply ELSE 0 END,
	mm.DrugStrength,
	'C' as [Source], -- from claims
	SUM(pp.PlanPaidAmount) as PlanPaidAmount
	FROM FinalRx mm
	LEFT JOIN MainMedicationPayments pp
	ON mm.ClaimNumber = pp.RXClaimNumber
	LEFT JOIN LookupDrugType ldt
	ON ldt.DrugId = mm.DrugTier
	OUTER APPLY
	(
		SELECT
		case count(mh.RecordNumber)
		when 0 then 0
		else count(mh.RecordNumber) - 1 
		end num
		FROM
		MainMedicationHistory mh
		where
		mh.IceNumber = mm.MVDID
		and mh.RxDrug = ISNULL( mm.DrugProductName, mm.GenericProductName )
	) mmh
	WHERE
	mm.MVDID = @ICENUMBER
	AND CustID = 16
	GROUP BY
	ldt.DrugName,
	mm.MVDID,
	ISNULL( mm.DrugProductName, mm.GenericProductName ),
	mm.ServiceDate,
	mm.WrittenDate,
	mmh.num,
	mm.PrescriberName,
	mm.PharmacyName,
	mm.NDCCode,
	DaysSupply,
	mm.DrugStrength,
	mm.DrugTier, 
	mm.MetricDecimalQuantity
	union
	select ' + ' AS TypeName,
	RxStartDate as StartDate,
	null as StopDate,
	RxStartDate as RefillDate,
	1 as TimesRefilled,
	dbo.fnInitCap(PrescribedBy) as PrescribedBy, 
	dbo.fnInitCap(RxDrug) as RxDrug, 
	dbo.fnInitCap(RxPharmacy) as RxPharmacy,
	HowMuch,
	HowOften,
	WhyTaking,
	dbo.fnInitCap(ISNULL(CreatedBy,'')) as CreatedBy,
	'' as CreatedByOrganization,
	'' as UpdatedBy,
	'' as UpdatedByOrganization,
	'Member' as UpdatedByContact,
	NDC as Code,
	CASE WHEN IsNumeric( DaysSupply ) = 1 THEN DaysSupply ELSE 0 END DaysSupply,
	DrugStrength as Strength,
	'M' as [Source], -- Member supplied
	null as PlanPaidAmount
	from MainMemberMed mmm
	WHERE mmm.MVDID = @ICENUMBER;

	select typeName,
	StartDate,
	StopDate,
	RefillDate,
	timesrefilled,
	PrescribedBy,
	RxDrug,
	RxPharmacy,
	HowMuch,
	HowOften,
	WhyTaking,
	CreatedBy,
	CreatedByOrganization,
	UpdatedBy,
	UpdatedByOrganization,
	UpdatedByContact,
	PlanPaidAmount,
	NDC,
	DaysSupply,
	Strength,
	[Source]
	from @tempMed
	ORDER BY refilldate desc;

END;