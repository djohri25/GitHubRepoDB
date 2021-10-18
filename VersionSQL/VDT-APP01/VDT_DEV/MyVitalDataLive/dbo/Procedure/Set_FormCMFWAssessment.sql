/****** Object:  Procedure [dbo].[Set_FormCMFWAssessment]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:  <Author,,Name>
-- Create date: 5/06/2015
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_FormCMFWAssessment]
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
 @MigrantFarmerworker bit= NULL,
 @AnyAssistance bit= NULL,
 @SpecialNotes varchar(300)= NULL ,
 @Result int = -1 output
AS
BEGIN
 SET NOCOUNT ON;

 declare @FormID int, @UserType varchar(10)

 INSERT INTO FormCMFWAssessment
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
	,[DateofLastVisit]
	,[MigrantFarmerworker]
	,[AnyAssistance]
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
		CONVERT(VARCHAR(10),cast(@DateofLastVisit as date),101),
		@MigrantFarmerworker,
		@AnyAssistance,
		@SpecialNotes,
		@FormDate,
		@StaffInterviewing,
		GETDATE(),
		@StaffInterviewing
  )
     
    declare @insMemberID varchar(20), @noteText varchar(1000)
     
     select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
     select @noteText = 'CMFW Assessment Form Saved. '

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
 values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'CMFW',@FormID)

    
     set @Result = @FormID
END