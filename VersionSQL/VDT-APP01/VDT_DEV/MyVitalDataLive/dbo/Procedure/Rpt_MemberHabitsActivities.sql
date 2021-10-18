/****** Object:  Procedure [dbo].[Rpt_MemberHabitsActivities]    Committed by VersionSQL https://www.versionsql.com ******/

-- [Rpt_MemberFamilyHistory] L25XF74SA6


--CREATE 
--
CREATE
Procedure [dbo].[Rpt_MemberHabitsActivities] 
	@IceNumber varchar(15)
as
	SELECT 
	dbo.CheckedAns(Smoking) Smoking, 
	dbo.CheckedAns(SmokingNow)SmokingNow, 
	dbo.CheckedAns(SmokingQuit)SmokingQuit, 
	SmokingWhen, SmokingYear, SmokingHowMuch,
	dbo.CheckedAns(SmokingOtherForm)SmokingOtherForm,
	SmokingNote, 
	dbo.CheckedAns(Alcohol)Alcohol, 
	AlcoholHowMuch, AlcoholHowOften, 
	dbo.CheckedAns(Drug)Drug, 
	DrugWhat,
	dbo.CheckedAns(SunExposure)SunExposure, 
	dbo.CheckedAns(Exercise)Exercise, 
	ExerciseType, ExerciseOften, 
	dbo.CheckedAns(Restriction)Restriction, 
	RestrictionHow,
	dbo.CheckedAns(Emotional)Emotional, 
	EmotionalHow, 
	dbo.CheckedAns(Smoking) AS IsSmoke,
	dbo.CheckedAns(SmokingNow) AS IsNow, dbo.CheckedAns(SmokingQuit) AS IsQuit,
	dbo.CheckedAns(SmokingOtherForm) AS IsOtherSk,
	dbo.CheckedAns(Alcohol) AS IsAlcohol,
	dbo.CheckedAns(Drug) AS IsDrug,
	dbo.CheckedAns(SunExposure) AS IsSunExposure,
	dbo.CheckedAns(Exercise) AS IsExercise,
	dbo.CheckedAns(Restriction) AS IsRestriction,
	dbo.CheckedAns(Emotional) AS IsEmotional
	FROM MainSocialHistory WHERE IceNumber = @IceNumber AND (Smoking IS NOT NULL AND SmokingNow IS NOT NULL)