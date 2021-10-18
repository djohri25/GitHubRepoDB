/****** Object:  Procedure [dbo].[Get_FormAddendum]    Committed by VersionSQL https://www.versionsql.com ******/

-- =======================================================
-- Author:		<Author,,Name> FormCMFWAssessment
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- ========================================================
CREATE PROCEDURE [dbo].[Get_FormAddendum]
@MVDID varchar(20), @CustID VARCHAR (20)=NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1[ID]
      ,F.[MVDID]
      ,F.[CustID]
      ,F.[StaffInterviewing]
      ,F.[FormDate]
      ,F.[Gender]
      ,F.[DateOfBirth]
      ,F.[PLan]
      ,F.[ProviderIDNumber],
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
  WHERE    MVDID = @MVDID AND CustID = @CustID
  order by f.ID desc
END