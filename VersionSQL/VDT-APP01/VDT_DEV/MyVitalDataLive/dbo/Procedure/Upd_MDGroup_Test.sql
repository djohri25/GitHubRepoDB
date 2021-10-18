/****** Object:  Procedure [dbo].[Upd_MDGroup_Test]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 
-- Description:	Updates MD group record
-- =============================================
CREATE Procedure [dbo].[Upd_MDGroup_Test]
	@Result int OUT,
	@ID int,
	@GroupName varchar(50),
	@Active bit,
	@IsNoteAlertGroup bit,
	@NPIList varchar(max) = null
AS
	SET NOCOUNT ON

	DECLARE @tempNPI varchar(50), @tempID int
	declare @temp table(data varchar(50))

	set @Result = 0
	
	if exists (select top 1 ID from MDGroup_Test where ID <> @ID AND GroupName = @GroupName)
	begin
		set @Result = -2
	end
	else
	begin
	
		UPDATE	MDGroup_Test
		SET	Active = @Active,
			GroupName = @GroupName,
			IsNoteAlertGroup = @IsNoteAlertGroup
		WHERE ID= @ID
		
		insert into @temp(data)
			select * from dbo.Split(@NPIList,',')
			
		delete from Link_MDGroupNPI_Test where MDGroupID = @ID
		
		while exists(select top 1 DATA from @temp)
		begin
			select top 1 @tempNPI = DATA from @temp
			
			if(ISNULL(@tempNPI,'') <> '')
			begin
				insert into Link_MDGroupNPI_Test(MDGroupID,NPI)
				values(@ID,@tempNPI)
			end
			
			delete from @temp where data = @tempNPI		
		end  
		
		SET @Result = 1
	end