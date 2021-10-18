/****** Object:  Procedure [dbo].[Set_FormGeneralAssessment]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:  <Author,,Name>
-- Create date: 5/06/2015
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_FormGeneralAssessment]
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
 @PrimaryCareProvider bit = NULL,
 @ProviderContactNumber varchar(13)= NULL,
 @DateofLastVisit datetime = NULL,
 @ReliableTransportation  bit=null,
 @SeeSpecialist bit= NULL,
 @Specialty varchar(150)= NULL,
 @SpecialistName varchar(150)= NULL,
 @ClinicName varchar(150)= NULL,
 @ClinicLocation varchar(150)= NULL,
 @ClinicPhoneNumber varchar(15)= NULL,
 @NumberOfHospitalVisit6Mnths varchar(10)= NULL,
 @HospLocation varchar(150)= NULL,
 @HospOther varchar(150)= NULL,
 @HospDate  varchar(15)= NULL,
 @NumberOfEDVisit varchar(10)= NULL,
 @EDVisitLocation varchar(150)= NULL,
 @EDVisitOther varchar(150)= NULL,
 @MedicalAppointments bit= NULL,
 @PrimaryDiagnoses varchar(300)= NULL,
 @SocialEnvironment bit= NULL,
 @BehavioralHealth bit= NULL,
 @RoutineMedications  bit= NULL,
 @ListOfMedications varchar(300)= NULL,
 @ObtainingYourMedication bit= NULL,
 @TreatmentRegimen bit=NUll,
 @DME bit =NULL,
 @ObtainingYourDME bit=NUll,
 @SpecialNotes varchar(300)= NULL ,
 @Result int = -1 output
AS
BEGIN
 SET NOCOUNT ON;

 declare @FormID int, @UserType varchar(10)

 INSERT INTO FormGeneralAssessment
    ( [MVDID]
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
           ,[DateofLastVisit],
            [ReliableTransportation],
   [SeeSpecialist],
   [Specialty],
   [SpecialistName],
   [ClinicName],
   [ClinicLocation],
   [ClinicPhoneNumber],
   [NumberOfHospitalVisit6Mnths],
   [HospLocation],
   [HospOther],
   [HospDate],
   [NumberOfEDVisit],
   [EDVisitLocation],
   [EDVisitOther],
   [MedicalAppointments],
   [PrimaryDiagnoses],
   [SocialEnvironment],
   [BehavioralHealth],
   [RoutineMedications],
   [ListOfMedications],
   [ObtainingYourMedication],
   [TreatmentRegimen],
   [DME],
   [ObtainingYourDME],
   [SpecialNotes],
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
  @SeeSpecialist,
  @Specialty ,
  @SpecialistName,
  @ClinicName,
  @ClinicLocation,
  @ClinicPhoneNumber,
  @NumberOfHospitalVisit6Mnths,
  @HospLocation,
  @HospOther,
  @HospDate,
  @NumberOfEDVisit,
  @EDVisitLocation,
  @EDVisitOther,
  @MedicalAppointments ,
  @PrimaryDiagnoses,
  @SocialEnvironment ,
  @BehavioralHealth ,
  @RoutineMedications ,
  @ListOfMedications ,
  @ObtainingYourMedication,
  @TreatmentRegimen ,
  @DME ,
  @ObtainingYourDME ,
  @SpecialNotes,
  @FormDate,
  @StaffInterviewing,
  GETDATE(),
  @StaffInterviewing
  )
     
    declare @insMemberID varchar(20), @noteText varchar(1000)
     
     select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
     select @noteText = 'General Assessment Form Saved. '

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
 values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'GA',@FormID)

    
     set @Result = @FormID
END