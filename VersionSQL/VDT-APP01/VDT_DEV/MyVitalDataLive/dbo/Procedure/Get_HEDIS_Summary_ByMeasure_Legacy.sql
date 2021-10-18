/****** Object:  Procedure [dbo].[Get_HEDIS_Summary_ByMeasure_Legacy]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Misha
-- Create date: 
-- Description:	
-- Modification:	MDeLuca	01/15/2018	Made changes for new Get_HEDIS_CurYearOverallPercentage
-- Changes:	05/08/2018	MDeLuca	Added calls by @LOB
-- =============================================
CREATE PROCEDURE [dbo].[Get_HEDIS_Summary_ByMeasure_Legacy]
	@Abbreviation varchar(50),
	@CustID int,
	@LOB varchar(50) = 'ALL',
	@NPI varchar(50) = 'ALL',
	@TIN varchar(50) = 'ALL',
	@MonthID char(6)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Total int, @Complete int, @Due int, @MonthID_Check	char(6), @LastYear_MonthID char(6), @PrevYearPerc DECIMAL(8,2), @PrevYear_Total DECIMAL(8,2), @PrevYear_Complete DECIMAL(8,2)
	DECLARE @SubmeasureID int, @SubmeasureName varchar (100), @TestGoal DECIMAL(8,2), @isIncentive bit
	DECLARE @CurYearToDatePerc decimal(8,4), @CurYearOverall decimal(8,4), @YTD_Goal_Status int, @Year_Overall_Status int
	DECLARE @MeasureEndMonth INT, @MeasureCycleEndDate DATE
	DECLARE @LOBDescription AS VARCHAR(50) = ''

	SELECT @MeasureEndMonth = MONTH(MeasuramentYearEnd)
	FROM [dbo].[LookupHedis]
	WHERE [Abbreviation] = @Abbreviation
	
	SET @MeasureCycleEndDate = DATEFROMPARTS(CASE WHEN @MeasureEndMonth < RIGHT(@MonthID,2) THEN LEFT(@MonthID,4) + 1 ELSE LEFT(@MonthID,4) END, @MeasureEndMonth, '01')
	
	SELECT @SubmeasureID = [ID], @SubmeasureName = [Name], @LastYear_MonthID = [MeasurementEnd]
	FROM [dbo].[HedisSubmeasures]
	WHERE [Abbreviation] = @Abbreviation

	SELECT @TestGoal = [Goal], @isIncentive = [isIncentive]
	FROM [dbo].[HedisScorecard]
	WHERE CustID = @CustID
		AND SubmeasureID = @SubmeasureID
		AND ISNULL(LOB, 'ALL') = @LOB

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
				AND ([PCP_NPI] = @NPI OR @NPI = 'ALL')
				AND ([PCP_TIN] = @TIN OR @TIN = 'ALL')

			SELECT @Complete = Count(ID) FROM [dbo].[Final_HEDIS_Member]
			WHERE CustID = @CustID
				AND [IsTestDue] = 1
				AND [TestID] = @SubmeasureID
				AND ([LOB] = @LOB OR @LOB = 'ALL')
				AND ([PCP_NPI] = @NPI OR @NPI = 'ALL')
				AND ([PCP_TIN] = @TIN OR @TIN = 'ALL')
		END
		ELSE
		BEGIN
			SELECT @Total = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
			WHERE CustID = @CustID
				AND MonthID = @MonthID
				AND [TestID] = @SubmeasureID
				AND ([LOB] = @LOB OR @LOB = 'ALL')
				AND ([PCP_NPI] = @NPI OR @NPI = 'ALL')
				AND ([PCP_TIN] = @TIN OR @TIN = 'ALL')

			SELECT @Complete = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
			WHERE CustID = @CustID
				AND [IsTestDue] = 1
				AND MonthID = @MonthID
				AND [TestID] = @SubmeasureID
				AND ([LOB] = @LOB OR @LOB = 'ALL')
				AND ([PCP_NPI] = @NPI OR @NPI = 'ALL')
				AND ([PCP_TIN] = @TIN OR @TIN = 'ALL')
		END

		--Previous Year
		SELECT @PrevYear_Total = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
		WHERE CustID = @CustID
			AND MonthID = @LastYear_MonthID
			AND [TestID] = @SubmeasureID
			AND ([LOB] = @LOB OR @LOB = 'ALL')
			AND ([PCP_NPI] = @NPI OR @NPI = 'ALL')
			AND ([PCP_TIN] = @TIN OR @TIN = 'ALL')

		SELECT @PrevYear_Complete = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
		WHERE CustID = @CustID
			AND [IsTestDue] = 1
			AND MonthID = @LastYear_MonthID
			AND [TestID] = @SubmeasureID
			AND ([LOB] = @LOB OR @LOB = 'ALL')
			AND ([PCP_NPI] = @NPI OR @NPI = 'ALL')
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
	IF @MeasureCycleEndDate < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), '01')
		BEGIN
				SELECT @CurYearOverall = (SUM(CAST(IsTestDue AS INT)) /  CAST(COUNT(*) AS DECIMAL(38,17))) * 100
				FROM dbo.Final_HEDIS_Member_FULL
				WHERE CustID = @CustID
				AND MonthID = CAST(YEAR(@MeasureCycleEndDate) AS CHAR(4)) + CASE WHEN LEN(@MeasureEndMonth) = 1 THEN '0'+CAST(@MeasureEndMonth AS CHAR(1)) ELSE CAST(@MeasureEndMonth AS CHAR(2)) END
				AND TestID = @SubmeasureID
				AND ([PCP_NPI] = @NPI OR @NPI = 'ALL')
				AND ([PCP_TIN] = @TIN OR @TIN = 'ALL')

				IF @CurYearOverall IS NULL
				SELECT @CurYearOverall = (SUM(CAST(IsTestDue AS INT)) /  CAST(COUNT(*) AS DECIMAL(38,17))) * 100
				FROM dbo.Final_HEDIS_Member_FULL
				WHERE CustID = @CustID
				AND MonthID = (SELECT MAX(MonthID) FROM dbo.Final_HEDIS_Member_FULL WHERE CustID = @CustID AND LEFT(MonthID,4) = LEFT(@MonthID,4) AND TestID = @SubmeasureID)
				AND TestID = @SubmeasureID
				AND ([PCP_NPI] = @NPI OR @NPI = 'ALL')
				AND ([PCP_TIN] = @TIN OR @TIN = 'ALL')
		END
		ELSE
		EXEC Get_HEDIS_CurYearOverallPercentage	
			@TestID = @SubmeasureID,
			@TIN = @TIN,
			@CustID = @CustID,
			@NPI = @NPI,
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

	SELECT @LOBDescription = [Label_Desc]
	FROM dbo.Lookup_Generic_Code
	WHERE [CodeTypeID] = 3
	AND [Cust_ID] = @CustID
	AND [Label] = @LOB
	
	SELECT @SubmeasureID AS testID,
		   @Abbreviation AS testAbbr,
		   @SubmeasureName+CASE WHEN @LOBDescription = '' THEN '' ELSE ' ('+ISNULL(@LOBDescription,'') +')' END AS testName,
		   @isIncentive as isIncentive,
		   isnull(@PrevYearPerc, 0) AS PrevYearPerc,
		   isnull(@CurYearToDatePerc, 0) AS CurYearToDatePerc,
		   isnull(@CurYearOverall, 0) AS CurYearOverall,
		   @TestGoal AS GoalPerc,
		   @Total AS QualifyingMemCount,
		   @Complete AS CompletedMemCount,
		   @Due AS DueMemCount,
		   @YTD_Goal_Status AS YearToDateGoalStatus,
		   @Year_Overall_Status AS CurYearOverallGoalStatus,
		   @MonthID as MonthID
END