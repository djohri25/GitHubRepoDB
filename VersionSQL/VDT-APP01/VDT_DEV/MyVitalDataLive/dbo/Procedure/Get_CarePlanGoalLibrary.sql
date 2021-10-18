/****** Object:  Procedure [dbo].[Get_CarePlanGoalLibrary]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Example:		EXEC dbo.Get_CarePlanGoalLibrary @CustID = '11', @LibraryID = 1
-- Changes:		04/24/2017	Marc De Luca	Changes the old style joins to normal joins.  The SQL Server data migration assistant pointed this out.
-- =============================================

CREATE PROCEDURE [dbo].[Get_CarePlanGoalLibrary]
	@CustID varchar(4),
	@LibraryID int
AS

BEGIN

	SET NOCOUNT ON;

	SELECT 
	 b.[cpLibraryID] AS ID
	,[cpGoalLanguage] AS Language
	,[cpGoalProblemNumber] AS ProblemNum
	,[cpGoalNumber] AS GoalNum
	,[cpLongGoalText] AS LongGoals
	,[cpShortGoalText] AS ShortGoals
	,[cpInterventionsText] AS Interventions
	FROM [dbo].[LookupCarePlanLibrary] a
	JOIN [dbo].[LookupCarePlanGoalLibrary] b ON a.[cpLibraryID] = b.[cpLibraryID]
	WHERE a.[cpLibraryCustIDList] like '%' + @CustID + '%'
	AND a.[cpLibraryID] = @LibraryID
	AND a.[cpLibraryStatus] = 1
	ORDER BY b.[cpLibraryID], [cpGoalLanguage], [cpGoalProblemNumber], [cpGoalNumber]

END