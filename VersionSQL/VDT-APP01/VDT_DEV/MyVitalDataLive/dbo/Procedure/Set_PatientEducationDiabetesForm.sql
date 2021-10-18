/****** Object:  Procedure [dbo].[Set_PatientEducationDiabetesForm]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/06/2015
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_PatientEducationDiabetesForm]
	@MVDID varchar(20),
	@CustID varchar(20),
	@StaffInterviewing varchar(50),
	@DateOfBirth datetime  ,
	@ProviderIDNumber varchar(20),

@CheckBloodSugar varchar(max),
	@CheckHgA1c varchar(max) ,
	@CheckBloodPressure varchar(max) ,
	@WatchLipids varchar(max) ,
	@DailyPhysicalActivity varchar(max) ,
	@StressManagement varchar(max) ,
	@SeeEyeDoctor varchar(max) ,
	
	@TellDentist varchar(max) ,
	@YearlyKidneyScreening varchar(max) ,
	@CheckFeet varchar(max),
	@KnowMedications varchar(max) ,
	@RememberDiet varchar(max) ,
	@EatSmallMeals varchar(max) ,
	@LimitCarbohydrate varchar(max) ,

	@VegetableAndSalads varchar(max) ,
	@EatLowFatProtein varchar(max) ,
	@AvoidHighFatFoods varchar(max) ,
	@AvoidFoodWithHighSugar varchar(max) ,
	@UseSugarSubstitute varchar(max) ,
	@LargeAmountAbdominalCramping varchar(max) ,
	@FreeFoods varchar(max) ,
	
	@DrinkFluids varchar(max) ,
	@DrinkSmallSipsLiquid varchar(max) ,
	@Drink812OunceFluid varchar(max) ,
	@EatingNormalCarbs varchar(max) ,
	@TakeCarbsInLiquid varchar(max) ,
	@AvoidSolidFoodsIfVomiting varchar(max) ,
	@DontStopInsulin varchar(max) ,
	
	@InsulinNeeded varchar(max) ,
	@InsulinTobeAdjusted varchar(max) ,
	@VomitOrDiarrhea varchar(max) ,
	@BloodSugarOver240 varchar(max) ,
	@HaveKetones varchar(max) ,
	@HaveDifficultyBreathing varchar(max) ,
	@UnsureHowMuchInsulin varchar(max) ,
	




	@Created datetime ,
	@CreatedBy varchar(50) ,
	@ModifiedBy varchar(50) ,
	@Result int = -1 output

	AS
BEGIN
	SET NOCOUNT ON;

	declare @FormID int, @UserType varchar(10)

INSERT INTO FormPatientEducationDiabetes
(
	MVDID ,
	CustID ,
	DateOfBirth,
	ProviderIDNumber,

CheckBloodSugar ,
	CheckHgA1c  ,
	CheckBloodPressure  ,
	WatchLipids  ,
	DailyPhysicalActivity  ,
	StressManagement  ,
	SeeEyeDoctor  ,
	
	TellDentist  ,
	YearlyKidneyScreening  ,
	CheckFeet ,
	KnowMedications  ,
	RememberDiet  ,
	EatSmallMeals  ,
	LimitCarbohydrate  ,

	VegetableAndSalads  ,
	EatLowFatProtein  ,
	AvoidHighFatFoods  ,
	AvoidFoodWithHighSugar  ,
	UseSugarSubstitute  ,
	LargeAmountAbdominalCramping  ,
	FreeFoods  ,
	
	DrinkFluids  ,
	DrinkSmallSipsLiquid  ,
	[Drink812OunceFluid]  ,
	EatingNormalCarbs  ,
	TakeCarbsInLiquid  ,
	AvoidSolidFoodsIfVomiting  ,
	DontStopInsulin  ,
	
	InsulinNeeded  ,
	InsulinTobeAdjusted  ,
	VomitOrDiarrhea  ,
	BloodSugarOver240  ,
	HaveKetones  ,
	HaveDifficultyBreathing  ,
	UnsureHowMuchInsulin  ,

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

@CheckBloodSugar ,
	@CheckHgA1c  ,
	@CheckBloodPressure  ,
	@WatchLipids  ,
	@DailyPhysicalActivity  ,
	@StressManagement  ,
	@SeeEyeDoctor  ,
	
	@TellDentist  ,
	@YearlyKidneyScreening  ,
	@CheckFeet ,
	@KnowMedications  ,
	@RememberDiet  ,
	@EatSmallMeals  ,
	@LimitCarbohydrate  ,

	@VegetableAndSalads  ,
	@EatLowFatProtein  ,
	@AvoidHighFatFoods  ,
	@AvoidFoodWithHighSugar  ,
	@UseSugarSubstitute  ,
	@LargeAmountAbdominalCramping  ,
	@FreeFoods  ,
	
	@DrinkFluids  ,
	@DrinkSmallSipsLiquid  ,
	@Drink812OunceFluid  ,
	@EatingNormalCarbs  ,
	@TakeCarbsInLiquid  ,
	@AvoidSolidFoodsIfVomiting  ,
	@DontStopInsulin  ,
	
	@InsulinNeeded  ,
	@InsulinTobeAdjusted  ,
	@VomitOrDiarrhea  ,
	@BloodSugarOver240  ,
	@HaveKetones  ,
	@HaveDifficultyBreathing  ,
	@UnsureHowMuchInsulin  ,
	

 	@Created ,
	@CreatedBy,
	GETDATE(),
	@ModifiedBy
)


	   declare @insMemberID varchar(20), @noteText varchar(1000)
     
     select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
     select @noteText = 'Patient Education Diabetes Form Saved. '

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
	values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'PED',@FormID)

	 set @Result = @FormID
END