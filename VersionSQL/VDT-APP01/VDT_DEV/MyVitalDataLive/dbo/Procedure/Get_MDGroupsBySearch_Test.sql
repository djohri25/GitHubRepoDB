/****** Object:  Procedure [dbo].[Get_MDGroupsBySearch_Test]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Bruce
-- Create date: 6/25/2016
-- Description:	For testing with Parkland providers
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDGroupsBySearch_Test]
@Search_Value varchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID
      ,GroupName
      ,Active
      ,IsNoteAlertGroup
      ,CreationDate
      ,ModifyDate
	 FROM MDGroup_Test WHERE GroupName  like   + @Search_Value +'%'
END