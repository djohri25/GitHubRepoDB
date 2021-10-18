/****** Object:  Procedure [dbo].[Set_FormOBIntakeAssessment]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/06/2015
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_FormOBIntakeAssessment]
	@MVDID varchar(20),
	@CustID varchar(20),
	@StaffInterviewing varchar(50),
	@FormDate date,
	@Gender Char(1) ,
	@DateOfBirth datetime  ,
	@PLan varchar (50),
	@ProviderIDNumber varchar(20),
	@Address varchar (150),
	@City varchar (50),
	@State varchar (50),
	@Zip varchar (10),
	@MemberPhone varchar (13),
	@MemberOtherPhone varchar (13)= NULL,
	@MemberExt varchar (4) =NULL,
	@MemberEmail varchar (150) =NULL,
	@ParentLegalGuardian varchar (150)= NULL,
	@GuardianPhone  varchar(13)= NULL,
	@GuardianOtherPhone varchar (13) =NULL,
	@GuardianExt varchar (4) =NULL,
	@IntroductionOfCMRole  bit =null,
	@MemberAgreeToCMservices bit = NULL,
	@CMServicesReason varchar (60)= NULL,
	@ReliableTransportation  bit=null,
	@OBProvider bit=NULL,
	@FindingOBProvider bit=NULL,
	@OBProviderContactNumber varchar (13) =NULL,
	@OBProviderLocation varchar(150) =NULL,
	@OBProviderName varchar(150) =NULL,
	@FirstTrimester bit=NULL,
	@FirstOBVisitDate varchar(15) =NULL,
	@GestationFirstOBVisit varchar(150) =NULL,
	@CurrentWeekGestation varchar(150) =NULL,
	@EDD varchar(150) =NULL,
	@Gravida varchar(150) =NULL,
	@Para varchar(150) =NULL,
	@LC varchar(150) =NULL,
	@PreEclampsia bit=NULL,
	@Eclampsia bit=NULL,
	@GestationalHypertension bit=NULL,
	@HypertensionNotPregnanant bit=NULL,
	@GestationalDiabetes bit=NULL,
	@DietControl bit=NULL,
	@InsulinControl bit=NULL,
	@PretermLabor bit=NULL,
	@17P bit=NULL,
	@CesareanSection bit=NULL,
	@Other bit=NULL,
	@ComplicationDescription varchar(150) =NULL,
	@MedicalConditionsIllnesses bit=NULL,
	@ListMedicalConditionsIllnesses varchar(300) =NULL,
	@Facility varchar(150) =NULL,
	@FacilityOther varchar(150) =NULL,
	@FacilityOON varchar(150) =NULL,
	@AttendingChildbirthClasses bit=NULL,
	@Medicaid bit=NULL,
	@MedicaidType varchar(150) =NULL,
	@MTP bit=NULL,
	@SocialProblems bit=NULL,
	@BeaconEAP bit=NULL,
	@DrAppointments bit=NULL,
	@NextOBAppointment varchar(150) =NULL,
	@PediatricianBaby bit=NULL,
	@PediatricianName varchar(150) =NULL,
	@PediatricianContactNumber  varchar (13) =NULL,
	@WIC bit=NULL,
	@SNAP bit=NULL ,
	@SupportFromFamily bit=NULL,
	@ManagementFollowup bit=NULL,
	@SpecialNotes varchar(300)= NULL ,
	@Result int = -1 output
AS
BEGIN
	SET NOCOUNT ON;

	declare @FormID int, @UserType varchar(10)

	INSERT INTO [FormOBIntakeAssessment]
    (	[MVDID]
           ,[CustID]
           ,[StaffInterviewing]
           ,[FormDate]
           ,[Gender]
           ,[DateOfBirth]
           ,[PLan]
           ,[ProviderIDNumber]
           ,[Address]
           ,[City]
           ,[State]
           ,[Zip]
           ,[MemberPhone]
           ,[MemberOtherPhone]
           ,[MemberExt]
           ,[MemberEmail]
           ,[ParentLegalGuardian]
           ,[GuardianPhone]
           ,[GuardianOtherPhone]
           ,[GuardianExt]
           ,[IntroductionOfCMRole]
           ,[MemberAgreeToCMservices]
           ,[CMServicesReason]
           ,[ReliableTransportation],
			[OBProvider] ,
			[FindingOBProvider] ,
			[OBProviderContactNumber] ,
			[OBProviderLocation] ,
			[OBProviderName],
			[FirstTrimester] ,
			[FirstOBVisitDate],
			[GestationFirstOBVisit],
			[CurrentWeekGestation],
			[EDD],
			[Gravida],
			[Para],
			[LC],
			[PreEclampsia] ,
			[Eclampsia] ,
			[GestationalHypertension] ,
			[HypertensionNotPregnanant] ,
			[GestationalDiabetes] ,
			[DietControl] ,
			[InsulinControl] ,
			[PretermLabor] ,
			[TakeP] ,
			[CesareanSection] ,
			[Other] ,
			[ComplicationDescription],
			[MedicalConditionsIllnesses] ,
			[ListMedicalConditionsIllnesses] ,
			[Facility],
			[FacilityOther],
			[FacilityOON],
			[AttendingChildbirthClasses] ,
			[Medicaid],
			[MedicaidType],
			[MTP],
			[SocialProblems],
			[BeaconEAP],
			[DrAppointments] ,
			[NextOBAppointment],
			[PediatricianBaby] ,
			[PediatricianName],
			[PediatricianContactNumber],
			[WIC] ,
			[SNAP] ,
			[SupportFromFamily] ,
			[ManagementFollowup] ,
			[SpecialNotes],
			[Created]
			,[CreatedBy]
			,[ModifiedDate]
			,[ModifiedBy])
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
		@Address ,
		@City ,
		@State ,
		@Zip ,
		@MemberPhone,
		@MemberOtherPhone ,
		@MemberExt ,
		@MemberEmail,
		@ParentLegalGuardian,
		@GuardianPhone ,
		@GuardianOtherPhone,
		@GuardianExt ,
		@IntroductionOfCMRole ,
		@MemberAgreeToCMservices ,
		@CMServicesReason ,
		@ReliableTransportation,
		@OBProvider,
		@FindingOBProvider,
		@OBProviderContactNumber,
		@OBProviderLocation,
		@OBProviderName ,
		@FirstTrimester,
		@FirstOBVisitDate,
		@GestationFirstOBVisit,
		@CurrentWeekGestation,
		@EDD,
		@Gravida,
		@Para,
		@LC,
		@PreEclampsia,
		@Eclampsia,
		@GestationalHypertension,
		@HypertensionNotPregnanant,
		@GestationalDiabetes,
		@DietControl,
		@InsulinControl,
		@PretermLabor,
		@17P,
		@CesareanSection,
		@Other,
		@ComplicationDescription,
		@MedicalConditionsIllnesses,
		@ListMedicalConditionsIllnesses,
		@Facility,
		@FacilityOther,
		@FacilityOON,
		@AttendingChildbirthClasses,
		@Medicaid,
		@MedicaidType,
		@MTP,
		@SocialProblems,
		@BeaconEAP,
		@DrAppointments,
		@NextOBAppointment,
		@PediatricianBaby,
		@PediatricianName,
		@PediatricianContactNumber,
		@WIC,
		@SNAP,
		@SupportFromFamily,
		@ManagementFollowup,
		@SpecialNotes,
		@FormDate,
		@StaffInterviewing,
		GETDATE(),
		@StaffInterviewing
		)
     
	   declare @insMemberID varchar(20), @noteText varchar(1000)
     
     select @insMemberID = InsMemberId from dbo.Link_MemberId_MVD_Ins where MVDId = @MVDID
     select @noteText = 'OB Intake Assessment Form Saved. '

	 if exists(select top 1 * from MDUser where Username =  @StaffInterviewing)
     begin
		set @UserType = 'MD'
	end
	else
	begin
		set @UserType = 'HP'		
	end
	select @FormID = @@IDENTITY

	insert into dbo.HPAlertNote (MVDID,Note,AlertStatusID,datecreated,createdby,CreatedByType,
		datemodified,modifiedby,ModifiedByType,SendToHP,SendToPCP,SendToNurture,SendToNone,LinkedFormType,LinkedFormID)
	values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'OBIA',@FormID)

    
     set @Result = @FormID
END