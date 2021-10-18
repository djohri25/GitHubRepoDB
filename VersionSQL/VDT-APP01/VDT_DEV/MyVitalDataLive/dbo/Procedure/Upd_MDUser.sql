/****** Object:  Procedure [dbo].[Upd_MDUser]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 
-- Description:	Updates MD user record
-- =============================================
CREATE Procedure [dbo].[Upd_MDUser]
	@Result int OUT,
	@ID int,
	@AccountName varchar(50),
	@Password varchar(50),
	@Active bit,
	@GroupList varchar(max) = null,
	@FirstName varchar(50),
	@LastName varchar(50),
	@Organization varchar(50),
	@Phone varchar(50)		
AS
	SET NOCOUNT ON

	DECLARE @CompanyID int,@tempGroupID varchar(50), @tempID int
	declare @temp table(data varchar(50))

	set @Result = 0
	
	IF ISNULL(@Password, '') = ''
		UPDATE	MDUser 
		SET	Active = @Active,
			AccountName = @AccountName,
			FirstName = @FirstName,
			LastName = @LastName,
			Organization = @Organization,
			Phone = @Phone
		WHERE ID= @ID
	ELSE
	BEGIN
		UPDATE	MDUser 
		SET Password = @Password,
			Active = @Active,
			AccountName = @AccountName,
			FirstName = @FirstName,
			LastName = @LastName,
			Organization = @Organization,
			Phone = @Phone			
		WHERE ID= @ID

	END
	
	insert into @temp(data)
		select * from dbo.Split(@GroupList,',')
		
	delete from Link_MDAccountGroup where MDAccountID = @ID
	
	while exists(select top 1 DATA from @temp)
	begin
		select top 1 @tempGroupID = DATA from @temp
		
		if(ISNULL(@tempGroupID,'') <> '')
		begin
			insert into Link_MDAccountGroup(MDAccountID,MDGroupID)
			values(@ID,@tempGroupID)
		end
		
		delete from @temp where data = @tempGroupID		
	end  
	

	SET @Result = 1