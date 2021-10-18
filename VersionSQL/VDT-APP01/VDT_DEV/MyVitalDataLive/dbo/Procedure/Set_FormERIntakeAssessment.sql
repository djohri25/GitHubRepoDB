/****** Object:  Procedure [dbo].[Set_FormERIntakeAssessment]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/06/2015
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_FormERIntakeAssessment]
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
	@ReviewedER bit= NULL,
	@Networkfacilities bit= NULL,
	@ClinicsWithinArea bit= NULL,
	@MedicalAdvice bit= NULL, 
	@SetonHealthPlan bit= NULL, 
	@PostERVisit  bit= NULL, 
	@MedicationPrescriptions   bit= NULL, 
	@PharmacyDelivery bit= NULL, 
	@ChildCurrentVisits  bit= NULL, 
	@RecommendedImmunizations   bit= NULL, 
	@HealthInsurance bit=NUll,
	@InsuranceType varchar(150)= NULL,
	@ReliableTransportation  bit=null,
	@Transportation varchar(150)= NULL,
	@SocialProblems bit=NUll,
	@BeaconEAP bit=NUll,
	@AdditionalResource varchar(150)= NULL,
	@SpecialNotes varchar(300)= NULL,
	@Result int = -1 output
AS
BEGIN
	SET NOCOUNT ON;

	declare @FormID int, @UserType varchar(10)

	INSERT INTO FormERIntakeAssessment
    (	 [MVDID]
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
           ,[ReviewedER]
           ,[Networkfacilitiest]
           ,[ClinicsWithinArea]
           ,[MedicalAdvice]
           ,[SetonHealthPlan]
           ,[PostERVisit]
           ,[MedicationPrescriptions]
           ,[PharmacyDelivery]
           ,[ChildCurrentVisits]
           ,[RecommendedImmunizations]
           ,[HealthInsurance]
           ,[InsuranceType]
           ,[ReliableTransportation]
           ,[Transportation]
           ,[SocialProblems]
           ,[BeaconEAP]
           ,[AdditionalResource]
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
		@ReviewedER,
		@Networkfacilities,
		@ClinicsWithinArea,
		@MedicalAdvice,
		@SetonHealthPlan,
		@PostERVisit ,
		@MedicationPrescriptions ,
		@PharmacyDelivery,
		@ChildCurrentVisits,
		@RecommendedImmunizations,
		@HealthInsurance,
		@InsuranceType,
		@ReliableTransportation,
		@Transportation,
		@SocialProblems,
		@BeaconEAP,
		@AdditionalResource,
		@SpecialNotes,
		@FormDate,
		@StaffInterviewing,
		GETDATE(),
		@StaffInterviewing
		)
     
	 declare @insMemberID varchar(20), @noteText varchar(1000)
   
     select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
     select @noteText = 'ER Intake Assessment Form Saved. '

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
	values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'ERIA',@FormID)

    
     set @Result = @FormID
END