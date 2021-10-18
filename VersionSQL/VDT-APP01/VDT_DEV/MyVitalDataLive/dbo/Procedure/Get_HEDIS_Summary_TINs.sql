/****** Object:  Procedure [dbo].[Get_HEDIS_Summary_TINs]    Committed by VersionSQL https://www.versionsql.com ******/

-- =========================================================
-- Author:		Misha
-- Create date: 05/09/2017
-- Description:	Data for TIN-level Scorecard
-- =========================================================
CREATE PROCEDURE [dbo].[Get_HEDIS_Summary_TINs]
	@Abbreviation varchar(20),
	@CustID int = 0,
	@MonthID char(6) = NULL,
	@LOB varchar(50) = 'ALL',
	@User varchar(50) = NULL, --TODO: add User
	@Page int = 1,
	@RecsPerPage int = NULL,
	@SortBy varchar(50) = 'EntityID',
	@SortDirection varchar(10) = 'asc',
	@TotalRecords int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Count int = 0
	DECLARE @ID int, @EntityID varchar(50)
	DECLARE @TestID int, @MonthID_Check	char(6)
	DECLARE @Entities TABLE (ID int Identity (1,1), EntityID varchar(50), EntityName varchar(100))
	DECLARE @EntitiesFinal TABLE (ID int Identity (1,1), EntityID varchar(50))
	CREATE TABLE #TEMP_RESULTS
	(EntityID VARCHAR(50), EntityName VARCHAR(250), PrevYearPerc DECIMAL(8,2), CurYearToDatePerc DECIMAL(8,2), CurYearOverall DECIMAL(8,2), QualifyingMemCount INT, CompletedMemCount INT, DueMemCount INT, YearToDateGoalStatus INT, CurYearOverallGoalStatus INT, MonthID CHAR(6))
	CREATE TABLE #TEMP_RESULTS_FINAL
	(EntityID VARCHAR(50), EntityName VARCHAR(250), PrevYearPerc DECIMAL(8,2), CurYearToDatePerc DECIMAL(8,2), CurYearOverall DECIMAL(8,2), QualifyingMemCount INT, CompletedMemCount INT, DueMemCount INT, YearToDateGoalStatus INT, CurYearOverallGoalStatus INT, MonthID CHAR(6))

	SELECT @TestID = [ID]
	FROM [dbo].[HedisSubmeasures]
	WHERE [Abbreviation] = @Abbreviation

	SELECT @MonthID_Check = Max(MonthID)
	FROM [dbo].[Final_HEDIS_Member_FULL]
	WHERE CustID = @CustID
		AND [TestID] = @TestID

	IF (@MonthID IS NULL OR @MonthID > @MonthID_Check)
	BEGIN
		SET @MonthID = @MonthID_Check
	END

	INSERT INTO @Entities
	SELECT DISTINCT a.PCP_TIN AS EntityID, b.SecondaryName AS EntityName
	FROM [dbo].[Final_HEDIS_Member_FULL] a
		INNER JOIN [dbo].[MDGroup] b ON a.PCP_TIN = b.GroupName AND [CustID_Import] = @CustID
	WHERE a.[CustID] = @CustID
		AND a.[MonthID]= @MonthID
		AND a.[TestID] = @TestID
		AND a.[PCP_TIN] NOT IN ('dchpbeta1', 'dchpbeta2', 'dchpbeta3', 'XXXXXXXXX')

	SET @Count = (SELECT COUNT(*) FROM @Entities)

	--Pagination & Sorting (parameters that can be determined before calculations)
	IF (@SortBy IN ('EntityID', 'EntityName'))
	BEGIN
		;WITH PostCTE AS 
		(
			SELECT EntityID, ROW_NUMBER() OVER
				(ORDER BY
					CASE WHEN @SortDirection = 'ASC' THEN
						CASE @SortBy
							WHEN 'EntityID' THEN EntityID
							WHEN 'EntityName' THEN EntityName
							ELSE EntityID
						END
					END ASC,
					CASE WHEN @SortDirection = 'DESC' THEN
					CASE @SortBy
							WHEN 'EntityID' THEN EntityID
							WHEN 'EntityName' THEN EntityName
							ELSE EntityID
						END
					END DESC
				) AS RowNumber
			FROM @Entities
		)
		INSERT INTO @EntitiesFinal
		SELECT EntityID
		FROM PostCTE
		WHERE RowNumber > ((@Page - 1) * ISNULL(@RecsPerPage, 0)) AND RowNumber <= (((@Page - 1) * ISNULL(@RecsPerPage, 0)) + ISNULL(@RecsPerPage, 100000))
	END
	ELSE
	BEGIN
		INSERT INTO @EntitiesFinal
		SELECT EntityID
		FROM @Entities
		ORDER BY EntityID
	END

	WHILE EXISTS (SELECT TOP 1 ID FROM @EntitiesFinal)
	BEGIN
		SELECT TOP 1 @ID = ID, @EntityID = EntityID FROM @EntitiesFinal
		
		INSERT #TEMP_RESULTS
			EXEC [dbo].[Get_HEDIS_Summary_ByTIN] @Abbreviation = @Abbreviation, @CustID = @CustID, @LOB = @LOB, @TIN = @EntityID, @MonthID = @MonthID

		DELETE @EntitiesFinal WHERE ID = @ID
	END

	--Pagination & Sorting (values in these columns can only be retrieved after the calculations)
	IF (@SortBy IN ('PrevYearPerc', 'CurYearToDatePerc', 'CurYearOverall', 'QualifyingMemCount', 'CompletedMemCount', 'DueMemCount', 'YearToDateGoalStatus', 'CurYearOverallGoalStatus'))
	BEGIN
		;WITH PostCTE AS
		(
			SELECT *, ROW_NUMBER() OVER
				(ORDER BY
					CASE WHEN @SortDirection = 'ASC' THEN
						CASE @SortBy
							WHEN 'PrevYearPerc' THEN CAST(PrevYearPerc AS DECIMAL(8,2))
							WHEN 'CurYearToDatePerc' THEN CAST(CurYearToDatePerc AS DECIMAL(8,2))
							WHEN 'CurYearOverall' THEN CAST(CurYearOverall AS DECIMAL(8,2))
							WHEN 'QualifyingMemCount' THEN CAST(QualifyingMemCount AS DECIMAL(8,2))
							WHEN 'CompletedMemCount' THEN CAST(CompletedMemCount AS DECIMAL(8,2))
							WHEN 'DueMemCount' THEN CAST(DueMemCount AS DECIMAL(8,2))
							WHEN 'YearToDateGoalStatus' THEN CAST(YearToDateGoalStatus AS DECIMAL(8,2))
							WHEN 'CurYearOverallGoalStatus' THEN CAST(CurYearOverallGoalStatus AS DECIMAL(8,2))
						END
					END ASC,
					CASE WHEN @SortDirection = 'DESC' THEN
					CASE @SortBy
							WHEN 'PrevYearPerc' THEN CAST(PrevYearPerc AS DECIMAL(8,2))
							WHEN 'CurYearToDatePerc' THEN CAST(CurYearToDatePerc AS DECIMAL(8,2))
							WHEN 'CurYearOverall' THEN CAST(CurYearOverall AS DECIMAL(8,2))
							WHEN 'QualifyingMemCount' THEN CAST(QualifyingMemCount AS DECIMAL(8,2))
							WHEN 'CompletedMemCount' THEN CAST(CompletedMemCount AS DECIMAL(8,2))
							WHEN 'DueMemCount' THEN CAST(DueMemCount AS DECIMAL(8,2))
							WHEN 'YearToDateGoalStatus' THEN CAST(YearToDateGoalStatus AS DECIMAL(8,2))
							WHEN 'CurYearOverallGoalStatus' THEN CAST(CurYearOverallGoalStatus AS DECIMAL(8,2))
						END
					END DESC
				) AS RowNumber
			FROM #TEMP_RESULTS
		)
		INSERT INTO #TEMP_RESULTS_FINAL
		SELECT EntityID, EntityName, PrevYearPerc, CurYearToDatePerc, CurYearOverall, QualifyingMemCount, CompletedMemCount, DueMemCount, YearToDateGoalStatus, CurYearOverallGoalStatus, MonthID
		FROM PostCTE
		WHERE RowNumber > ((@Page - 1) * ISNULL(@RecsPerPage, 0)) AND RowNumber <= (((@Page - 1) * ISNULL(@RecsPerPage, 0)) + ISNULL(@RecsPerPage, 100000))
	END
	ELSE
	BEGIN
		INSERT INTO #TEMP_RESULTS_FINAL
		SELECT *
		FROM #TEMP_RESULTS
	END

	SET @TotalRecords = @Count
	SELECT * FROM #TEMP_RESULTS_FINAL
END