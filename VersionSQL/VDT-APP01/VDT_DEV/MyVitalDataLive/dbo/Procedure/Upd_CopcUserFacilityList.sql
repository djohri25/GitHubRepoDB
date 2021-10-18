/****** Object:  Procedure [dbo].[Upd_CopcUserFacilityList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 
-- Description:	Updates Copc User Facility List
-- =============================================
create Procedure [dbo].Upd_CopcUserFacilityList
	@Result int OUT,
	@UserID varchar(50),
	@FacilityList varchar(max) 
AS
	SET NOCOUNT ON

	DECLARE @tempID varchar(50)
	declare @temp table(data varchar(50))

	set @Result = 0
		
	insert into @temp(data)
		select * from dbo.Split(@FacilityList,',')
		
	delete from Link_HPCopcUserFacility where USERID = @UserID
	
	while exists(select top 1 DATA from @temp)
	begin
		select top 1 @tempID = DATA from @temp
		
		if(ISNULL(@tempID,'') <> '')
		begin
			insert into Link_HPCopcUserFacility(UserID,FacilityID)
			values(@UserID,@tempID)
		end
		
		delete from @temp where data = @tempID		
	end  
	

	SET @Result = 1