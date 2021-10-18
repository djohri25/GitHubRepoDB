/****** Object:  Procedure [dbo].[Set_PatientEducationGeneralAdultForm]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/06/2015
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_PatientEducationGeneralAdultForm]
	@MVDID varchar(20),
	@CustID varchar(20),
	@StaffInterviewing varchar(50),
	@DateOfBirth datetime  ,
	@ProviderIDNumber varchar(20),

@IncreaseShortnessofBreath varchar(max),
	@UnableToSleepFlat varchar(max) ,
	@WorseningCough varchar(max) ,
	@RednessOrDrainage varchar(max) ,
	@UnexplainedWeightGain varchar(max) ,
	@IncreaseFatigue varchar(max) ,
	@PersistentNausea varchar(max) ,
	@PersistentElevatedTemprature varchar(max) ,
	@AvoidContactWithOthers varchar(max) ,
	@FollowupWithPhysician varchar(max) ,
	@TakeAllMedications varchar(max) ,
	@ReadNutritionLabels varchar(max) ,
	@FindWaysToReduceStress varchar(max) ,
	@RemainActive varchar(max) ,
	



	@Created datetime ,
	@CreatedBy varchar(50) ,
	@ModifiedBy varchar(50) ,
	@Result int = -1 output

	AS
BEGIN
	SET NOCOUNT ON;

	declare @FormID int, @UserType varchar(10)

INSERT INTO FormPatientEducationGeneralAdult
(
	MVDID ,
	CustID ,
	DateOfBirth,
	ProviderIDNumber,

IncreaseShortnessofBreath ,
	UnableToSleepFlat  ,
	WorseningCough  ,
	RednessOrDrainage  ,
	UnexplainedWeightGain  ,
	IncreaseFatigue  ,
	PersistentNausea  ,
	PersistentElevatedTemprature  ,
	AvoidContactWithOthers  ,
	FollowupWithPhysician  ,
	TakeAllMedications  ,
	ReadNutritionLabels  ,
	FindWaysToReduceStress  ,
	RemainActive  ,
	



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

@IncreaseShortnessofBreath ,
	@UnableToSleepFlat  ,
	@WorseningCough  ,
	@RednessOrDrainage  ,
	@UnexplainedWeightGain  ,
	@IncreaseFatigue  ,
	@PersistentNausea  ,
	@PersistentElevatedTemprature  ,
	@AvoidContactWithOthers  ,
	@FollowupWithPhysician  ,
	@TakeAllMedications  ,
	@ReadNutritionLabels  ,
	@FindWaysToReduceStress  ,
	@RemainActive  ,
	

 	@Created ,
	@CreatedBy,
	GETDATE(),
	@ModifiedBy
)


	   declare @insMemberID varchar(20), @noteText varchar(1000)
     
     select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
     select @noteText = 'Patient Education General Adult Form Saved. '

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
	values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'PEGA',@FormID)

	 set @Result = @FormID
END