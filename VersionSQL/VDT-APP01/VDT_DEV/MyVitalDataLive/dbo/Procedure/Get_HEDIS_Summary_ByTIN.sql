/****** Object:  Procedure [dbo].[Get_HEDIS_Summary_ByTIN]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_HEDIS_Summary_ByTIN]
	@Abbreviation varchar(50),
	@CustID int,
	@LOB varchar(50) = 'ALL',
	@TIN varchar(50), --Since it is by TIN there has to be a TIN
	@MonthID char(6)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Total int, @Complete int, @Due int, @MonthID_Check	char(6), @LastYear_MonthID char(6), @PrevYearPerc DECIMAL(8,2), @PrevYear_Total DECIMAL(8,2), @PrevYear_Complete DECIMAL(8,2)
	DECLARE @SubmeasureID int, @TestGoal DECIMAL(8,2)
	DECLARE @EntityID varchar(50), @EntityName varchar (250)
	DECLARE @CurYearToDatePerc decimal(8,4), @CurYearOverall decimal(8,4), @YTD_Goal_Status int, @Year_Overall_Status int

	SELECT @SubmeasureID = [ID], @LastYear_MonthID = [MeasurementEnd]
	FROM [dbo].[HedisSubmeasures]
	WHERE [Abbreviation] = @Abbreviation

	SELECT @EntityID = GroupName, @EntityName = SecondaryName
	FROM [dbo].[MDGroup]
	WHERE [CustID_Import] = @CustID
		AND GroupName = @TIN

	SELECT @TestGoal = [Goal]
	FROM [dbo].[HedisScorecard]
	WHERE CustID = @CustID
		AND SubmeasureID = @SubmeasureID

	SELECT @MonthID_Check = Max(MonthID)
	FROM [dbo].[Final_HEDIS_Member_FULL]
	WHERE CustID = @CustID
		AND [TestID] = @SubmeasureID

	IF (@MonthID IS NULL OR @MonthID > @MonthID_Check)
	BEGIN
		SET @MonthID = @MonthID_Check
	END

	SET @LastYear_MonthID = CAST((CAST(LEFT(@MonthID, 4) AS int) - 1) AS char(4)) + LEFT(@LastYear_MonthID, 2)

	SELECT @LOB = (CASE WHEN @LOB = '' THEN 'ALL' ELSE @LOB END)
	SELECT @TIN = (CASE WHEN @TIN = '' THEN 'ALL' ELSE @TIN END)

	SELECT @PrevYear_Total = 0 
	SELECT @PrevYear_Complete = 0

	IF (@MonthID IS NOT NULL)
	BEGIN
		--This Year
		IF (@MonthID = @MonthID_Check)
		BEGIN
			SELECT @Total = Count(ID) FROM [dbo].[Final_HEDIS_Member]
			WHERE CustID = @CustID
				AND [TestID] = @SubmeasureID
				AND ([LOB] = @LOB OR @LOB = 'ALL')
				AND ([PCP_TIN] = @TIN OR @TIN = 'ALL')

			SELECT @Complete = Count(ID) FROM [dbo].[Final_HEDIS_Member]
			WHERE CustID = @CustID
				AND [IsTestDue] = 1
				AND [TestID] = @SubmeasureID
				AND ([LOB] = @LOB OR @LOB = 'ALL')
				AND ([PCP_TIN] = @TIN OR @TIN = 'ALL')
		END
		ELSE
		BEGIN
			SELECT @Total = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
			WHERE CustID = @CustID
				AND MonthID = @MonthID
				AND [TestID] = @SubmeasureID
				AND ([LOB] = @LOB OR @LOB = 'ALL')
				AND ([PCP_TIN] = @TIN OR @TIN = 'ALL')

			SELECT @Complete = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
			WHERE CustID = @CustID
				AND [IsTestDue] = 1
				AND MonthID = @MonthID
				AND [TestID] = @SubmeasureID
				AND ([LOB] = @LOB OR @LOB = 'ALL')
				AND ([PCP_TIN] = @TIN OR @TIN = 'ALL')
		END

		--Previous Year
		SELECT @PrevYear_Total = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
		WHERE CustID = @CustID
			AND MonthID = @LastYear_MonthID
			AND [TestID] = @SubmeasureID
			AND ([LOB] = @LOB OR @LOB = 'ALL')
			AND ([PCP_TIN] = @TIN OR @TIN = 'ALL')

		SELECT @PrevYear_Complete = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
		WHERE CustID = @CustID
			AND [IsTestDue] = 1
			AND MonthID = @LastYear_MonthID
			AND [TestID] = @SubmeasureID
			AND ([LOB] = @LOB OR @LOB = 'ALL')
			AND ([PCP_TIN] = @TIN OR @TIN = 'ALL')
			
		SELECT @Due = @Total - @Complete
	END

	SELECT @CurYearToDatePerc = 0

	IF (ISNULL(@Complete, 0) > 0)
	BEGIN
		SELECT @CurYearToDatePerc = (CONVERT(decimal(18,4), @Complete) / CONVERT(decimal(18,4), NULLIF(@Total, 0))) * 100
	END
	
	IF (@CurYearToDatePerc < @TestGoal)
	BEGIN
		SELECT @YTD_Goal_Status = -1
	END
	ELSE
	BEGIN
		SELECT @YTD_Goal_Status = 1
	END

	-- Added 12/28/2017
IF LEFT(@MonthID,4) < YEAR(GETDATE())
	BEGIN
		SELECT @CurYearOverall = ISNULL((SUM(CAST(IsTestDue AS INT)) /  CAST(COUNT(*) AS decimal(8,2))) * 100, 0.00)
		FROM dbo.Final_HEDIS_Member_FULL
		WHERE CustID = @CustID
		AND TestID = @SubmeasureID
		AND (NULLIF(NULLIF(@TIN,''),'All') IS NULL OR PCP_TIN = @TIN)
		AND MonthID = (SELECT MAX(MonthID) FROM dbo.Final_HEDIS_Member_FULL WHERE CustID = @CustID AND LEFT(MonthID,4) = LEFT(@MonthID,4) AND TestID = @SubmeasureID)
	END
	ELSE
	EXEC Get_HEDIS_CurYearOverallPercentage	
		@TestID = @SubmeasureID,
		@TIN = @TIN,
		@CustID = @CustID,
		@NPI = 'ALL',
		@PCP_GroupID = NULL,
		@CurYearToDatePerc = @CurYearToDatePerc,
		@YearOverallPercentage = @CurYearOverall output

	IF (@CurYearOverall < @TestGoal)
	BEGIN
		SELECT @Year_Overall_Status = -1
	END
	ELSE
	BEGIN
		SELECT @Year_Overall_Status = 1
	END

	If (ISNULL(@PrevYear_Complete, 0) > 0)
	BEGIN
		SELECT @PrevYearPerc = (@PrevYear_Complete / NULLIF(@PrevYear_Total, 0)) * 100
	END

	SELECT @EntityID AS EntityID,
		   @EntityName AS EntityName,
		   isnull(@PrevYearPerc, 0) AS PrevYearPerc,
		   isnull(@CurYearToDatePerc, 0) AS CurYearToDatePerc,
		   isnull(@CurYearOverall, 0) AS CurYearOverall,
		   @Total AS QualifyingMemCount,
		   @Complete AS CompletedMemCount,
		   @Due AS DueMemCount,
		   @YTD_Goal_Status AS YearToDateGoalStatus,
		   @Year_Overall_Status AS CurYearOverallGoalStatus,
		   @MonthID as MonthID
END