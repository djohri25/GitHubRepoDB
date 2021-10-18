/****** Object:  Procedure [dbo].[Shop_CheckEmail]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Shop_CheckEmail]

@Email varchar(50)

AS

SET NOCOUNT ON

SELECT COUNT(*) FROM dbo.MainUserName WHERE UserName = @Email