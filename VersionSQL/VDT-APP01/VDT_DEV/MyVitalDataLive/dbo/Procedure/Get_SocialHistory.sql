/****** Object:  Procedure [dbo].[Get_SocialHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_SocialHistory] 
	@IceNumber varchar(15)
as

	set nocount on

	DECLARE @Count int

	SELECT @Count = COUNT(*) FROM MainSocialHistory WHERE IceNumber = @IceNumber
	IF @Count = 0
		INSERT INTO MainSocialHistory (IceNumber) VALUES (@IceNumber)
	
	SELECT Smoking, SmokingNow, SmokingQuit, SmokingWhen, SmokingYear, SmokingHowMuch,
	SmokingOtherForm,SmokingNote, Alcohol, AlcoholHowMuch, AlcoholHowOften, Drug, DrugWhat,
	SunExposure, Exercise, ExerciseType, ExerciseOften, Restriction, RestrictionHow,
	Emotional, EmotionalHow, 
	Smoking AS IsSmoke,
	dbo.CheckedAns(SmokingNow) AS IsNow, dbo.CheckedAns(SmokingQuit) AS IsQuit,
	dbo.CheckedAns(SmokingOtherForm) AS IsOtherSk,
	Alcohol AS IsAlcohol,
	Drug AS IsDrug,
	SunExposure AS IsSunExposure,
	Exercise AS IsExercise,
	Restriction AS IsRestriction,
	Emotional AS IsEmotional
	FROM MainSocialHistory WHERE IceNumber = @IceNumber