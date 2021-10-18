/****** Object:  Procedure [dbo].[MD_VerifySSOLogin]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[MD_VerifySSOLogin]
	@UserID varchar(50),
	@UserTIN varchar(50),
	@Result int output
		-- possible values: 
		--  1 - authentication succeeded, 
		--  0 - authentication failed, 
AS
begin
	SET NOCOUNT ON
--declare @Result int
--declare @NPI varchar(50)

	declare @AccountID varchar(20)
	
	Select @result = 0,
		@AccountID = ''

	select @AccountID = ID
	from MDUser 
	where Username = @UserTIN and Active = 1

	if ISNULL(@AccountID,'') <> ''
	begin
		update MDUser set LastLogin = GETUTCDATE()
		where Username = @UserTIN
		
		insert into SSO_Log(UserID,UserTIN,Action)
		values(@UserID,@UserTIN,'Logged in')	
			
		set @result = 1
	end	
	else
	begin
		insert into SSO_Log(UserID,UserTIN,Action)
		values(@UserID,@UserTIN,'Invalid username')				
	end
end