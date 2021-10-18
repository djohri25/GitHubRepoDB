/****** Object:  Procedure [dbo].[setPDFLabeltextPEDGeneralGuidelines]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE procedure [dbo].[setPDFLabeltextPEDGeneralGuidelines]
@Id int,@casename varchar(500)

as

if(@casename ='General Conditions')
BEGIN
SELECT checkbloodsugar AS condition FROM formpatienteducationdiabetes WHERE checkbloodsugar != '' AND id = @Id
UNION
SELECT CheckHgA1c AS condition FROM formpatienteducationdiabetes WHERE CheckHgA1c != '' AND id = @Id
UNION
SELECT CheckBloodPressure AS condition FROM formpatienteducationdiabetes WHERE CheckBloodPressure != '' AND id = @Id
UNION
SELECT WatchLipids AS condition FROM formpatienteducationdiabetes WHERE WatchLipids != '' AND id = @Id
UNION
SELECT DailyPhysicalActivity AS condition FROM formpatienteducationdiabetes WHERE DailyPhysicalActivity != '' AND id = @Id
UNION
SELECT Stressmanagement AS condition FROM formpatienteducationdiabetes WHERE Stressmanagement != '' AND id = @Id
UNION
SELECT Seeeyedoctor AS condition FROM formpatienteducationdiabetes WHERE Seeeyedoctor != '' AND id = @Id
UNION
SELECT Telldentist AS condition FROM formpatienteducationdiabetes WHERE Telldentist != '' AND id = @Id
UNION
SELECT yearlykidneyscreening AS condition FROM formpatienteducationdiabetes WHERE yearlykidneyscreening != '' AND id = @Id
UNION
SELECT CheckFeet AS condition FROM formpatienteducationdiabetes WHERE CheckFeet != '' AND id = @Id
UNION
SELECT KnowMedications AS condition FROM formpatienteducationdiabetes WHERE KnowMedications != '' AND id = @Id
END
--SELECT * FROM FormPatientEducationDiabetes
ELSE
if(@casename = 'Basic Dietary Guidelines')
BEGIN
SELECT RememberDiet AS condition FROM formpatienteducationdiabetes WHERE RememberDiet != '' AND id = @Id
UNION
SELECT EatSmallMeals AS condition FROM formpatienteducationdiabetes WHERE EatSmallMeals != '' AND id = @Id
UNION
SELECT LimitCarbohydrate AS condition FROM formpatienteducationdiabetes WHERE LimitCarbohydrate != '' AND id = @Id
UNION
SELECT VegetableAndSalads AS condtion FROM formpatienteducationdiabetes WHERE VegetableAndSalads != '' AND id = @Id
UNION
SELECT EatLowFatProtein AS condtion FROM formpatienteducationdiabetes WHERE EatLowFatProtein != '' AND id = @Id
UNION
SELECT AvoidHighFatFoods AS condtion FROM formpatienteducationdiabetes WHERE AvoidHighFatFoods != '' AND id = @Id
UNION
SELECT AvoidFoodWithHighSugar AS condtion FROM formpatienteducationdiabetes WHERE AvoidFoodWithHighSugar != '' AND id = @Id
UNION
SELECT UseSugarSubstitute AS condtion FROM formpatienteducationdiabetes WHERE UseSugarSubstitute != '' AND id = @Id
UNION
SELECT LargeAmountAbdominalCramping AS condtion FROM formpatienteducationdiabetes WHERE LargeAmountAbdominalCramping != '' AND id = @Id
UNION
SELECT FreeFoods AS condtion FROM formpatienteducationdiabetes WHERE FreeFoods != '' AND id = @Id
end
else

if(@casename = 'General Guidelines for Sick Day Management')
BEGIN
SELECT DrinkFluids AS condition FROM formpatienteducationdiabetes WHERE DrinkFluids != '' AND id = @Id
UNION
SELECT DrinkSmallSipsLiquid AS condition FROM formpatienteducationdiabetes WHERE DrinkSmallSipsLiquid != '' AND id = @Id
UNION
SELECT [Drink812OunceFluid] AS condition FROM formpatienteducationdiabetes WHERE [Drink812OunceFluid] != '' AND id = @Id
UNION
SELECT EatingNormalCarbs AS condition FROM formpatienteducationdiabetes WHERE EatingNormalCarbs != '' AND id = @Id
UNION
SELECT TakeCarbsInLiquid AS condition FROM formpatienteducationdiabetes WHERE TakeCarbsInLiquid != '' AND id = @Id
UNION
SELECT AvoidSolidFoodsIfVomiting AS condition FROM formpatienteducationdiabetes WHERE AvoidSolidFoodsIfVomiting != '' AND id = @Id
END
else
If(@casename= 'If you take insulin')
BEGIN
SELECT DontStopInsulin AS condition FROM formpatienteducationdiabetes WHERE DontStopInsulin != '' AND id = @Id
UNION
SELECT InsulinNeeded AS condition FROM formpatienteducationdiabetes WHERE InsulinNeeded != '' AND id = @Id
UNION
SELECT InsulinTobeAdjusted AS condition FROM formpatienteducationdiabetes WHERE InsulinTobeAdjusted != '' AND id = @Id
END
else
if(@casename = 'Call your Health Care Provider if you')
BEGIN
SELECT VomitOrDiarrhea AS condition FROM formpatienteducationdiabetes WHERE VomitOrDiarrhea != '' AND id = @Id
UNION
SELECT BloodSugarOver240 AS condition FROM formpatienteducationdiabetes WHERE BloodSugarOver240 != '' AND id = @Id
UNION
SELECT HaveKetones AS condition FROM formpatienteducationdiabetes WHERE HaveKetones != '' AND id = @Id
UNION
SELECT HaveDifficultyBreathing AS condition FROM formpatienteducationdiabetes WHERE HaveDifficultyBreathing != '' AND id = @Id
UNION
SELECT UnsureHowMuchInsulin AS condition FROM formpatienteducationdiabetes WHERE UnsureHowMuchInsulin != '' AND id = @Id
END



--EXEC [dbo].[setPDFLabeltextPEDGeneralGuidelines]
--@Id = 1,@casename ='General Guidelines for Sick Day Management'