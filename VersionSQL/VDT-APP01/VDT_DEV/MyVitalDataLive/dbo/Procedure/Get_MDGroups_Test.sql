/****** Object:  Procedure [dbo].[Get_MDGroups_Test]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Bruce
-- Create date: 6/25/2016
-- Description:	testing with Parkland providers
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDGroups_Test] 
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID
      ,GroupName
      ,Active
      ,IsNoteAlertGroup
      ,CreationDate
      ,ModifyDate
	 FROM MDGroup_Test
	order by GroupName
END