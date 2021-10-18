/****** Object:  Procedure [dbo].[Get_HPPredefinedNotes]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/25/2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPPredefinedNotes]
	@username varchar(50),
	@custID varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

--select @username = 'mvdadmin',-- 'slyTestEMS', 
--	@custID = 1

	declare @temp table(data varchar(50))

	declare @query varchar(1000), @querySupport varchar(1000), @adminToolUserId varchar(50),
			@adminRoleId varchar(50), @superadminRoleId varchar(50), @isAdmin bit,
			@healthplanAdminRoleId varchar(50), @tempUserRoleID varchar(50), @allowViewAll bit

	set @allowViewAll = 0
				
	-- Get userId
	set @querySupport = 'select UserId from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Users 
		where username = ''' + @username + ''''

	insert into @temp(data)
		exec (@querySupport)

	select @adminToolUserId = data from @temp
	delete from @temp

	-- Retrieve Admin and Superadmin role Ids
	EXEC Get_SupportUserRoleID @RoleName = 'Admin', @RoleID = @adminRoleId OUTPUT
	EXEC Get_SupportUserRoleID @RoleName = 'superadmin', @RoleID = @superadminRoleId OUTPUT
	EXEC Get_SupportUserRoleID @RoleName = 'HealthPlanAdmin', @RoleID = @healthplanAdminRoleId OUTPUT

	set @querySupport = 'select roleID from ' + dbo.Get_SupportDBName() +'.dbo.aspnet_UsersInRoles 
				where userid = ''' + @adminToolUserId + ''' '

	insert into @temp(data)
		exec (@querySupport)

	select @tempUserRoleID = data from @temp

	if(isnull(@tempUserRoleID,'') <> '' AND 
		(@tempUserRoleID = @adminRoleId OR @tempUserRoleID = @superadminRoleID OR @tempUserRoleID = @healthplanAdminRoleId))
	begin
		set @allowViewAll = 1
	end
	

--select @adminToolUserId as '@adminToolUserId', @tempUserRoleID as '@tempUserRoleID', @allowViewAll as '@allowViewAll'


	select h.ID as NoteID,ShortName, Note, StatusID, 
		isNull(s.Name,'') as StatusName, AlertGroupID,
		(select g.Name from HPAlertGroup g where g.ID = AlertGroupID) as AlertGroupName
	from dbo.HPAlertPredefinedNote h
		left join LookupHPAlertStatus s on h.StatusID = s.ID
	where custID = @custID
		and 
		(
			AlertGroupID is null
			or
			@allowViewAll = 1
			or
			exists(
				select top 1 * from Link_HPAlertGroupAgent ga where ga.Group_ID = h.AlertGroupID and ga.Agent_ID = @adminToolUserId
			)
		)
		
END