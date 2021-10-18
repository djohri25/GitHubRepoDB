/****** Object:  Procedure [dbo].[setPDFLabeltextPEGP]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[setPDFLabeltextPEGP]
@Id int,@casename varchar(500)

as

if(@casename ='Call your doctor')
BEGIN
SELECT * FROM 
(SELECT PersistentNausea AS condition,'A' orderkey FROM FormPatientEducationGeneralPediatrics fpegp WHERE PersistentNausea != '' AND id = @Id
UNION
SELECT PersistentElevatedTemprature AS condition,'B' orderkey FROM FormPatientEducationGeneralPediatrics fpegp WHERE PersistentElevatedTemprature != '' AND id = @Id
UNION
SELECT UncontrolledPain AS condition,'C' orderkey FROM FormPatientEducationGeneralPediatrics fpegp WHERE fpegp.UncontrolledPain != '' AND id = @Id
UNION
SELECT DietaryIntake AS condition,'D' orderkey FROM FormPatientEducationGeneralPediatrics fpegp WHERE fpegp.DietaryIntake != '' AND id = @Id
UNION
SELECT BehaviorOrAlertness AS condition,'E' orderkey FROM FormPatientEducationGeneralPediatrics fpegp WHERE fpegp.BehaviorOrAlertness != '' AND id = @Id
UNION
SELECT DifficultyBreathing AS condition,'F' orderkey FROM FormPatientEducationGeneralPediatrics fpegp WHERE fpegp.DifficultyBreathing != '' AND id = @Id
UNION
SELECT DecreaseUrineOutput AS condition,'G' orderkey FROM FormPatientEducationGeneralPediatrics fpegp WHERE fpegp.DecreaseUrineOutput != '' AND id = @Id
) x ORDER BY orderkey
END
--SELECT * FROM FormPatientEducationGeneralPediatrics
ELSE
if(@casename = 'Other Instructions')
BEGIN
SELECT * FROM (
SELECT AvoidContactWithOthers AS condition,'H' orderkey FROM FormPatientEducationGeneralPediatrics fpegp WHERE fpegp.AvoidContactWithOthers != '' AND id = @Id
UNION
SELECT FollowupWithPhysician AS condition,'I' orderkey FROM FormPatientEducationGeneralPediatrics fpegp WHERE fpegp.FollowupWithPhysician != '' AND id = @Id
UNION
SELECT TakeAllMedications AS condition,'J' orderkey FROM FormPatientEducationGeneralPediatrics fpegp WHERE fpegp.TakeAllMedications != '' AND id = @Id
) x ORDER BY orderkey
END



--EXEC [dbo].[setPDFLabeltextPEGP]
--@Id = 1,@casename ='Other Instructions'