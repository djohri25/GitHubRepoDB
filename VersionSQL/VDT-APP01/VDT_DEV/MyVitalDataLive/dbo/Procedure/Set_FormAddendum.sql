/****** Object:  Procedure [dbo].[Set_FormAddendum]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:  <Author,,Name>
-- Create date: 5/06/2015
-- Description: <Description,,>
-- =============================================
create PROCEDURE [dbo].[Set_FormAddendum]
 @MVDID varchar(20),
 @CustID varchar(20),
 @StaffInterviewing varchar(50),
 @FormDate date,
 @Gender Char(1) ,
 @DateOfBirth datetime  ,
 @PLan varchar (50),
 @ProviderIDNumber varchar(20),

 	@Grooming varchar(150) =NULL ,
	@Dressing varchar(150)  = NULL ,
	@Bathing varchar(500)  = NULL ,
	@Toileting varchar(500) = NULL ,
	@Eating varchar(500) = NULL ,
	@Laundry varchar(500) = NULL ,
	@LightHousekeeping varchar(500) = NULL ,
	@Shopping varchar(500) = NULL ,
	@MealPreparation varchar(500) = NULL ,
	@UsingTheTelephone varchar(500) = NULL ,
	@ManagingMedications varchar(500) = NULL ,
	@ManagingPrescribedProcedures varchar(500) = NULL ,
	@TransferAmbulation varchar(500) = NULL ,
	@ManagingBarrierrs varchar(500) = NULL ,
	@AlertOriented varchar(500) = NULL ,
	@RequiresPrompting varchar(500) = NULL ,
	@RequiresAssistance varchar(500) = NULL ,
	@RequiresAssistanceInRoutine varchar(500) = NULL ,
	@TotallyDependent varchar(500) = NULL ,
	@Beliefs varchar(500) = NULL ,
	@Barriers varchar(500) = NULL ,
	@Access varchar(500) = NULL ,
	@Financial varchar(500) = NULL ,
	@Other varchar(500) = NULL ,
	@Will varchar(500) = NULL ,
	@LivingWill varchar(500) = NULL ,
	@AdvancedDirectives varchar(500) = NULL ,
	@HealthCare varchar(500) = NULL ,
	@None varchar(500) = NULL ,

	@HealthCareTreatments varchar(500) = NULL ,
	@FamilyTraditions varchar(500) = NULL ,
	@LanguageBarriers varchar(500) = NULL ,
	@VisualLimitations varchar(500) = NULL ,
	@HearingDeficits varchar(500) = NULL ,
	@Literacy varchar(500) = NULL ,
	
	@Member varchar(500) = NULL ,
	@Caregiver varchar(500) = NULL ,
	@Training varchar(500) = NULL ,
	@Assistance varchar(500) = NULL ,

	@UnclearCaregiver varchar(500) = NULL ,
	@AssistanceNeeded varchar(500) = NULL ,
	@Eligibility varchar(500) = NULL ,
	@BehavioralHealth varchar(500) = NULL ,
	@LongTerm varchar(500) = NULL ,

	@Rehabilitative varchar(500) = NULL ,
	@PalliativeCare varchar(500) = NULL ,
	@HomeHealth varchar(500) = NULL ,


 --@Address varchar (500),
 --@City varchar (50),
 --@State varchar (50),
 --@Zip varchar (10),
 --@MemberPhone varchar (13),
 --@MemberOtherPhone varchar (13)= NULL,
 --@MemberExt varchar (4) =NULL,
 --@MemberEmail varchar (150) =NULL,
 --@ParentLegalGuardian varchar (150)= NULL,
 --@GuardianPhone  varchar(13)= NULL,
 --@GuardianOtherPhone varchar (13) =NULL,
 --@GuardianExt varchar (4) =NULL,
 --@IntroductionOfCMRole  bit =null,
 --@MemberAgreeToCMservices bit = NULL,
 --@CMServicesReason varchar (60)= NULL,
 --@PrimaryCareProvider bit,
 --@ProviderContactNumber varchar(13)= NULL,
 --@DateofLastVisit datetime = NULL,
 --@MigrantFarmerworker bit= NULL,
 --@AnyAssistance bit= NULL,
 --@SpecialNotes varchar(300)= NULL ,


 @Result int = -1 output
AS
BEGIN
 SET NOCOUNT ON;

 declare @FormID int, @UserType varchar(10)

 INSERT INTO FormAddendum
	( 
	[MVDID]
	,[CustID]
	,[StaffInterviewing]
	,[FormDate]
	,[Gender]
	,[DateOfBirth]
	,[PLan]
	,[ProviderIDNumber]
,	[Grooming] ,
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
					
	[Created],
	[CreatedBy],
	[ModifiedDate],
	[ModifiedBy])
    VALUES
     (
		@MVDID,
		@CustID,
		@StaffInterviewing ,
		@FormDate,
		@Gender,
		Convert(varchar(10),@DateOfBirth,101),
		@PLan ,
		@ProviderIDNumber,
	@Grooming  ,
	@Dressing  ,
	@Bathing  ,
	@Toileting  ,
	@Eating  ,
	@Laundry  ,
	@LightHousekeeping ,
	@Shopping ,
	@MealPreparation  ,
	@UsingTheTelephone  ,
	@ManagingMedications  ,
	@ManagingPrescribedProcedures ,
	@TransferAmbulation,
	@ManagingBarrierrs,
	@AlertOriented  ,
	@RequiresPrompting  ,
	@RequiresAssistance  ,
	@RequiresAssistanceInRoutine  ,
	@TotallyDependent ,
	@Beliefs  ,
	@Barriers ,
	@Access  ,
	@Financial  ,
	@Other ,
	@Will ,
	@LivingWill ,
	@AdvancedDirectives  ,
	@HealthCare ,
	@None  ,

	@HealthCareTreatments,
	@FamilyTraditions,
	@LanguageBarriers,
	@VisualLimitations,
	@HearingDeficits ,
	@Literacy,
	
	@Member ,
	@Caregiver ,
	@Training ,
	@Assistance ,

	@UnclearCaregiver ,
	@AssistanceNeeded,
	@Eligibility ,
	@BehavioralHealth,
	@LongTerm  ,

	@Rehabilitative ,
	@PalliativeCare ,
	@HomeHealth ,
		@FormDate,
		@StaffInterviewing,
		GETDATE(),
		@StaffInterviewing
  )
     
    declare @insMemberID varchar(20), @noteText varchar(1000)
     
     select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
     select @noteText = 'Form Addendum Saved. '

  if exists(select top 1 * from MDUser where Username =  @StaffInterviewing)
     begin
  set @UserType = 'MD'
 end
 else
 begin
  set @UserType = 'HP'  
 end
 select @FormID = @@IDENTITY

 insert into HPAlertNote (MVDID,Note,AlertStatusID,datecreated,createdby,CreatedByType,
  datemodified,modifiedby,ModifiedByType,SendToHP,SendToPCP,SendToNurture,SendToNone,LinkedFormType,LinkedFormID)
 values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'FA',@FormID)

    
     set @Result = @FormID
END