/****** Object:  Procedure [dbo].[Get_HospitalListByUser]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 07/28/2008
-- Description:	Returns the list of hospitals which can be seen by User
--		If @User is blank then retrieve the full list
-- =============================================
CREATE PROCEDURE [dbo].[Get_HospitalListByUser]
	@User varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @userId varchar(50), @userCustomerId int, 
		@adminRoleId varchar(50), @superadminRoleId varchar(50), @isAdmin bit,
		@healthplanAdminRoleId varchar(50), @query varchar(1000)

	declare @temp table(data varchar(50))

	-- Get userId
	set @query = 'select UserId from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Users 
		where username = ''' + @User + ''''
	
	insert into @temp(data)
		exec (@query)

	select @userId = data from @temp
	delete from @temp

	-- Retrieve Admin and Superadmin role Ids
	EXEC Get_SupportUserRoleID @RoleName = 'Admin', @RoleID = @adminRoleId OUTPUT
	EXEC Get_SupportUserRoleID @RoleName = 'superadmin', @RoleID = @superadminRoleId OUTPUT

	set @query = 'select userid from ' + dbo.Get_SupportDBName() +'.dbo.aspnet_UsersInRoles 
				where userid = ''' + @userId + ''' and (roleid = ''' + @adminRoleId  + 
				''' or roleid = ''' + @superadminRoleId + ''')'
	insert into @temp(data)
		exec (@query)

	-- Check if the user had admin or superadmin right, if that's the case don't filter
	-- the list by user
	if exists( select data from @temp )
	begin
		SELECT ID,Name
		FROM MainEMSHospital
		order by Name
	end
	else
	begin
		-- Check if user is a healthplan admin
		IF EXISTS (SELECT SupportToolUserId FROM Link_SupUser_Admin_HPCustomer WHERE SupportToolUserId = @userId)
			-- Return all hospitals under healthplan associate with user
			SELECT	h.ID, h.Name
			FROM	MainEMSHospital AS h INNER JOIN
					Link_HPFacilityCustomer AS hc ON h.ID = hc.Facility_ID INNER JOIN
					Link_SupUser_Admin_HPCustomer AS uc ON hc.Cust_ID = uc.HPCustomerId
			WHERE	uc.SupportToolUserId = @userId
		ELSE
			-- Return only hospital(s) which is assiciated with the user
			SELECT ID,Name		  
			FROM MainEMSHospital a inner join dbo.Link_SupUserHospital b on a.ID = b.HospitalId
			where SupportToolUserId = @userId
			order by Name
	end

END