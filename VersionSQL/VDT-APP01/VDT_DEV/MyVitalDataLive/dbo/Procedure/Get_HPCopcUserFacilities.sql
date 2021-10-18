/****** Object:  Procedure [dbo].[Get_HPCopcUserFacilities]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 2/12/2013
-- Description:	 Retrieves the list of COPC User Facilities
-- =============================================
create PROCEDURE [dbo].[Get_HPCopcUserFacilities]
	@UserId varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	--select @UserId = 'F9F8D9A4-8231-4C2F-8195-C4351171FEA5'
	

	-- Holds temporary result
	declare @tempTab table (id varchar(50), name varchar(100), isSelected bit default(0))

	insert into @tempTab (id,name)
	SELECT ID, FacilityName 
	from CopcFacility 
	where Active = 1
	
	-- Set Select flag only if Facility is assigned to user
	update @tempTab set isSelected = 1 
	where id in( 
		select FacilityID from dbo.Link_HPCopcUserFacility
		 where UserId = @UserId)

	select id, name, isSelected 
	from @tempTab
	order by name
		
END