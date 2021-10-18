/****** Object:  Procedure [dbo].[Get_TestDueStatus]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_TestDueStatus]
AS
BEGIN
	SET NOCOUNT ON;

    select ID,Name,IsComplete from LookupTestDueStatus
    where active = 1 and ParentID is null
    order by name
END