/****** Object:  Procedure [dbo].[setPDFLabeltextAAF]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[setPDFLabeltextAAF]
@Id int,@casename varchar(500)

as

if(@casename ='Activities of Daily Living')
BEGIN
SELECT * FROM (
SELECT grooming AS condition,'A' orderkey FROM FormAddendum fa WHERE fa.Grooming != '' AND id = @Id
UNION
SELECT Dressing AS condition,'B' orderkey FROM FormAddendum fa WHERE fa.Dressing != '' AND id = @Id
UNION
SELECT Bathing AS condition,'C' orderkey FROM FormAddendum fa WHERE fa.Bathing != '' AND id = @Id
UNION
SELECT Toileting AS condition,'D' orderkey FROM FormAddendum fa WHERE fa.Toileting != '' AND id = @Id
UNION
SELECT Eating AS condition,'E' orderkey FROM FormAddendum fa WHERE fa.Eating != '' AND id = @Id
UNION
SELECT Laundry AS condition,'F' orderkey FROM FormAddendum fa WHERE fa.Laundry != '' AND id = @Id
UNION
SELECT LightHousekeeping AS condition,'G' orderkey FROM FormAddendum fa WHERE fa.LightHousekeeping != '' AND id = @Id
UNION
SELECT Shopping AS condition,'H' orderkey FROM FormAddendum fa WHERE fa.Shopping != '' AND id = @Id
UNION
SELECT MealPreparation AS condition,'I' orderkey FROM FormAddendum fa WHERE fa.MealPreparation != '' AND id = @Id
UNION
SELECT UsingTheTelephone AS condition,'J' orderkey FROM FormAddendum fa WHERE fa.UsingTheTelephone != '' AND id = @Id
UNION
SELECT ManagingMedications AS condition,'K' orderkey FROM FormAddendum fa WHERE fa.ManagingMedications != '' AND id = @Id
UNION
SELECT ManagingPrescribedProcedures AS condition,'L' orderkey FROM FormAddendum fa WHERE fa.ManagingPrescribedProcedures != '' AND id = @Id
UNION
SELECT TransferAmbulation AS condition,'M' orderkey FROM FormAddendum fa WHERE fa.TransferAmbulation != '' AND id = @Id
UNION
SELECT ManagingBarrierrs AS condition,'N' orderkey FROM FormAddendum fa WHERE fa.ManagingBarrierrs != '' AND id = @Id
) x ORDER BY orderkey
END
ELSE
if(@casename = 'Level of cognitive functioning')
BEGIN
SELECT * FROM (
SELECT AlertOriented AS condition,'A' orderkey FROM FormAddendum fa WHERE fa.AlertOriented != '' AND id = @Id
UNION
SELECT RequiresPrompting AS condition,'B' orderkey FROM FormAddendum fa WHERE fa.RequiresPrompting != '' AND id = @Id
UNION
SELECT RequiresAssistance AS condition,'C' orderkey FROM FormAddendum fa WHERE fa.RequiresAssistance != '' AND id = @Id
UNION
SELECT RequiresAssistanceInRoutine AS condition,'D' orderkey FROM FormAddendum fa WHERE fa.RequiresAssistanceInRoutine != '' AND id = @Id
UNION
SELECT TotallyDependent AS condition,'E' orderkey FROM FormAddendum fa WHERE fa.TotallyDependent != '' AND id = @Id
) x ORDER BY orderkey
END
ELSE
if(@casename ='Identification of possible psychosocial issues')
BEGIN
SELECT * FROM (
SELECT Beliefs AS condition,'A' orderkey FROM FormAddendum fa WHERE fa.Beliefs != '' AND id = @Id
UNION
SELECT Barriers AS condition,'B' orderkey FROM FormAddendum fa WHERE fa.Barriers != '' AND id = @Id
UNION
SELECT Access AS condition,'C' orderkey FROM FormAddendum fa WHERE fa.Access != '' AND id = @Id
UNION
SELECT Financial AS condition,'D' orderkey FROM FormAddendum fa WHERE fa.Financial != '' AND id = @Id
UNION
SELECT Other AS condition,'E' orderkey FROM FormAddendum fa WHERE fa.Other != '' AND id = @Id
) x ORDER BY orderkey
END
ELSE
if(@casename ='Life planning activities')
BEGIN
SELECT * FROM (
SELECT Will AS condition,'A' orderkey FROM FormAddendum fa WHERE fa.Will != '' AND id = @Id
UNION
SELECT LivingWill AS condition,'B' orderkey FROM FormAddendum fa WHERE fa.LivingWill != '' AND id = @Id
UNION
SELECT AdvancedDirectives AS condition,'C' orderkey FROM FormAddendum fa WHERE fa.AdvancedDirectives != '' AND id = @Id
UNION
SELECT HealthCare AS condition,'D' orderkey FROM FormAddendum fa WHERE fa.HealthCare != '' AND id = @Id
UNION
SELECT [None] AS condition,'E' orderkey FROM FormAddendum fa WHERE fa.[None] != '' AND id = @Id
) x ORDER BY orderkey
END
ELSE

if(@casename ='Identification of cultural')
BEGIN
SELECT * FROM (
SELECT HealthCareTreatments AS condition,'A' orderkey FROM FormAddendum fa WHERE fa.HealthCareTreatments != '' AND id = @Id
UNION
SELECT FamilyTraditions AS condition,'B' orderkey FROM FormAddendum fa WHERE fa.FamilyTraditions != '' AND id = @Id
UNION
SELECT LanguageBarriers AS condition,'C' orderkey FROM FormAddendum fa WHERE fa.LanguageBarriers != '' AND id = @Id
UNION
SELECT VisualLimitations AS condition,'D' orderkey FROM FormAddendum fa WHERE fa.VisualLimitations != '' AND id = @Id
UNION
SELECT HearingDeficits AS condition,'E' orderkey FROM FormAddendum fa WHERE fa.HearingDeficits != '' AND id = @Id
UNION
SELECT Literacy AS condition,'E' orderkey FROM FormAddendum fa WHERE fa.Literacy != '' AND id = @Id
) x ORDER BY orderkey
END
ELSE
if(@casename ='Caregiver assessment')
BEGIN
SELECT * FROM (
SELECT Member AS condition,'A' orderkey FROM FormAddendum fa WHERE fa.Member != '' AND id = @Id
UNION
SELECT Caregiver AS condition,'B' orderkey FROM FormAddendum fa WHERE fa.Caregiver != '' AND id = @Id
UNION
SELECT Training AS condition,'C' orderkey FROM FormAddendum fa WHERE fa.Training != '' AND id = @Id
UNION
SELECT Assistance AS condition,'D' orderkey FROM FormAddendum fa WHERE fa.Assistance != '' AND id = @Id
UNION
SELECT UnclearCaregiver AS condition,'E' orderkey FROM FormAddendum fa WHERE fa.UnclearCaregiver != '' AND id = @Id
UNION
SELECT AssistanceNeeded AS condition,'E' orderkey FROM FormAddendum fa WHERE fa.AssistanceNeeded != '' AND id = @Id
) x ORDER BY orderkey
END

ELSE
if(@casename ='Assessment of available community')
BEGIN
SELECT * FROM (
SELECT Eligibility AS condition,'A' orderkey FROM FormAddendum fa WHERE fa.Eligibility != '' AND id = @Id
UNION
SELECT BehavioralHealth AS condition,'B' orderkey FROM FormAddendum fa WHERE fa.BehavioralHealth != '' AND id = @Id
UNION
SELECT LongTerm AS condition,'C' orderkey FROM FormAddendum fa WHERE fa.LongTerm != '' AND id = @Id
UNION
SELECT Rehabilitative AS condition,'D' orderkey FROM FormAddendum fa WHERE fa.Rehabilitative != '' AND id = @Id
UNION
SELECT PalliativeCare AS condition,'E' orderkey FROM FormAddendum fa WHERE fa.PalliativeCare != '' AND id = @Id
UNION
SELECT HomeHealth AS condition,'E' orderkey FROM FormAddendum fa WHERE fa.HomeHealth != '' AND id = @Id
) x ORDER BY orderkey
END