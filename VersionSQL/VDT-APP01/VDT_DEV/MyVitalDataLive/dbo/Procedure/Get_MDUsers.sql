/****** Object:  Procedure [dbo].[Get_MDUsers]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDUsers]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID
      ,Username
      ,Email
      ,Password
      ,Active
      ,FirstName
      ,LastName
      ,CreationDate
      ,ModifyDate
      ,LastLogin
      ,LastLoginIP
      ,SecurityQ1
      ,SecurityA1
      ,SecurityQ2
      ,SecurityA2
      ,SecurityQ3
      ,SecurityA3
      ,Company
      ,AccountName
      ,FirstName
      ,LastName
      ,Organization
      ,Phone
  FROM MDUser ORDER BY ID desc
END