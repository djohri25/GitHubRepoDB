/****** Object:  Procedure [dbo].[setPDFLabeltextPEPP]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[setPDFLabeltextPEPP]
@Id int,@casename varchar(500)

as

if(@casename ='Call your doctor')
BEGIN
SELECT * FROM 
(SELECT FeverOver100  AS condition,'A' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.FeverOver100 != '' AND id = @Id
UNION
SELECT PersistentNausea  AS condition,'B' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE PersistentNausea != '' AND id = @Id
UNION
SELECT PainBurningUrination  AS condition,'C' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.PainBurningUrination != '' AND id = @Id
UNION
SELECT SwellingInLegs  AS condition,'D' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.SwellingInLegs != '' AND id = @Id
UNION
SELECT ChestPain  AS condition,'E' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.ChestPain != '' AND id = @Id
UNION
SELECT LocalizedPain  AS condition,'F' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.LocalizedPain != '' AND id = @Id
UNION
SELECT PersistentPerinealPain  AS condition,'G' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.PersistentPerinealPain != '' AND id = @Id
UNION
SELECT IncreasedPainAfterCSection  AS condition,'H' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.IncreasedPainAfterCSection != '' AND id = @Id
UNION
SELECT FoulSmellingDischarge  AS condition,'I' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.FoulSmellingDischarge != '' AND id = @Id
UNION
SELECT BrightRedBleeding  AS condition,'J' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.BrightRedBleeding != '' AND id = @Id
UNION
SELECT PostPartumDepression  AS condition,'K' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.PostPartumDepression != '' AND id = @Id

) x ORDER BY orderkey
END
ELSE
if(@casename = 'Other Instructions')
BEGIN
SELECT * FROM 
(
SELECT NothingInVagina  AS condition,'L' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.NothingInVagina != '' AND id = @Id
UNION
SELECT NoDriving  AS condition,'M' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.NoDriving != '' AND id = @Id
UNION
SELECT TakeAllMedications  AS condition,'N' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.TakeAllMedications != '' AND id = @Id
) x ORDER BY orderkey
END
ELSE
if(@casename = 'Community Resources')
BEGIN
SELECT * FROM 
(
SELECT ReferToCommunityResources   AS condition,'O' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.ReferToCommunityResources != '' AND id = @Id
UNION
SELECT WIC  AS condition,'P' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.WIC != '' AND id = @Id
UNION
SELECT AnyBodyCan  AS condition,'Q' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.AnyBodyCan != '' AND id = @Id
UNION
SELECT Text4Baby  AS condition,'R' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.Text4Baby != '' AND id = @Id
UNION
SELECT Health4Mom  AS condition,'S' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.Health4Mom != '' AND id = @Id
UNION
SELECT HealthyChildren  AS condition,'T' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.HealthyChildren != '' AND id = @Id
UNION
SELECT YourTexasBenefits AS condition,'U' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.YourTexasBenefits != '' AND id = @Id
UNION
SELECT TexasHealthSteps  AS condition,'V' orderkey FROM FormPatientEducationPostPartum fpepp  WHERE fpepp.TexasHealthSteps != '' AND id = @Id
) x ORDER BY orderkey
END



--EXEC [dbo].[setPDFLabeltextPEDGeneralGuidelines]
--@Id = 1,@casename ='General Guidelines for Sick Day Management'