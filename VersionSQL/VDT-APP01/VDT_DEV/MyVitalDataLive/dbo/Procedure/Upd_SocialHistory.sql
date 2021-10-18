/****** Object:  Procedure [dbo].[Upd_SocialHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_SocialHistory] 

	@IceNumber varchar(15),
	@Smoking varchar(5),
	@SmokingNow bit, 
	@SmokingQuit bit,
	@SmokingWhen varchar(50),
	@SmokingYear float,
	@SmokingHowMuch float,
	@SmokingOtherForm bit,
	@SmokingNote varchar(50),
	@Alcohol varchar(5),
	@AlcoholHowMuch varchar(50),
	@AlcoholHowOften varchar(50),
	@Drug varchar(5),
	@DrugWhat varchar(50),
	@SunExposure varchar(5),
	@Exercise varchar(5),
	@ExerciseType varchar(50),
	@ExerciseOften varchar(50),
	@Restriction varchar(5),
	@RestrictionHow varchar(50),	
	@Emotional varchar(5),
	@EmotionalHow varchar(50)


as

	DECLARE @Count int
	set nocount on

	SELECT @Count = COUNT(*) FROM MainSocialHistory WHERE IceNumber = @IceNumber

	IF @Count = 0
	
	INSERT INTO MainSocialHistory
	(ICENUMBER, Smoking, 
	SmokingNow, 
	SmokingQuit, 
	SmokingWhen, 
	SmokingYear, 
	SmokingHowMuch,
	SmokingOtherForm,
	SmokingNote, 
	Alcohol, 
	AlcoholHowMuch, 
	AlcoholHowOften, 
	Drug, 
	DrugWhat,
	SunExposure,
	Exercise, 
	ExerciseType, 
	ExerciseOften, 
	Restriction, 
	RestrictionHow,
	Emotional,
	EmotionalHow, 
	CreationDate,
	ModifyDate) VALUES(
	@IceNumber,
	@Smoking, 
	@SmokingNow, 
	@SmokingQuit, 
	@SmokingWhen, 
	@SmokingYear, 
	@SmokingHowMuch,
	@SmokingOtherForm,
	@SmokingNote, 
	@Alcohol, 
	@AlcoholHowMuch, 
	@AlcoholHowOften, 
	@Drug, 
	@DrugWhat,
	@SunExposure,
	@Exercise, 
	@ExerciseType, 
	@ExerciseOften, 
	@Restriction, 
	@RestrictionHow,
	@Emotional,
	@EmotionalHow, 
	GETUTCDATE(), GETUTCDATE())

	ELSE

	UPDATE MainSocialHistory
	SET Smoking = @Smoking, 
	SmokingNow = @SmokingNow, 
	SmokingQuit = @SmokingQuit, 
	SmokingWhen = @SmokingWhen, 
	SmokingYear = @SmokingYear, 
	SmokingHowMuch = @SmokingHowMuch,
	SmokingOtherForm = @SmokingOtherForm,
	SmokingNote = @SmokingNote, 
	Alcohol = @Alcohol, 
	AlcoholHowMuch = @AlcoholHowMuch, 
	AlcoholHowOften = @AlcoholHowOften, 
	Drug = @Drug, 
	DrugWhat = @DrugWhat,
	SunExposure = @SunExposure,
	Exercise = @Exercise, 
	ExerciseType = @ExerciseType, 
	ExerciseOften = @ExerciseOften, 
	Restriction = @Restriction, 
	RestrictionHow = @RestrictionHow,
	Emotional = @Emotional,
	EmotionalHow = @EmotionalHow, 
	ModifyDate = GETUTCDATE()
	WHERE IceNumber = @IceNumber