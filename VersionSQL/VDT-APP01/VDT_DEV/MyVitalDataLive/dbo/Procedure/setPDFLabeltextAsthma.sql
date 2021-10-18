/****** Object:  Procedure [dbo].[setPDFLabeltextAsthma]    Committed by VersionSQL https://www.versionsql.com ******/

create procedure [dbo].[setPDFLabeltextAsthma]
@Id int
as

SELECT RemainIndoors AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.RemainIndoors != '' AND id = @Id
UNION
SELECT WearMask AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.WearMask != '' AND id = @Id
UNION
SELECT DecreaseDustInHome AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.DecreaseDustInHome != '' AND id = @Id
UNION
SELECT MaintainExerciseAndRest AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.MaintainExerciseAndRest != '' AND id = @Id
UNION
SELECT AvoidPersonwithRTI AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.AvoidPersonwithRTI != '' AND id = @Id
UNION
SELECT ControlStressFactor AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.ControlStressFactor != '' AND id = @Id
UNION
SELECT AvoidDehydration AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.AvoidDehydration != '' AND id = @Id
UNION
SELECT AvoidExposureToCold AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.AvoidExposureToCold != '' AND id = @Id
UNION
SELECT ReceiveImmunization AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.ReceiveImmunization != '' AND id = @Id
UNION
SELECT TakingMedication AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.TakingMedication != '' AND id = @Id
UNION
SELECT StopSmoking AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.StopSmoking != '' AND id = @Id
UNION
SELECT PCPAsthmaActionPlan AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.PCPAsthmaActionPlan != '' AND id = @Id
UNION
SELECT AvoidAsthmaTrigger AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.AvoidAsthmaTrigger != '' AND id = @Id