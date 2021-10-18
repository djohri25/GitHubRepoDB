/****** Object:  Procedure [dbo].[Set_CopcFacility]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Creates new record of MD user
-- =============================================
create PROCEDURE [dbo].[Set_CopcFacility]
	@Result int OUT,
	@Name varchar(50),
	@Active bit,
	@NPIList varchar(max) = null
AS
	SET NOCOUNT ON

	DECLARE @tempNPI varchar(50), @tempID int
	declare @temp table(data varchar(50))

	IF EXISTS (SELECT TOP 1 ID FROM CopcFacility WHERE FacilityName = @Name)
		-- username found
		SET @Result = -2
	ELSE
	BEGIN
		IF @Active IS NULL
			-- set to default 0
			SET @Active = 0

		insert into @temp(data)
		select * from dbo.Split(@NPIList,',')

		INSERT INTO CopcFacility
		   (FacilityName,Active)
		VALUES
			(@Name,@Active)
		
		SET @Result = @@ROWCOUNT	

		select @tempID = ID from CopcFacility where FacilityName = @Name   
		   
		while exists(select top 1 DATA from @temp)
		begin
			select top 1 @tempNPI = DATA from @temp
			
			if(ISNULL(@tempNPI,'') <> '')
			begin
				insert into Link_CopcFacilityNPI(CopcFacilityID,NPI)
				values(@tempID,@tempNPI)
			end
			
			delete from @temp where data = @tempNPI		
		end   		
		
	END