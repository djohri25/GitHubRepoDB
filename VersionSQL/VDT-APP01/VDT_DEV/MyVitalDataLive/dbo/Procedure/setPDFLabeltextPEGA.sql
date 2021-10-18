/****** Object:  Procedure [dbo].[setPDFLabeltextPEGA]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[setPDFLabeltextPEGA]
@Id int,@casename varchar(500)

as

if(@casename ='Call your doctor')
BEGIN
SELECT * FROM (
SELECT IncreaseShortnessofBreath AS condition,'A' orderkey FROM FormPatientEducationGeneralAdult fpega  WHERE IncreaseShortnessofBreath != '' AND id = @Id
UNION
SELECT UnableToSleepFlat AS condition,'B' orderkey FROM FormPatientEducationGeneralAdult fpega  WHERE fpega.UnableToSleepFlat != '' AND id = @Id
UNION
SELECT WorseningCough AS condition,'C' orderkey FROM FormPatientEducationGeneralAdult fpega  WHERE fpega.WorseningCough != '' AND id = @Id
UNION
SELECT RednessOrDrainage AS condition,'D' orderkey FROM FormPatientEducationGeneralAdult fpega  WHERE fpega.RednessOrDrainage != '' AND id = @Id
UNION
SELECT UnexplainedWeightGain AS condition,'E' orderkey FROM FormPatientEducationGeneralAdult fpega  WHERE fpega.UnexplainedWeightGain != '' AND id = @Id
UNION
SELECT IncreaseFatigue AS condition,'F' orderkey FROM FormPatientEducationGeneralAdult fpega  WHERE fpega.IncreaseFatigue != '' AND id = @Id
UNION
SELECT PersistentNausea AS condition,'G' orderkey FROM FormPatientEducationGeneralAdult fpega  WHERE PersistentNausea != '' AND id = @Id
UNION
SELECT PersistentElevatedTemprature AS condition,'H' orderkey FROM FormPatientEducationGeneralAdult fpega WHERE PersistentElevatedTemprature != '' AND id = @Id
) x ORDER BY orderkey
END
--SELECT * FROM FormPatientEducationGeneralAdult
ELSE
if(@casename = 'Other Instructions')
BEGIN
SELECT * FROM (
SELECT AvoidContactWithOthers AS condition,'I' orderkey FROM FormPatientEducationGeneralAdult fpega WHERE fpega.AvoidContactWithOthers != '' AND id = @Id
UNION
SELECT FollowupWithPhysician AS condition,'J' orderkey FROM FormPatientEducationGeneralAdult fpega WHERE fpega.FollowupWithPhysician != '' AND id = @Id
UNION
SELECT TakeAllMedications AS condition,'K' orderkey FROM FormPatientEducationGeneralAdult fpega WHERE fpega.TakeAllMedications != '' AND id = @Id
UNION
SELECT ReadNutritionLabels AS condition,'L' orderkey FROM FormPatientEducationGeneralAdult fpega  WHERE fpega.ReadNutritionLabels != '' AND id = @Id
UNION
SELECT FindWaysToReduceStress AS condition,'M' orderkey FROM FormPatientEducationGeneralAdult fpega  WHERE fpega.FindWaysToReduceStress != '' AND id = @Id
UNION
SELECT RemainActive AS condition,'N' orderkey FROM FormPatientEducationGeneralAdult fpega  WHERE fpega.RemainActive != '' AND id = @Id
) x ORDER BY orderkey
END