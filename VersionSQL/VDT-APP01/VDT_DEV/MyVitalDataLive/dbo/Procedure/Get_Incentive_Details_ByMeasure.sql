/****** Object:  Procedure [dbo].[Get_Incentive_Details_ByMeasure]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_Incentive_Details_ByMeasure]
	@CustID int,
	@Measure varchar(20),
	@TIN varchar(50),
	@Year varchar(4)

AS
BEGIN

	DECLARE @MonthID varchar(20), @TestID int

	SELECT @MonthID = CAST(@Year AS VARCHAR(10)) + '12'

	--This is a patch, we need to remove it!
	--the patch is done so that we do not show data for the new year before we are ready to do so
	SELECT @MonthID = '201712'
	
	SELECT @TestID = [ID]
	FROM [dbo].[LookupHedis]
	WHERE [Abbreviation] = @Measure

	SELECT 
		[MemberID]
		,[MemberLastName]
		,[MemberFirstName]
		,[DOB]
		,CASE [IsTestDue] WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END AS Complete
		,CASE [LOB] WHEN 'M' THEN 'STAR' WHEN 'C' THEN 'CHIP' WHEN 'K' THEN 'STAR KIDS' END AS LOB
	FROM [dbo].[Final_HEDIS_Member_FULL]
	WHERE [CustID] = @CustID
		AND [MonthID] = @MonthID
		AND [TestID] = @TestID
		AND [PCP_TIN] = @TIN
		AND LOB != 'K'
END