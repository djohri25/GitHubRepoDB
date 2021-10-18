/****** Object:  Procedure [dbo].[Rpt_MemberMedi]    Committed by VersionSQL https://www.versionsql.com ******/

-- Returns the list of medication with start date or refill date > curDate - 120 days
CREATE PROCEDURE [dbo].[Rpt_MemberMedi]
--Declare
 	@ICENUMBER varchar(15),
	@ReportType varchar(15) = null
AS
BEGIN
SET NOCOUNT ON

--set @ICENUMBER=N'16MW824027'

declare @limitDate datetime

declare @tempMed table (
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
	[PlanPaidAmount]	decimal(18,2)

)


if(len(isnull(@ReportType,'')) > 0 and @ReportType = '21')
begin
	set @limitDate = DATEADD(dd,-120, getdate())
end
else
begin
	set @limitDate = '1/1/1900'
end


Declare @ICEGroup varchar(50)
Select @ICEGroup = IceGroup from [dbo].[MainICENUMBERGroups]
where IceNumber = @ICENUMBER

Create Table #IceNumbers (IceNumber varchar(50))
Insert #IceNumbers
Select IceNumber from [dbo].[MainICENUMBERGroups]
where IceGroup = @ICEGroup


-- We need to sort by refill date, so if blank then set it to start date

insert into @tempMed (typeName,
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
	[PlanPaidAmount])

SELECT (SELECT DrugName FROM LookupDrugType WHERE LookupDrugType.DrugId = mm.DrugId) AS TypeName,
	StartDate, 
	StopDate, 
	isnull(RefillDate,StartDate) as [RefillDate],
	(
		-- Newly created med is not considered "Refill", so subtract 1
		-- If history record not created return 0
		select case count(RecordNumber)
			when 0 then 0
			else count(RecordNumber) - 1 
			end
		from MainMedicationHistory mh
		where mh.IceNumber = mm.Icenumber and mh.RxDrug = mm.RxDrug
	) as TimesRefilled,
	dbo.InitCap(PrescribedBy) as PrescribedBy, 
	dbo.InitCap(RxDrug) as RxDrug, 
	dbo.InitCap(RxPharmacy) as RxPharmacy,
	HowMuch, HowOften, WhyTaking,
	dbo.InitCap(ISNULL(CreatedBy,'')) as CreatedBy,
	dbo.InitCap(ISNULL(CreatedByOrganization,'')) as CreatedByOrganization,
	dbo.InitCap(ISNULL(UpdatedBy,'')) as UpdatedBy,
	dbo.InitCap(ISNULL(UpdatedByOrganization,'')) as UpdatedByOrganization,
	ISNULL(UpdatedByContact,'') as UpdatedByContact,
	SUM(pp.PlanPaidAmount) as PlanPaidAmount
FROM MainMedication mm JOIN MainMedicationPayments pp ON mm.RXClaimNumber = pp.RXClaimNumber
WHERE --ICENUMBER = @ICENUMBER
mm.ICENUMBER in (Select IceNUmber From #IceNumbers)  
	AND (
		(StartDate is null and RefillDate is null)
		OR
		StartDate > @limitDate
		OR
		RefillDate > @limitDate
		)
GROUP BY mm.IceNumber, mm.DrugId, mm.RxDrug, StartDate, StopDate, RefillDate, mm.PrescribedBy, mm.RxDrug, mm.RxPharmacy, HowMuch, HowOften, WhyTaking, CreatedBy, CreatedByOrganization, UpdatedBy, UpdatedByOrganization, UpdatedByContact

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
	PlanPaidAmount
from @tempMed
ORDER BY refilldate desc


DROP TABLE #IceNumbers;


END