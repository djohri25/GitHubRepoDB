/****** Object:  Procedure [dbo].[Get_MemberRxInteraction_Old]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[Get_MemberRxInteraction_Old]
(
		@MedRecs [dbo].[MedRec] READONLY
)
AS
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
	left(F.[NDC],9) as NDC9,
	F.[GCN_SEQNO],
	G.[DDI_Codex],
	D.[DDI_MONOX],
	D.[DDI_SL]
	INTO
	#PatientMeds 
	FROM
	@MedRecs mr
	LEFT OUTER JOIN	[FirstDataBankDB].[dbo].[RNDC14_NDC_MSTR] F
	ON LEFT( F.NDC, 9 ) = LEFT( mr.NDC, 9 )
	LEFT OUTER JOIN [FirstDataBankDB].[dbo].[RADIMGC4_GCNSEQNO_LINK] G on G.GCN_SEQNO = F.GCN_SEQNO 
	LEFT OUTER JOIN [FirstDataBankDB].[dbo].RADIMMA5_MSTR D on D.DDI_CODEX = G.DDI_Codex
	WHERE
	D.DDI_SL < 3;

	-- look for drug interactions by using a cross join
	-- interaction rule is FDB version 2; MONOX match and CODEX does not

	DROP TABLE IF EXISTS #PatientMedInteractions;
	SELECT DISTINCT
	c.NDC9 as FirstNDC,
	s.NDC9 as SecondNDC,
	c.DDI_MONOX, c.DDI_SL
	into
	#PatientMedInteractions
	FROM
	#PatientMeds c
       CROSS JOIN #PatientMeds s
	WHERE
	C.NDC9 != s.NDC9
	AND C.DDI_MONOX = S.DDI_MONOX
	AND C.DDI_CODEX != S.DDI_CODEX
	AND c.NDC9 < s.NDC9;

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
	ON LEFT(F1.NDC,9) = D.FirstNDC
	LEFT OUTER JOIN [FirstDataBankDB].[dbo].[RNDC14_NDC_MSTR] F2
	ON LEFT(F2.NDC,9) = D.SecondNDC
	WHERE
	M.IAMIDENTN != 'R' 
	ORDER BY
	DDI_SL,
	FirstNDC,
	SecondNDC,
	M.DDI_MONOX,
	M.ADI_MONOSN;

	-- generate the output to the requester
	SELECT
	*
	FROM
	#RXInteractionReport;
END