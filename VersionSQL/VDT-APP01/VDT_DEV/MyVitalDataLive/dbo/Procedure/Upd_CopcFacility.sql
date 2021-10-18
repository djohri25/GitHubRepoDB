/****** Object:  Procedure [dbo].[Upd_CopcFacility]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 1/17/2013
-- Description:	Updates COPC facility record
-- =============================================
CREATE Procedure [dbo].[Upd_CopcFacility]
	@Result int OUT,
	@ID int,
	@FacilityName varchar(50),
	@Active bit,
	@NPIList varchar(max) = null
AS
	SET NOCOUNT ON

	DECLARE @tempNPI varchar(50), @tempID int
	declare @temp table(data varchar(50))

	set @Result = 0
	
	if exists (select top 1 ID from CopcFacility where ID <> @ID AND FacilityName = @FacilityName)
	begin
		set @Result = -2
	end
	else
	begin
	
		UPDATE	CopcFacility 
		SET	Active = @Active,
			FacilityName = @FacilityName
		WHERE ID= @ID

		
		insert into @temp(data)
			select * from dbo.Split(@NPIList,',')
			
		delete from Link_CopcFacilityNPI where CopcFacilityID = @ID
		
		while exists(select top 1 DATA from @temp)
		begin
			select top 1 @tempNPI = DATA from @temp
			
			if(ISNULL(@tempNPI,'') <> '')
			begin
				insert into Link_CopcFacilityNPI(CopcFacilityID,NPI)
				values(@ID,@tempNPI)
			end
			
			delete from @temp where data = @tempNPI		
		end  
		

		SET @Result = 1
	end