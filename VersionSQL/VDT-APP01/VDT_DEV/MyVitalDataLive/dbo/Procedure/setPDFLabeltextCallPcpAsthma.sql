/****** Object:  Procedure [dbo].[setPDFLabeltextCallPcpAsthma]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE procedure [dbo].[setPDFLabeltextCallPcpAsthma]
@Id int
as


SELECT DecreasePeakFlows  AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.DecreasePeakFlows != '' AND id = @Id
UNION
SELECT IncreaseAgitation AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.IncreaseAgitation != '' AND id = @Id
UNION
SELECT AsthmaAttackNotControlled AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.AsthmaAttackNotControlled != '' AND id = @Id
UNION
SELECT IncreasedNeedForMedication AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.IncreasedNeedForMedication != '' AND id = @Id
UNION
SELECT IncreaseAsthmaAttack AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.IncreaseAsthmaAttack != '' AND id = @Id
UNION
SELECT ControlStressFactorPCP AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.ControlStressFactorPCP != '' AND id = @Id
UNION
SELECT DecreaseActivityTolerance AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.DecreaseActivityTolerance != '' AND id = @Id
UNION
SELECT PersistentElevatedTemp AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.PersistentElevatedTemp != '' AND id = @Id
UNION
SELECT CoughProductive AS condition FROM FormPatientEducationAsthma fpea WHERE fpea.CoughProductive != '' AND id = @Id