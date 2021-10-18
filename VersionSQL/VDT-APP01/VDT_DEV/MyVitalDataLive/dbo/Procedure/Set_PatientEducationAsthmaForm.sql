/****** Object:  Procedure [dbo].[Set_PatientEducationAsthmaForm]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/06/2015
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_PatientEducationAsthmaForm]
	@MVDID varchar(20),
	@CustID varchar(20),
	@StaffInterviewing varchar(50),
	@DateOfBirth datetime  ,
	@ProviderIDNumber varchar(20),
	@RemainIndoors varchar(max) ,
	@WearMask varchar(max) ,
    @DecreaseDustInHome varchar(max) ,
	@MaintainExerciseAndRest varchar(max) ,
	@AvoidPersonwithRTI varchar(max) ,
	@ControlStressFactor varchar(max) ,
	@AvoidDehydration varchar(max) ,
	@AvoidExposureToCold varchar(max) ,
	@ReceiveImmunization varchar(max) ,
	@TakingMedication varchar(max) ,
	@StopSmoking varchar(max) ,
	@PCPAsthmaActionPlan varchar(max) ,
	@AvoidAsthmaTrigger varchar(max) ,
	@DecreasePeakFlows varchar(max) ,
	@IncreaseAgitation varchar(max) ,
	@AsthmaAttackNotControlled varchar(max) ,
	@IncreasedNeedForMedication varchar(max) ,
	@IncreaseAsthmaAttack varchar(max) ,
	@ControlStressFactorPCP varchar(max) ,
	@DecreaseActivityTolerance varchar(max) ,
	@PersistentElevatedTemp varchar(max) ,
	@CoughProductive varchar(max) ,
 	@Created datetime ,
	@CreatedBy varchar(50) ,
	@ModifiedBy varchar(50) ,
	@Result int = -1 output

	AS
BEGIN
	SET NOCOUNT ON;

	declare @FormID int, @UserType varchar(10)

INSERT INTO FormPatientEducationAsthma
(
	MVDID ,
	CustID ,
	DateOfBirth,
	ProviderIDNumber,
	RemainIndoors ,
	WearMask ,
    DecreaseDustInHome,
	MaintainExerciseAndRest ,
	AvoidPersonwithRTI,
	ControlStressFactor,
	AvoidDehydration ,
	AvoidExposureToCold,
	ReceiveImmunization,
	TakingMedication,
	StopSmoking,
	PCPAsthmaActionPlan,
	AvoidAsthmaTrigger,
	DecreasePeakFlows,
	IncreaseAgitation ,
	AsthmaAttackNotControlled ,
	IncreasedNeedForMedication ,
	IncreaseAsthmaAttack ,
	ControlStressFactorPCP ,
	DecreaseActivityTolerance ,
	PersistentElevatedTemp ,
	CoughProductive ,
 	Created ,
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
@RemainIndoors ,
	@WearMask ,
    @DecreaseDustInHome,
	@MaintainExerciseAndRest ,
	@AvoidPersonwithRTI,
	@ControlStressFactor,
	@AvoidDehydration ,
	@AvoidExposureToCold,
	@ReceiveImmunization,
	@TakingMedication,
	@StopSmoking,
	@PCPAsthmaActionPlan,
	@AvoidAsthmaTrigger,
	@DecreasePeakFlows,
	@IncreaseAgitation ,
	@AsthmaAttackNotControlled ,
	@IncreasedNeedForMedication ,
	@IncreaseAsthmaAttack ,
	@ControlStressFactorPCP ,
	@DecreaseActivityTolerance ,
	@PersistentElevatedTemp ,
	@CoughProductive ,
 	@Created ,
	@CreatedBy,
	GETDATE(),
	@ModifiedBy
)


	   declare @insMemberID varchar(20), @noteText varchar(1000)
     
     select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
     select @noteText = 'Patient Education Asthma Form Saved. '

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
	values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'PEA',@FormID)

	 set @Result = @FormID
END