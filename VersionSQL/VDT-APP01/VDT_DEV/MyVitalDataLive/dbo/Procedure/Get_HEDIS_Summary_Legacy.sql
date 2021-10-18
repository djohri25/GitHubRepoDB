/****** Object:  Procedure [dbo].[Get_HEDIS_Summary_Legacy]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Changes:	05/08/2018	MDeLuca	Added calls by @LOB
-- =============================================
CREATE PROCEDURE [dbo].[Get_HEDIS_Summary_Legacy]
	@CustID int,
	@TIN varchar(50),
	@NPI varchar(50),
	@LOB varchar(50) = 'ALL',
	@MonthID char(6) = NULL,
	@EMS varchar(50) = NULL,
	@UserID_SSO varchar(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @MonthID IS NULL
		SELECT @MonthID = MAX(MonthID) FROM dbo.Final_HEDIS_Member_FULL WHERE CustID = @CustID

	DECLARE @ID int, @Abbreviation varchar(50)
	DECLARE @Abbreviations TABLE (ID int Identity (1,1), Abbreviation varchar(50), LOB VARCHAR(10))
	CREATE TABLE #TEMP_RESULTS
	(testID INT, testAbbr VARCHAR(10), testName VARCHAR(100), isIncentive bit, PrevYearPerc DECIMAL(8,2), CurYearToDatePerc DECIMAL(8,2), CurYearOverall DECIMAL(8,2), GoalPerc DECIMAL(8,2), QualifyingMemCount INT, CompletedMemCount INT, DueMemCount INT, YearToDateGoalStatus INT, CurYearOverallGoalStatus INT, MonthID CHAR(6))
	
	--Plan Link
	IF (@EMS IS NULL AND @UserID_SSO IS NULL)
	BEGIN
	INSERT INTO @Abbreviations (Abbreviation, LOB)
		SELECT a.Abbreviation, ISNULL(b.LOB, 'ALL')
		FROM [dbo].[HedisSubmeasures] a
		INNER JOIN [dbo].[HedisScorecard] b ON a.ID = b.SubmeasureID
		LEFT JOIN [dbo].[HedisScorecard_TIN] d ON b.ID = d.ScoreCardID AND ISNULL(d.TIN, 0) = @TIN
		WHERE b.CustID = @CustID
			AND (ISNULL(b.PlanLink_Active, 0) = 1 OR ISNULL(d.PlanLink_Active, 0) = 1)
		ORDER BY Abbreviation
	END
	--DR Link
	ELSE
	BEGIN
		INSERT INTO @Abbreviations (Abbreviation, LOB)
		SELECT a.Abbreviation,ISNULL(b.LOB, 'ALL')
		FROM [dbo].[HedisSubmeasures] a
		INNER JOIN [dbo].[HedisScorecard] b ON a.ID = b.SubmeasureID
		RIGHT JOIN [dbo].[HedisMeasures] c ON a.MeasureID = c.ID
		LEFT JOIN [dbo].[HedisScorecard_TIN] d ON b.ID = d.ScoreCardID AND ISNULL(d.TIN, 0) = @TIN
		WHERE b.CustID = @CustID
			AND (ISNULL(b.DRLink_Active, 0) = 1 OR ISNULL(d.DRLink_Active, 0) = 1)
		ORDER BY Abbreviation
	END

	WHILE EXISTS (SELECT TOP 1 * FROM @Abbreviations)
	BEGIN
		SELECT TOP 1  @ID = ID, @Abbreviation = Abbreviation, @LOB = LOB FROM @Abbreviations
		
		INSERT #TEMP_RESULTS
			EXEC [dbo].[Get_HEDIS_Summary_ByMeasure_Legacy] @Abbreviation = @Abbreviation, @CustID = @CustID, @LOB = @LOB, @NPI = @NPI, @TIN = @TIN, @MonthID = @MonthID

		DELETE @Abbreviations WHERE ID = @ID
	END

	IF (ISNULL(@EMS, '') != '' OR ISNULL(@UserID_SSO, '') != '')
	BEGIN
		-- Record SP Log
		DECLARE @params nvarchar(1000) = null
		SET @params = '@NPI=' + @NPI + ';' +
					  '@LOB=' + @LOB + ';' +
					  '@CustID=' + CONVERT(varchar(50), @CustID) + ';' +
					  '@TIN=' + ISNULL(@TIN, 'null') + ';' +
					  '@MonthID=' + ISNULL(@MonthID, 'null') + ';'
		EXEC [dbo].[Set_StoredProcedures_Log] '[dbo].[Get_HEDIS_Summary]', @EMS, @UserID_SSO, @params
	END

	SELECT * FROM #TEMP_RESULTS
END