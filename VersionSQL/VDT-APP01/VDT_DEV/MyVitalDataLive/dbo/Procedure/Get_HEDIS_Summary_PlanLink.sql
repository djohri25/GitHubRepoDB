/****** Object:  Procedure [dbo].[Get_HEDIS_Summary_PlanLink]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Changes: 09/04/2018 MDelUca	Added IN ('Predictive', 'Real', '3Percent', '5Percent')
-- =============================================
CREATE PROCEDURE [dbo].[Get_HEDIS_Summary_PlanLink]
	(@CustID int,
	@LOB varchar(50) = 'ALL',
	@NPI varchar(50),
	@PCP_GroupID int = NULL,
	@MonthID	char(6))
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @PlanLInk_Active bit, @ID int, @Abbreviation varchar(50)
	DECLARE @Abbreviations TABLE (ID int Identity (1,1), Abbreviation varchar(50))

	--INSERT INTO @Abbreviations (Abbreviation)
	--VALUES ('AWC'), ('W34'), ('W15'), ('AMR'), ('PPC1'), ('PPC2'), ('URI'), ('FUH7'), ('FUH30'), ('CWP'),
	--	   ('ADD_Init'), ('ADD_CM'), ('CISCMB2'), ('CISCMB3'), ('CISCMB4'), ('CISCMB5'), ('CISCMB6'), ('CISCMB7'), ('CISCMB8'), ('CISCMB9'),
	--	   ('CISCMB10'), ('CISDTP'), ('CISHEPA'), ('CISHEPB'), ('CISHIB'), ('CISINFL'), ('CISMMR'), ('CISIPV'), ('CISPNEU'), ('CISROTA'),
	--	   ('CISVZV'), ('CDC1'), ('CDC4'), ('WCC1'), ('WCC2'), ('WCC3'), ('IMA1'), ('IMA2'), ('IMA3'), ('CBP'),
	--	   ('MMA1A'), ('MMA1B'), ('MMA2A'), ('MMA2B'), ('MMA3A'), ('MMA3B'), ('MMA4A'), ('MMA4B'), ('COL'), ('AAB'), ('CCS'), ('ABA'),
	--	   ('AMM1'), ('AMM2'), ('CDC2'), ('CDC3'), ('CDC7'), ('CDC9'), ('CDC10'), ('BCS')

	INSERT INTO @Abbreviations
	(Abbreviation)
	SELECT Abbreviation
	FROM [dbo].[LookupHedis]
	WHERE [TestType] IN ('Predictive', 'Real', '3Percent', '5Percent')
		AND [MeasuramentYearStart] IS NOT NULL
	ORDER BY Abbreviation

	CREATE TABLE #TEMP_RESULTS
	(testID INT, testAbbr VARCHAR(10), testName VARCHAR(100), FullTestName VARCHAR(200), testType VARCHAR(50), PrevYearPerc DECIMAL(8,2), CurYearToDatePerc DECIMAL(8,2), CurYearOverall DECIMAL(8,2), GoalPerc DECIMAL(8,2), AvgMonthlyDifference  DECIMAL(8,2) ,QualifyingMemCount INT, CompletedMemCount INT, DueMemCount INT, YearToDateGoalStatus INT, CurYearOverallGoalStatus INT ,PCP_NPI VARCHAR(50),	PCP_GroupID	 VARCHAR(50), CustID INT,duration VARCHAR(50),MonthID CHAR(6))

	WHILE EXISTS (SELECT TOP 1 * FROM @Abbreviations)
	BEGIN
		SELECT TOP 1  @ID = ID, @Abbreviation = Abbreviation FROM @Abbreviations

		SELECT @PlanLInk_Active = 0
		SELECT @PlanLInk_Active = [PlankLink_Active] FROM HPTestDueGoal WHERE CustID = @CustID AND TestDueID = (SELECT ID FROM [dbo].[LookupHedis] WHERE [Abbreviation] = @Abbreviation)
		IF (ISNULL(@PlanLInk_Active, 0) = 1)
		BEGIN
			INSERT #TEMP_RESULTS
				EXEC [dbo].[Get_HEDIS_Summary_ByMeasure_PlanLink] @Abbreviation =@Abbreviation, @CustID = @CustID, @LOB = @LOB, @NPI = @NPI, @PCP_GroupID = @PCP_GroupID, @MonthID = @MonthID
		END

		DELETE @Abbreviations WHERE ID = @ID
	END

	SELECT * FROM #TEMP_RESULTS

END