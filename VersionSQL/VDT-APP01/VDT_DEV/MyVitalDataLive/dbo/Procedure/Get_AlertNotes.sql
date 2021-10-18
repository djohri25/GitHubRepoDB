/****** Object:  Procedure [dbo].[Get_AlertNotes]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_AlertNotes]
	@AlertID int,
	@UserID varchar(50),
	@ShowAllMemberNotes bit			-- If 0 return only notes for the current alert, otherwise return 
									-- notes for current alert and alert notes of the current member 
									-- (alerts are created as a result of member lookups)
AS
BEGIN
	SET NOCOUNT ON;

--select @AlertID = 277,
--	@UserID = 'mvdadmin',
--	@ShowAllMemberNotes = 1
	
	declare @hasModifyRights bit		-- system Admins and HP admins has modify rights

	declare @query varchar(1000), @querySupport varchar(1000), @adminToolUserId varchar(50),
		@adminRoleId varchar(50), @superadminRoleId varchar(50), @isAdmin bit,
		@healthplanAdminRoleId varchar(50), @tempUserRoleID varchar(50),
		@hpMemberID varchar(20)

	declare @temp table(data varchar(50))

	set @hasModifyRights = 0

	-- Get userId
	set @querySupport = 'select UserId from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Users 
		where username = ''' + @UserID + ''''

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
		set @hasModifyRights = 1
	end

	select @hpMemberID = MemberID from hpalert where ID = @AlertID


	if(@ShowAllMemberNotes = 0)
	begin
		Select n.ID,note, convert(varchar,n.DateModified,101) as NoteDate, n.ModifiedBy as Owner,
			name as AlertStatus,
			ISNULL(n.LinkedFormType, '') as LInkedFormType,
			n.LinkedFormID,
			ls.ID as AlertStatusID,
			case when n.ModifiedBy = @UserID then 0
				when @hasModifyRights = 1 then 0
				when n.ModifiedBy <> @UserID then 1			
			end as ReadOnly
		from HPAlertNote n
			inner join lookupHPalertstatus ls on n.alertstatusId = ls.id 
			inner join hpAlert h on n.alertID = h.ID
		where n.AlertID = @AlertID and n.active = 1
		order by n.DateModified desc
	end
	else
	begin
		declare @mvdid varchar(50)
		select @mvdid = mvdid
		from Link_MemberId_MVD_Ins
		where InsMemberId = @hpMemberID
		
		Select n.ID,note, convert(varchar,n.DateModified,101) as NoteDate, n.ModifiedBy as Owner,
			name as AlertStatus,
			ISNULL(n.LinkedFormType, '') as LinkedFormType,
			n.LinkedFormID,
			ls.ID as AlertStatusID,
			case when n.ModifiedBy = @UserID then 0
				when @hasModifyRights = 1 then 0
				when n.ModifiedBy <> @UserID then 1			
			end as ReadOnly
		from HPAlertNote n
			left join lookupHPalertstatus ls on n.alertstatusId = ls.id 
		where MVDID = @mvdid and n.active = 1
		order by n.DateModified desc	
	end
END