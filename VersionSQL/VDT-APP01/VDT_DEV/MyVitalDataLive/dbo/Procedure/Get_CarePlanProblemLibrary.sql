/****** Object:  Procedure [dbo].[Get_CarePlanProblemLibrary]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Mike Grover
-- Create date: 10/21/2016
-- Description:	Return the list of Care Plan
--		Problems associated with a given library
-- Example:		EXEC dbo.Get_CarePlanProblemLibrary @CustID = '11', @LibraryID = 1
-- Changes:		04/24/2017	Marc De Luca	Changes the old style joins to normal joins.  The SQL Server data migration assistant pointed this out.
-- =============================================
CREATE PROCEDURE [dbo].[Get_CarePlanProblemLibrary]
	@CustID varchar(4),
	@LibraryID int
AS

BEGIN

	SET NOCOUNT ON;

	SELECT b.[cpLibraryID] AS ID, [cpProbLanguage] AS Language, [cpProbNumber] AS ProblemNum, [cpProbText] AS Problem
	FROM [dbo].[LookupCarePlanLibrary] a
	JOIN [dbo].[LookupCarePlanProblemLibrary] b ON a.[cpLibraryID] = b.[cpLibraryID]
	WHERE a.[cpLibraryCustIDList] LIKE '%' + @CustID + '%'
	AND a.[cpLibraryID] = @LibraryID
	AND a.[cpLibraryStatus] = 1
	ORDER BY b.[cpLibraryID], [cpProbLanguage], [cpProbNumber]

END