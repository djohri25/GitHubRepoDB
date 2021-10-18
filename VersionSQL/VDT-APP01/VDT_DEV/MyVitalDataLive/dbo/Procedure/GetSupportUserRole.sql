/****** Object:  Procedure [dbo].[GetSupportUserRole]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetSupportUserRole]
	@Username varchar(50),
	@roleName varchar(50) output
AS
BEGIN
	SET NOCOUNT ON;

	--select @Username = 'mvdadmin'
	
	declare @query varchar(1000), @querySupport varchar(1000), @supportToolUserId varchar(50),
		@adminRoleId varchar(50), @superadminRoleId varchar(50), @isAdmin bit,
		@healthplanAdminRoleId varchar(50), @tempUserRoleID varchar(50),
		@hpMemberID varchar(20)

	declare @temp table(data varchar(50))
	declare @tempRole table(roleID varchar(50), roleName varchar(50))

	-- Get userId
	set @querySupport = 'select UserId from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Users 
		where username = ''' + @Username + ''''

	insert into @temp(data)
		exec (@querySupport)

	select @supportToolUserId = data from @temp
	delete from @temp

	set @querySupport = 'select r.roleID, r.roleName
		from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Roles r
			inner join ' + dbo.Get_SupportDBName() +'.dbo.aspnet_UsersInRoles ur on r.RoleId = ur.RoleId
		where userid = ''' + @supportToolUserId + ''' '

	insert into @tempRole
	exec (@querySupport)

	select @roleName = rolename
	from @tempRole
	
END