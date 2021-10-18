/****** Object:  Procedure [dbo].[Set_FormPostPartumAssessment]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/06/2015
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_FormPostPartumAssessment]
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
	@PrimaryCareProvider bit,
	@ProviderContactNumber varchar(13)= NULL,
	@DateofLastVisit datetime = NULL,
	@ReliableTransportation  bit=null,
	@HaveOBProvider bit =null,
	@HelpFindingOBprovider bit =null,
	@OBProviderContactNumber  varchar(13)= NULL,
	@OBProviderOfficeLocation varchar(150)= NULL,
	@OBProviderNames varchar(150)= NULL,
	@OBProviderDateOfVisit varchar(150)= NULL,
	@FirstOBVisit varchar(50)= NULL,
	@DiaperGiftCard varchar(50)= NULL,
	@MotherAdmissionDate varchar(50)= NULL,
	@MotherDischargeDate varchar(50)= NULL,
	@MotherExtendedStayReason varchar(150)= NULL,
	@DeliverDate varchar(15)= NULL,
	@Vaginal bit =null,
	@VaginalwTL bit =null,
	@VBAC bit =null,
	@VBACwTL bit =null,
	@CSX bit =null,
	@CSXwTL bit =null,
	@BirthWeightLBs  varchar(20) =null,
	@BirthWeightOZs  varchar(20)=null,
	@BirthWeightGrams  varchar(20) =null,
	@BirthCertificateFirstName varchar(150)= NULL,
	@BirthCertificateMIName varchar(100)= NULL,
	@BirthCertificateLastName varchar(150)= NULL,
	@ExtendedStayNICU bit =null,
	@ReasonExtendedStay  varchar(300)= NULL,
	@BabyDischargeDate  varchar(15) =null,
	@PreEclampsia bit =null,
	@Eclampsia bit =null,
	@GestationalHypertension bit =null,
	@HypertensionNotPregnanant bit =null,
	@GestationalDiabetes bit =null,
	@DietControl bit =null,
	@InsulinControl bit =null,
	@PretermLabor bit =null,
	@170DuringPregnancy bit =null,
	@Other bit =null,
	@ComplicationDescription varchar(300)= NULL,
	@DeliveryComplications bit =null,
	@DeliveryComplicationDesc varchar(300)= NULL,
	@MotherBabyOncehome varchar(300)= NULL,
	@Breastfeeding bit =null,
	@FormulaFeeding bit =null,
	@Both bit =null,
	@BreastPump bit =null,
	@WIC bit =null,
	@SocialProblems  bit =null,
	@EAP bit =null,
	@MTP bit =null,
	@keepingDrAppointments bit= NULL,
	@AppointmentForMother varchar(150)= NULL,
	@AppointmentForBaby varchar(150)= NULL,
	@BabyPediatrician varchar(150)= NULL,
	@PediatricianContactNumber varchar(150)= NULL,
	@WereInstructionsProvided bit= NULL,
	@EducationalMaterialProvided bit=NUll,
	@EducationalMaterialSite varchar(150)= NULL,
	@OBorPCP bit=NUll,
	@SpecialNotes varchar(300)= NULL ,
	@Result int = -1 output
AS
BEGIN
	SET NOCOUNT ON;

	declare @FormID int, @UserType varchar(10)

	INSERT INTO FormPostPartumAssessment
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
           ,[PrimaryCareProvider]
           ,[ProviderContactNumber]
           ,[DateofLastVisit]
           ,[ReliableTransportation]
           ,[HaveOBProvider]
           ,[HelpFindingOBprovider]
           ,[OBProviderContactNumber]
           ,[OBProviderOfficeLocation]
           ,[OBProviderNames]
           ,[OBProviderDateOfVisit]
           ,[FirstOBVisit]
           ,[DiaperGiftCard]
           ,[MotherAdmissionDate]
           ,[MotherDischargeDate]
           ,[MotherExtendedStayReason]
           ,[DeliverDate]
           ,[Vaginal]
           ,[VaginalwTL]
           ,[VBAC]
           ,[VBACwTL]
           ,[CSX]
           ,[CSXwTL]
           ,[BirthWeightLBs]
           ,[BirthWeightOZs]
           ,[BirthWeightGrams]
           ,[BirthCertificateFirstName]
           ,[BirthCertificateMIName]
           ,[BirthCertificateLastName]
           ,[ExtendedStayNICU]
           ,[ReasonExtendedStay]
           ,[BabyDischargeDate]
           ,[PreEclampsia]
           ,[Eclampsia]
           ,[GestationalHypertension]
           ,[HypertensionNotPregnanant]
           ,[GestationalDiabetes]
           ,[DietControl]
           ,[InsulinControl]
           ,[PretermLabor]
           ,[170DuringPregnancy]
           ,[Other]
           ,[ComplicationDescription]
           ,[DeliveryComplications]
           ,[DeliveryComplicationDesc]
           ,[MotherBabyOncehome]
           ,[Breastfeeding]
           ,[FormulaFeeding]
           ,[Both]
           ,[BreastPump]
           ,[WIC]
           ,[SocialProblems]
           ,[EAP]
           ,[MTP]
           ,[keepingDrAppointments]
           ,[AppointmentForMother]
           ,[AppointmentForBaby]
           ,[BabyPediatrician]
           ,[PediatricianContactNumber]
           ,[WereInstructionsProvided]
           ,[EducationalMaterialProvided]
           ,[EducationalMaterialSite]
           ,[OBorPCP]
           ,[SpecialNotes]
           ,[Created]
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
		@PrimaryCareProvider ,
		@ProviderContactNumber,
		CONVERT(VARCHAR(10),cast(@DateofLastVisit as date),101)  ,
		@ReliableTransportation,
		@HaveOBProvider,
		@HelpFindingOBprovider,
		@OBProviderContactNumber,
		@OBProviderOfficeLocation,
		@OBProviderNames,
		@OBProviderDateOfVisit,
		@FirstOBVisit,
		@DiaperGiftCard,
		@MotherAdmissionDate,
		@MotherDischargeDate,
		@MotherExtendedStayReason,
		@DeliverDate,
		@Vaginal,
		@VaginalwTL,
		@VBAC,
		@VBACwTL,
		@CSX,
		@CSXwTL,
		@BirthWeightLBs ,
		@BirthWeightOZs ,
		@BirthWeightGrams,
		@BirthCertificateFirstName,
		@BirthCertificateMIName,
		@BirthCertificateLastName,
		@ExtendedStayNICU,
		@ReasonExtendedStay,
		@BabyDischargeDate,
		@PreEclampsia,
		@Eclampsia,
		@GestationalHypertension,
		@HypertensionNotPregnanant,
		@GestationalDiabetes,
		@DietControl,
		@InsulinControl,
		@PretermLabor,
		@170DuringPregnancy,
		@Other,
		@ComplicationDescription,
		@DeliveryComplications,
		@DeliveryComplicationDesc,
		@MotherBabyOncehome,
		@Breastfeeding,
		@FormulaFeeding,
		@Both,
		@BreastPump,
		@WIC,
		@SocialProblems,
		@EAP,
		@MTP,
		@keepingDrAppointments,
		@AppointmentForMother,
		@AppointmentForBaby,
		@BabyPediatrician,
		@PediatricianContactNumber,
		@WereInstructionsProvided,
		@EducationalMaterialProvided,
		@EducationalMaterialSite,
		@OBorPCP,
		@SpecialNotes,
		@FormDate,
		@StaffInterviewing,
		GETDATE(),
		@StaffInterviewing
		)
     
	   declare @insMemberID varchar(20), @noteText varchar(1000)
     
     select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
     select @noteText = 'Post-Partum Assessment Form Saved. '

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
	values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'PMA',@FormID)

    
     set @Result = @FormID
END