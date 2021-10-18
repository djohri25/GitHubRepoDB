/****** Object:  Procedure [dbo].[Get_MemberRxInteraction]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE

[dbo].[Get_MemberRxInteraction]

(

@MedRecs [dbo].[MedRecExt] READONLY

)

AS

/** changed NDC9 to NDC11 MEG 2020-05-18 



Added concatenation to IAMTEXTN in output row for the IAMDENTIN 'T' - Title

Used FOR XML PATH instead of STRING_AGG because the server is v 2016 and not 2017

**/

BEGIN

DECLARE @DBName varchar(50) = 'FirstDataBankDB'



-- SET NOCOUNT ON added to prevent extra result sets from

-- interfering with SELECT statements.

SET NOCOUNT ON;

DECLARE @SQL_SCRIPT VARCHAR(MAX);



-- get the GCN_SEQNO code and DDI Codex value for the NDC-9 values into temp table

-- only include severity 1 and 2 ie. contraindicated and severe levels



DROP TABLE IF EXISTS #PatientMeds;

SELECT DISTINCT

F.[NDC] as NDC11,

F.[GCN_SEQNO],

G.[DDI_Codex],

D.[DDI_MONOX],

D.[DDI_SL]

INTO

#PatientMeds 

FROM

@MedRecs mr

LEFT OUTER JOIN [FirstDataBankDB].[dbo].[RNDC14_NDC_MSTR] F

ON F.NDC = mr.NDC

LEFT OUTER JOIN [FirstDataBankDB].[dbo].[RADIMGC4_GCNSEQNO_LINK] G on G.GCN_SEQNO = F.GCN_SEQNO 

LEFT OUTER JOIN [FirstDataBankDB].[dbo].RADIMMA5_MSTR D on D.DDI_CODEX = G.DDI_Codex

WHERE

D.DDI_SL < 3;


-- look for drug interactions by using a cross join

-- interaction rule is FDB version 2; MONOX match and CODEX does not



DROP TABLE IF EXISTS #PatientMedInteractions;

SELECT DISTINCT

c.NDC11 as FirstNDC,

s.NDC11 as SecondNDC,

c.DDI_MONOX, c.DDI_SL

into

#PatientMedInteractions

FROM

#PatientMeds c

CROSS JOIN #PatientMeds s

WHERE

C.NDC11 != s.NDC11

AND C.DDI_MONOX = S.DDI_MONOX

AND C.DDI_CODEX != S.DDI_CODEX

AND c.NDC11 < s.NDC11;



-- generate the final drug interaction monographs

-- order by severity level so that contraindications appear first

DROP TABLE IF EXISTS #RXInteractionReport;

SELECT DISTINCT

D.DDI_SL,

D.FirstNDC,

F1.BN as FirstMed,

D.SecondNDC,

F2.BN as SecondMed,

M.DDI_MONOX,

M.ADI_MONOSN,

M.IAMIDENTN,

M.IAMTEXTN 

INTO

#RXInteractionReport 

FROM

#PatientMedInteractions D

LEFT OUTER JOIN [FirstDataBankDB].[dbo].[RADIMMO5_MONO] M

ON M.DDI_MONOX = D.DDI_MONOX 

LEFT OUTER JOIN [FirstDataBankDB].[dbo].[RNDC14_NDC_MSTR] F1

ON F1.NDC = D.FirstNDC

LEFT OUTER JOIN [FirstDataBankDB].[dbo].[RNDC14_NDC_MSTR] F2

ON F2.NDC = D.SecondNDC

WHERE

M.IAMIDENTN != 'R' 

ORDER BY

DDI_SL,

FirstNDC,

SecondNDC,

M.DDI_MONOX,

M.ADI_MONOSN;



-- generate the output to the requester

--concatenate IAMTEXTN to one column and one row



SELECT DISTINCT DDI_SL,FirstNDC,FirstMed, SecondNDC, SecondMed, DDI_MONOX, 1 AS ADI_MONOSN, 'T' AS IAMDENTIN, 

STUFF((SELECT ' ' + IAMTEXTN AS [text()]

FROM #RXInteractionReport

WHERE FirstNDC = rx.FirstNDC AND SecondNDC = rx.SecondNDC 

AND IAMIDENTN = 'T'

ORDER BY ADI_MONOSN

FOR XML PATH('')), 1, 1, '' ) AS IAMTEXTN

FROM #RXInteractionReport rx

WHERE IAMIDENTN = 'T'



UNION



SELECT *--DDI_SL, FirstNDC, FirstMed, SecondNDC, SecondMed, DDI_MONOX, ADI_MONOSN, IAMIDENTN, IAMTEXTN

FROM

#RXInteractionReport

WHERE IAMIDENTN != 'T'

ORDER BY

DDI_SL,

FirstNDC,

SecondNDC,

DDI_MONOX,

ADI_MONOSN;



END