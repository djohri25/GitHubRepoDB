/****** Object:  Procedure [dbo].[IceMR_SocialHistoryUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_SocialHistoryUpdate] 

	@IceNumber varchar(15),
	@Smoking bit,
	@SmokingNow bit, 
	@SmokingQuit bit,
	@SmokingWhen varchar(50),
	@SmokingYear float,
	@SmokingHowMuch float,
	@SmokingOtherForm bit,
	@SmokingNote varchar(50),
	@Alcohol bit,
	@AlcoholHowMuch varchar(50),
	@AlcoholHowOften varchar(50),
	@Drug bit,
	@DrugWhat varchar(50),
	@SunExposure bit,
	@Exercise bit,
	@ExerciseType varchar(50),
	@ExerciseOften varchar(50),
	@Restriction bit,
	@RestrictionHow varchar(50),	
	@Emotional bit,
	@EmotionalHow varchar(50)


as

	DECLARE @Count int

	SET NOCOUNT ON

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