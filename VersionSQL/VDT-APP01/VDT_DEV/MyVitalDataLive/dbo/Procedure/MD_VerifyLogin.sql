/****** Object:  Procedure [dbo].[MD_VerifyLogin]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[MD_VerifyLogin]
	@Username varchar(50),
	@Password varchar(50),
	@IP varchar(20),
	@AccountID varchar(20) output,
	@ForcePasswordReset bit output,
	@Result int output
		-- possible values: 
		--  1 - authentication succeeded, 
		--  0 - authentication failed, 
AS
begin
	SET NOCOUNT ON
--declare @Result int
--declare @NPI varchar(50)

	Select @result = 0,
		@AccountID = ''

	select @AccountID = ID,
		 @ForcePasswordReset = ForcePasswordReset
	from MDUser 
	where Username = @Username and Password = @Password and Active = 1

	if ISNULL(@AccountID,'') <> ''
	begin
		update MDUser set LastLogin = GETUTCDATE(), lastLoginIP = @IP
		where Username = @Username
		
		insert into MDUserLogin(Username)
		values(@Username)
		
		set @result = 1
	end

end