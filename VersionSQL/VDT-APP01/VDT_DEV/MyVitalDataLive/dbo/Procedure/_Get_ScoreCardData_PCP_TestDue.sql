/****** Object:  Procedure [dbo].[_Get_ScoreCardData_PCP_TestDue]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/9/2013
-- Description:	Retrieves summary percentages per Hedis test
-- =============================================
CREATE PROCEDURE [dbo].[_Get_ScoreCardData_PCP_TestDue]
	@PCP_NPI varchar(20),
	@PCP_GroupID int ,
	@CustID int ,
	@UserType varchar(50),
	@LOB varchar(50) = 'ALL' 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TIN  varchar(20) = null

	If (@CustID != 11)  --- Driscoll is the only SSO user at this time
	BEGIN

		--Select @TIN = MDGroupID from [dbo].[MDUser] a
		--join [Link_MDAccountGroup] b
		--on a.ID = b.MDAccountID
		--where username = @EMS

		SET @TIN = @PCP_GroupID
	END

	exec [dbo].[_Get_HEDIS_Summary_PlanLink]  @CustID,@LOB, @PCP_NPI, @PCP_GroupID
END