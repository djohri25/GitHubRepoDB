/****** Object:  Procedure [dbo].[Get_MDGroups]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDGroups] 
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID
      ,GroupName
      ,Active
      ,IsNoteAlertGroup
      ,CreationDate
      ,ModifyDate

	 FROM MDGroup
	order by GroupName
END