/****** Object:  Procedure [dbo].[Upd_UserPassword]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_UserPassword]
	@UserName varchar(100),
	@Password varchar(20),
	@NewPassword varchar(20), 
	@Result int OUT
As

Set Nocount On

DECLARE @Count int
	SELECT @Result = COUNT(*) FROM MainUserName WHERE UserName = @UserName AND Password = @Password
	IF @Result = 1
		UPDATE MainUserName SET Password = @NewPassword, ModifyDate = GETUTCDATE()
		WHERE UserName = @UserName