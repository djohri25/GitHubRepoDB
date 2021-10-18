/****** Object:  Procedure [dbo].[Get_HPCopcUserFacilitiesByUser]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 2/19/2013
-- Description:	 Retrieves the list of COPC User Facilities based on currently logged in user
-- =============================================
create PROCEDURE [dbo].[Get_HPCopcUserFacilitiesByUser]
	@Username varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

--select @Username = 'mvdadmin'

	declare @tempUserRole table (roleId varchar(50), roleName varchar(50))
	declare @querySupport varchar(1000), @adminToolUserId varchar(50), @RoleName varchar(50)
	
	EXEC GetSupportUserRole @username = @Username, @roleName = @RoleName output
		
	if (@RoleName like '%admin%')
	begin
		SELECT distinct ID, FacilityName 
		from Link_HPCopcUserFacility u
			inner join CopcFacility c on u.FacilityID = c.ID
		where Active = 1	
	end
	else
	begin
	
		declare @temp table(data varchar(50))

		-- Get userId
		set @querySupport = 'select UserId from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Users 
			where username = ''' + @Username + ''''

		insert into @temp(data)
			exec (@querySupport)

		select @adminToolUserId = data from @temp
		
		SELECT ID, FacilityName 
		from Link_HPCopcUserFacility u
			inner join CopcFacility c on u.FacilityID = c.ID
		where Active = 1
			and u.UserID = @adminToolUserId		
	end	
	
		
END