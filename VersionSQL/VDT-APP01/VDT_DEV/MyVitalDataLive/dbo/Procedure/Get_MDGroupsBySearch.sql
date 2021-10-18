/****** Object:  Procedure [dbo].[Get_MDGroupsBySearch]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDGroupsBySearch]
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

	 FROM MDGroup WHERE GroupName  like   + @Search_Value +'%'
END