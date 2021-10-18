/****** Object:  Procedure [dbo].[Get_RxByName]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Updated: 9/4/20
-- Description:	Provides search result for medicine name
--						Includes look up for medical marijuana
-- mgrover	2021-08-04	Modify search to sort by NDC number length and then by position of search term in name. Increased output to top 50
-- =============================================
CREATE PROCEDURE [dbo].[Get_RxByName]
	@MedName varchar(MAX) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @SQL varchar(MAX) = ''

	IF ( @MedName IS NULL )
	BEGIN
		RETURN -1;
	END;

	CREATE TABLE #RxRESULTS(LN NVARCHAR(300), NDC VARCHAR(250))

	SELECT @SQL = 'INSERT  INTO #RxRESULTS SELECT TOP 40 min(n.NDC) As NDC, n.LN 
	FROM FirstDataBankDB.dbo.RNDC14_NDC_MSTR n 
	WHERE 1=1'

	SELECT @SQL = @SQL + ' AND n.LN LIKE ''%' + value + '%'''
	FROM STRING_SPLIT(@MedName, ' ')

	SELECT @SQL = @SQL + ' GROUP BY n.LN'

	EXEC (@SQL)
	
	-- medical marijuana lookup
	SELECT @SQL = 'INSERT  INTO #RxRESULTS SELECT TOP 20 MIN(n.MEDID) As NDC, n.MED_MEDID_DESC As LN FROM FirstDataBankDB.dbo.RMIID1_MED n WHERE 1=1' 

	SELECT @SQL = @SQL + ' AND n.MED_MEDID_DESC LIKE ''%' + value + '%'''
	FROM STRING_SPLIT(@MedName, ' ')

	SELECT @SQL = @SQL + ' GROUP BY n.MED_MEDID_DESC'

	EXEC (@SQL)
	
	SELECT top 50 LN, NDC
	FROM #RxRESULTS
	--ORDER BY NDC
	ORDER BY len(ln) desc, charindex(@MedName,NDC)

	DROP TABLE #RxRESULTS
END