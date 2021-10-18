/****** Object:  Procedure [dbo].[Set_PatientEducationCHFForm]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/06/2015
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_PatientEducationCHFForm]
	@MVDID varchar(20),
	@CustID varchar(20),
	@StaffInterviewing varchar(50),
	@DateOfBirth datetime  ,
	@ProviderIDNumber varchar(20),
	@SuddenWeightGain varchar(500),
	@SwollenAbdomenAnkle varchar(500),
	@WorsenShortnessOfBreath varchar(500),
	@NotSleepingComfortableFlat varchar(500),
	@WorseningCough varchar(500),
	@PersistentOnsetNauseaVomiting varchar(500),
	@WorseningDizziness varchar(500),
	@NewOnsetFatigue varchar(500), 	
	@Created datetime ,
	@CreatedBy varchar(50) ,
	@ModifiedBy varchar(50) ,
	@Result int = -1 output

	AS
BEGIN
	SET NOCOUNT ON;

	declare @FormID int, @UserType varchar(10)

INSERT INTO FormPatientEducationCHF
(
	MVDID ,
	CustID ,
	DateOfBirth,
	ProviderIDNumber,
	SuddenWeightGain,
	SwollenAbdomenAnkle,
	WorsenShortnessOfBreath,
	NotSleepingComfortableFlat,
	WorseningCough ,
	PersistentOnsetNauseaVomiting,
	WorseningDizziness,
	NewOnsetFatigue, 	
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
	@SuddenWeightGain,
	@SwollenAbdomenAnkle,
	@WorsenShortnessOfBreath,
	@NotSleepingComfortableFlat,
	@WorseningCough ,
	@PersistentOnsetNauseaVomiting,
	@WorseningDizziness,
	@NewOnsetFatigue, 	
 	@Created ,
	@CreatedBy,
	GETDATE(),
	@ModifiedBy
)


	   declare @insMemberID varchar(20), @noteText varchar(1000)
     
     select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
     select @noteText = 'Patient Education CHF Form Saved. '

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
	values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'PECHF',@FormID)

	 set @Result = @FormID
END