/****** Object:  Procedure [dbo].[Get_MyPatientsDiseaseList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Changes: 05/08/2018	MDeLuca	Added: AND b.LOB IS NULL
-- =============================================
CREATE PROCEDURE [dbo].[Get_MyPatientsDiseaseList]
	@CustID int,
	@TIN varchar(50) = NULL,
	@User varchar(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TIN_Temp varchar(50)

	CREATE TABLE #TempValues (ID int, Name varchar(200), Abbreviation varchar(50), DRLink_BirthdayFilter bit DEFAULT 0) 

	--TIN
	SET @TIN_Temp = @TIN
	IF (@TIN IS NULL AND @User IS NOT NULL)
	BEGIN
		SELECT TOP 1 @TIN_Temp = TIN
		FROM [dbo].[Get_TinArray](@User, @TIN_Temp)
	END
	
	INSERT #TempValues
	SELECT a.ID, a.Name + ' (' + a.Abbreviation + ')' as Name, a.Abbreviation, b.DRLink_BirthdayFilter
	FROM [dbo].[HedisSubmeasures] a
	INNER JOIN [dbo].[HedisScorecard] b ON a.ID = b.SubmeasureID AND b.LOB IS NULL
	LEFT JOIN [dbo].[HedisScorecard_TIN] d ON b.ID = d.ScoreCardID AND ISNULL(d.TIN, 0) = @TIN_Temp
	WHERE b.CustID = @CustID
		AND (ISNULL(b.DRLink_Active, 0) = 1 OR ISNULL(d.DRLink_Active, 0) = 1)
	ORDER BY Abbreviation

	UPDATE #TempValues
	SET NAME = 'Patients w/Asthma'
	WHERE Abbreviation = 'AST'

	UPDATE #TempValues
	SET NAME = 'Patients w/Diabetes'
	WHERE Abbreviation = 'DIA'

	UPDATE #TempValues
	SET NAME = 'Full Panel List'
	WHERE Abbreviation = 'FPL'

	SELECT * FROM #TempValues

	DROP TABLE #TempValues
END