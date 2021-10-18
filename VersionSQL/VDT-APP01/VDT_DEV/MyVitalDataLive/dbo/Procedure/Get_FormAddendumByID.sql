/****** Object:  Procedure [dbo].[Get_FormAddendumByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name> FormAddendum
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================[Get_FormAddendumByID]
create PROCEDURE [dbo].[Get_FormAddendumByID]
@ID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1[ID]
      ,[MVDID]
      ,[CustID]
      ,[StaffInterviewing]
      ,[FormDate]
      ,[Gender]
      ,[DateOfBirth]
      ,[PLan]
      ,[ProviderIDNumber]
   ,
	[Grooming] ,
	[Dressing] ,
	[Bathing]  ,
	[Toileting]  ,
	[Eating]  ,
	[Laundry] ,
	[LightHousekeeping]  ,
	[Shopping],
	[MealPreparation] ,
	[UsingTheTelephone] ,
	[ManagingMedications] ,
	[ManagingPrescribedProcedures] ,
	[TransferAmbulation],
	[ManagingBarrierrs] ,
	[AlertOriented],
	[RequiresPrompting] ,
	[RequiresAssistance],
	[RequiresAssistanceInRoutine] ,
	[TotallyDependent] ,
	[Beliefs] ,
	[Barriers] ,
	[Access],
	[Financial] ,
	[Other],
	[Will],
	[LivingWill] ,
	[AdvancedDirectives] ,
	[HealthCare],
	[None],

	[HealthCareTreatments] ,
	[FamilyTraditions],
	[LanguageBarriers] ,
	[VisualLimitations] ,
	[HearingDeficits] ,
	[Literacy] ,
	
	[Member],
	[Caregiver] ,
	[Training]  ,
	[Assistance] ,

	[UnclearCaregiver] ,
	[AssistanceNeeded] ,
	[Eligibility],
	[BehavioralHealth] ,
	[LongTerm],

	[Rehabilitative],
	[PalliativeCare] ,
	[HomeHealth] ,
					
	f.[Created],
	f.[CreatedBy],
	f.[ModifiedDate],
	f.[ModifiedBy],
		d.FirstName,
		d.LastName
  FROM [FormAddendum] F
  Left JOIN MainPersonalDetails d ON d.ICENUMBER = F.MVDID
  LEFT JOIN MainInsurance m ON m.ICENUMBER = F.MVDID 
  where F.ID = @ID
  order by f.FormDate desc
END