/****** Object:  Procedure [dbo].[Get_SupportUserNameLogin]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_SupportUserNameLogin]
	@UserName varchar(100),
	@Password varchar(20)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Count int

	set @Count=0
	
	SELECT @Count = count(*) FROM SupportUserName 
	WHERE UserName = @UserName AND Password = @Password

	select @Count
END