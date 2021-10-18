/****** Object:  Procedure [dbo].[Upd_Medication]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Upd_Medication]

	@RecNum int,
	@StartDate datetime,
	@StopDate datetime,
	@RefillDate datetime = NULL,
	@PrescribedBy varchar(50),
	@DrugId varchar(1),
	@RxDrug varchar(50),
	@RxPharmacy varchar(50),
	@Strength varchar(50) = NULL,
	@HowMuch varchar(50),
	@Route varchar(50) = NULL,
	@HowOften varchar(50),
	@WhyTaking varchar(50),
	@ApproxDate bit,
	@UpdatedBy nvarchar(250) = NULL,
	@UpdatedByContact nvarchar(256) = NULL,
	@Organization nvarchar(64) = NULL

AS

SET NOCOUNT ON

UPDATE MainMedication
SET
	StartDate = @StartDate, 
	StopDate = @StopDate, 
	RefillDate = @RefillDate,
	PrescribedBy = @PrescribedBy,
	DrugId = @DrugId, 
	RxDrug = @RxDrug, 
	RxPharmacy = @RxPharmacy, 
	Strength = @Strength,
	HowMuch = @HowMuch, 
	Route = @Route,
	HowOften = @HowOften, 
	WhyTaking = @WhyTaking, 
	ModifyDate = GETUTCDATE(),
	ApproxDate =@ApproxDate,
	UpdatedBy =@UpdatedBy,
	UpdatedByContact = @UpdatedByContact,
	UpdatedByOrganization=@Organization
WHERE RecordNumber = @RecNum