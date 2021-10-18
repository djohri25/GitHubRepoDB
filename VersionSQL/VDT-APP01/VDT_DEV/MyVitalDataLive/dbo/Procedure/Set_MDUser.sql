/****** Object:  Procedure [dbo].[Set_MDUser]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Creates new record of MD user
-- =============================================
CREATE PROCEDURE [dbo].[Set_MDUser]
	@Result int OUT,
	@Username varchar(50),
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

	DECLARE @CompanyID int, @tempGroupID varchar(50), @tempID int
	declare @temp table(data varchar(50))

	IF EXISTS (SELECT TOP 1 ID FROM MDUser WHERE Username = @Username)
		-- username found
		SET @Result = -2
	ELSE
	BEGIN
		IF @Active IS NULL
			-- set to default 0
			SET @Active = 0

		insert into @temp(data)
		select * from dbo.Split(@GroupList,',')

		INSERT INTO MDUser
		   (Username,Password,Active,AccountName,FirstName,LastName,Organization,Phone)
		VALUES
			(@Username,@Password,@Active,@AccountName,@FirstName,@LastName,@Organization,@Phone)
		
		select @tempID = ID from MDUser where Username = @Username   

		SET @Result = @@ROWCOUNT	
		   
		while exists(select top 1 DATA from @temp)
		begin
			select top 1 @tempGroupID = DATA from @temp
			
			if(ISNULL(@tempGroupID,'') <> '')
			begin
				insert into Link_MDAccountGroup(MDAccountID,MDGroupID)
				values(@tempID,@tempGroupID)
			end
			
			delete from @temp where data = @tempGroupID		
		end   		
		
	END