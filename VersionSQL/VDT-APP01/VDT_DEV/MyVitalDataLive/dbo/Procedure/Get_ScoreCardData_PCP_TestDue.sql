/****** Object:  Procedure [dbo].[Get_ScoreCardData_PCP_TestDue]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_ScoreCardData_PCP_TestDue]
	@PCP_NPI varchar(20),
	@PCP_GroupID int ,
	@CustID int ,
	@UserType varchar(50),
	@LOB varchar(50) = 'ALL' ,
	@MonthID	char(6)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TIN  varchar(20) = null

	IF @LOB='ALL' AND @PCP_NPI='' AND @PCP_GroupID=35828 AND @CustID=10 AND @UserType='HP' AND @MonthID='201805'
	BEGIN
		SELECT testID,testAbbr,testName,FullTestName,testType,PrevYearPerc,CurYearToDatePerc,CurYearOverall,GoalPerc,AvgMonthlyDifference,QualifyingMemCount
		,CompletedMemCount,DueMemCount,YearToDateGoalStatus,CurYearOverallGoalStatus,PCP_NPI,PCP_GroupID,CustID,duration,MonthID
		FROM dbo.ScoreCardCacheForDemo

		RETURN
	END

	If (@CustID != 11)  --- Driscoll is the only SSO user at this time
	BEGIN

		--Select @TIN = MDGroupID from [dbo].[MDUser] a
		--join [Link_MDAccountGroup] b
		--on a.ID = b.MDAccountID
		--where username = @EMS

		SET @TIN = @PCP_GroupID
	END

	exec [dbo].[Get_HEDIS_Summary_PlanLink] @CustID, @LOB, @PCP_NPI, @PCP_GroupID, @MonthID	
END