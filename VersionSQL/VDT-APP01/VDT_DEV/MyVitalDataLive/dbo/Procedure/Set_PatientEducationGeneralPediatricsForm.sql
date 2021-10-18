/****** Object:  Procedure [dbo].[Set_PatientEducationGeneralPediatricsForm]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/06/2015
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_PatientEducationGeneralPediatricsForm]
	@MVDID varchar(20),
	@CustID varchar(20),
	@StaffInterviewing varchar(50),
	@DateOfBirth datetime  ,
	@ProviderIDNumber varchar(20),

	@UncontrolledPain varchar(max) ,
	@DietaryIntake varchar(max) ,
	@BehaviorOrAlertness varchar(max) ,
	@DifficultyBreathing varchar(max) ,
	@DecreaseUrineOutput varchar(max) ,
	@PersistentNausea varchar(max) ,
	@PersistentElevatedTemprature varchar(max) ,
	@AvoidContactWithOthers varchar(max) ,
	@FollowupWithPhysician varchar(max) ,
	@TakeAllMedications varchar(max) ,
	



	@Created datetime ,
	@CreatedBy varchar(50) ,
	@ModifiedBy varchar(50) ,
	@Result int = -1 output

	AS
BEGIN
	SET NOCOUNT ON;

	declare @FormID int, @UserType varchar(10)

INSERT INTO FormPatientEducationGeneralPediatrics
(
	MVDID ,
	CustID ,
	DateOfBirth,
	ProviderIDNumber,

	UncontrolledPain ,
	DietaryIntake,
	BehaviorOrAlertness  ,
	DifficultyBreathing  ,
	DecreaseUrineOutput  ,
	PersistentNausea  ,
	PersistentElevatedTemprature  ,
	AvoidContactWithOthers  ,
	FollowupWithPhysician  ,
	TakeAllMedications  ,
	


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

@UncontrolledPain ,
	@DietaryIntake,
	@BehaviorOrAlertness  ,
	@DifficultyBreathing  ,
	@DecreaseUrineOutput  ,
	@PersistentNausea  ,
	@PersistentElevatedTemprature  ,
	@AvoidContactWithOthers  ,
	@FollowupWithPhysician  ,
	@TakeAllMedications  ,
		

 	@Created ,
	@CreatedBy,
	GETDATE(),
	@ModifiedBy
)


	   declare @insMemberID varchar(20), @noteText varchar(1000)
     
     select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
     select @noteText = 'Patient Education General Pediatrics Form Saved. '

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
	values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'PEGP',@FormID)

	 set @Result = @FormID
END