/****** Object:  Procedure [dbo].[Get_MedEducationSheets]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE

[dbo].[Get_MedEducationSheets]

(

@MedRecs [dbo].[MedRecExt] READONLY

)

AS

BEGIN

DECLARE @DBName varchar(50) = 'FirstDataBankDB'



-- SET NOCOUNT ON added to prevent extra result sets from

-- interfering with SELECT statements.

SET NOCOUNT ON;



-- get the GCN_SEQNO code and DDI Codex value for the NDC-9 values into temp table

-- only include severity 1 and 2 ie. contraindicated and severe levels



DROP TABLE IF EXISTS #PatientMeds;

SELECT DISTINCT

left(F.[NDC],9) as NDC9,

F.BN,

F.[GCN_SEQNO],

G.PEMONO

INTO

#PatientMeds 

FROM

@MedRecs mr

JOIN [FirstDataBankDB].[dbo].[RNDC14_NDC_MSTR] F ON LEFT( F.NDC, 9 ) = LEFT( mr.NDC, 9 )

JOIN [FirstDataBankDB].[dbo].RPEMOGC0_MONO_GCNSEQNO_LINK G on G.GCN_SEQNO = F.GCN_SEQNO 



-- look for drug education based on Patient Education Standard Monograph

DROP TABLE IF EXISTS #MedEducation;

select distinct M.BN, MONO.PEMONOE_SN, MONO.PEMTXTEI, MONO.PEMTXTE

into #MedEducation

from [FirstDataBankDB].[dbo].RPEMMOE2_MONO MONO

JOIN #PatientMeds M on M.PEMONO = MONO.PEMONO



-- generate the output to the requester

SELECT

ME.BN, PEMONOE_SN, PEMTXTEI, PEMTXTE

FROM

#MedEducation ME

order by ME.BN, PEMONOE_SN, PEMTXTEI

END