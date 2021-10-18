/****** Object:  Procedure [dbo].[Set_MDGroup_Test]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Bruce
-- Create date: 6/25/2016
-- Description:	Creates new record of MD user (for MDGroup_Test table with new Parkland providers
-- =============================================
CREATE PROCEDURE [dbo].[Set_MDGroup_Test]
	@Result int OUT,
	@GroupName varchar(50),
	@Active bit,
	@IsNoteAlertGroup bit,
	@NPIList varchar(max) = null
AS
	SET NOCOUNT ON

	DECLARE @tempNPI varchar(50), @tempID int
	declare @temp table(data varchar(50))

	IF EXISTS (SELECT TOP 1 ID FROM MDGroup_Test WHERE GroupName = @GroupName)
		-- username found
		SET @Result = -2
	ELSE
	BEGIN
		IF @Active IS NULL
			-- set to default 0
			SET @Active = 0

		insert into @temp(data)
		select * from dbo.Split(@NPIList,',')

		INSERT INTO MDGroup_Test
		   (GroupName,Active,IsNoteAlertGroup)
		VALUES
			(@GroupName,@Active,@IsNoteAlertGroup)
		
		SET @Result = @@ROWCOUNT	

		select @tempID = ID from MDGroup_Test where GroupName = @GroupName   
		   
		while exists(select top 1 DATA from @temp)
		begin
			select top 1 @tempNPI = DATA from @temp
			
			if(ISNULL(@tempNPI,'') <> '')
			begin
				insert into Link_MDGroupNPI_Test(MDGroupID,NPI)
				values(@tempID,@tempNPI)
			end
			
			delete from @temp where data = @tempNPI		
		end   		
		
	END