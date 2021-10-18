/****** Object:  Procedure [dbo].[Set_MDGroup]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Creates new record of MD user
-- =============================================
CREATE PROCEDURE [dbo].[Set_MDGroup]
	@Result int OUT,
	@GroupName varchar(50),
	@Active bit,
	@IsNoteAlertGroup bit,
	@NPIList varchar(max) = null
AS
	SET NOCOUNT ON

	DECLARE @tempNPI varchar(50), @tempID int
	declare @temp table(data varchar(50))

	IF EXISTS (SELECT TOP 1 ID FROM MDGroup WHERE GroupName = @GroupName)
		-- username found
		SET @Result = -2
	ELSE
	BEGIN
		IF @Active IS NULL
			-- set to default 0
			SET @Active = 0

		insert into @temp(data)
		select * from dbo.Split(@NPIList,',')

		INSERT INTO MDGroup
		   (GroupName,Active,IsNoteAlertGroup)
		VALUES
			(@GroupName,@Active,@IsNoteAlertGroup)
		
		SET @Result = @@ROWCOUNT	

		select @tempID = ID from MDGroup where GroupName = @GroupName   
		   
		while exists(select top 1 DATA from @temp)
		begin
			select top 1 @tempNPI = DATA from @temp
			
			if(ISNULL(@tempNPI,'') <> '')
			begin
				insert into Link_MDGroupNPI(MDGroupID,NPI)
				values(@tempID,@tempNPI)
			end
			
			delete from @temp where data = @tempNPI		
		end   		
		
	END