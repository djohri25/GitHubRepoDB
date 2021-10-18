/****** Object:  Procedure [dbo].[Get_UserSecurityQuestion]    Committed by VersionSQL https://www.versionsql.com ******/

Create Procedure [dbo].[Get_UserSecurityQuestion]
	@Email varchar(100),
	@SecurityQuestion int OUT
As

SET NOCOUNT ON

	SELECT @SecurityQuestion = SecQuestion FROM MainUserName WHERE UserName = @Email 