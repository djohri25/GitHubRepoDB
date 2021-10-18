/****** Object:  Procedure [dbo].[IceMR_MedicationUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_MedicationUpdate]  

@ICENUMBER varchar(15),
@StartDate datetime,
@StopDate datetime,
@PrescribedBy varchar(50),
@RxDrug varchar(50),
@RxPharmacy varchar(50),
@HowMuch varchar(50),
@HowOften varchar(50),
@WhyTaking varchar(50),
@DrugId varchar(1)


AS


SET NOCOUNT ON

INSERT INTO MainMedication (ICENUMBER, StartDate, StopDate, PrescribedBy, RxDrug, RxPharmacy,
DrugId, HowMuch, HowOften, WhyTaking, CreationDate, ModifyDate) 
VALUES (@ICENUMBER, @StartDate, @StopDate, @PrescribedBy, @RxDrug, @RxPharmacy,
@DrugId, @HowMuch, @HowOften, @WhyTaking, GETUTCDATE(), GETUTCDATE())