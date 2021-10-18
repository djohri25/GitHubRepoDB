/****** Object:  Procedure [dbo].[Set_PatientEducationPostPartumForm]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/06/2015
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_PatientEducationPostPartumForm]
	@MVDID varchar(20),
	@CustID varchar(20),
	@StaffInterviewing varchar(50),
	@DateOfBirth datetime  ,
	@ProviderIDNumber varchar(20),

	@FeverOver100 varchar(max) ,
	@PersistentNausea varchar(max) ,
	@PainBurningUrination varchar(max) ,
	@SwellingInLegs varchar(max) ,
	@ChestPain varchar(max) ,
	@LocalizedPain varchar(max) ,
	@PersistentPerinealPain varchar(max) ,
	@IncreasedPainAfterCSection varchar(max) ,
	@FoulSmellingDischarge varchar(max) ,
	@BrightRedBleeding varchar(max) ,
	@PostPartumDepression varchar(max) ,
	@NothingInVagina varchar(max) ,
	@NoDriving varchar(max) ,
	@TakeAllMedications varchar(max) ,
	@ReferToCommunityResources varchar(max) ,
	@WIC varchar(max) ,
	@AnyBodyCan varchar(max) ,
	@Text4Baby varchar(max) ,
	@Health4Mom varchar(max) ,
	@HealthyChildren varchar(max) ,
	@YourTexasBenefits varchar(max) ,
	@TexasHealthSteps varchar(max) ,
	@Created datetime ,
	@CreatedBy varchar(50) ,
	@ModifiedBy varchar(50) ,
	@Result int = -1 output

	AS
BEGIN
	SET NOCOUNT ON;

	declare @FormID int, @UserType varchar(10)

INSERT INTO FormPatientEducationPostPartum
(
	MVDID ,
	CustID ,
	DateOfBirth,
	ProviderIDNumber,

	FeverOver100  ,
	PersistentNausea  ,
	PainBurningUrination  ,
	SwellingInLegs  ,
	ChestPain  ,
	LocalizedPain  ,
	PersistentPerinealPain  ,
	IncreasedPainAfterCSection  ,
	FoulSmellingDischarge  ,
	BrightRedBleeding  ,
	PostPartumDepression  ,
	NothingInVagina  ,
	NoDriving  ,
	TakeAllMedications  ,
	ReferToCommunityResources  ,
	WIC  ,
	AnyBodyCan  ,
	Text4Baby  ,
	Health4Mom  ,
	HealthyChildren  ,
	YourTexasBenefits  ,
	TexasHealthSteps  ,
	


	Created,
	CreatedBy,
	ModifiedDate,
	ModifiedBy 
	
)
VALUES
(
    @MVDID,
	@CustID,
	@DateOfBirth,
	@ProviderIDNumber,

	@FeverOver100  ,
	@PersistentNausea  ,
	@PainBurningUrination  ,
	@SwellingInLegs  ,
	@ChestPain  ,
	@LocalizedPain  ,
	@PersistentPerinealPain  ,
	@IncreasedPainAfterCSection  ,
	@FoulSmellingDischarge  ,
	@BrightRedBleeding  ,
	@PostPartumDepression  ,
	@NothingInVagina  ,
	@NoDriving  ,
	@TakeAllMedications  ,
	@ReferToCommunityResources  ,
	@WIC  ,
	@AnyBodyCan  ,
	@Text4Baby  ,
	@Health4Mom  ,
	@HealthyChildren  ,
	@YourTexasBenefits  ,
	@TexasHealthSteps  ,

 	@Created ,
	@CreatedBy,
	GETDATE(),
	@ModifiedBy
)


	   declare @insMemberID varchar(20), @noteText varchar(1000)
     
     select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
     select @noteText = 'Patient Education Post Partum Form Saved. '

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
	values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'PEPP',@FormID)

	 set @Result = @FormID
END