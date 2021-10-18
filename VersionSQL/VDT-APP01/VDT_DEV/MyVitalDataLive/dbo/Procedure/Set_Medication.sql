/****** Object:  Procedure [dbo].[Set_Medication]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Set_Medication]

	@ICENUMBER varchar(15),
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
	@CreatedBy nvarchar(250) = NULL,
	@UpdatedBy nvarchar(250) = NULL,
	@UpdatedByContact nvarchar(256) = NULL,
	@Organization nvarchar(64) = NULL

AS

SET NOCOUNT ON

INSERT INTO MainMedication (ICENUMBER, StartDate, StopDate, RefillDate, PrescribedBy,
	DrugId, RxDrug, RxPharmacy, Strength, HowMuch, Route, HowOften, WhyTaking, CreationDate, 
	ModifyDate,ApproxDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByContact,UpdatedByOrganization) 
VALUES (@IceNumber, @StartDate, @StopDate, @RefillDate, @PrescribedBy,
	@DrugId, @RxDrug, @RxPharmacy, @Strength, @HowMuch, @Route, @HowOften, @WhyTaking,
	GETUTCDATE(), GETUTCDATE(),@ApproxDate,@CreatedBy,@Organization,@UpdatedBy,@UpdatedByContact,@Organization)