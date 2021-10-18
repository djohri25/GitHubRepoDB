/****** Object:  Procedure [dbo].[Get_HPCustomerList]    Committed by VersionSQL https://www.versionsql.com ******/

-- Stored procedure
-- =============================================
-- Author:		sw
-- Create date: 09/23/2008
-- Description:	Returns the list of Health Plan customers matching 
--	the criteria
--  @User - currently logged in user. The return list will contain only his employer/customer.
--		Unless, @User has admin or superadmin rights then the list contains all customers matching @ActiveFilter
--	@ActiveFilter - might have the following values: ALL, ACTIVE, INACTIVE
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPCustomerList]
	@User varchar(50),
	@ActiveFilter varchar(15)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @query varchar(1000), @querySupport varchar(1000), @userId varchar(50), @userCustomerId int, 
		@adminRoleId varchar(50), @superadminRoleId varchar(50), @isAdmin bit,
		@healthplanAdminRoleId varchar(50), @tempUserRoleID varchar(50)

	declare @temp table(data varchar(50))

	-- Get userId
	set @querySupport = 'select UserId from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Users 
		where username = ''' + @User + ''''

	insert into @temp(data)
		exec (@querySupport)

	select @userId = data from @temp
	delete from @temp

	-- Retrieve Admin and Superadmin role Ids
	EXEC Get_SupportUserRoleID @RoleName = 'Admin', @RoleID = @adminRoleId OUTPUT
	EXEC Get_SupportUserRoleID @RoleName = 'superadmin', @RoleID = @superadminRoleId OUTPUT
	EXEC Get_SupportUserRoleID @RoleName = 'HealthPlanAdmin', @RoleID = @healthplanAdminRoleId OUTPUT

	set @querySupport = 'select roleID from ' + dbo.Get_SupportDBName() +'.dbo.aspnet_UsersInRoles 
				where userid = ''' + @userId + ''' '

	insert into @temp(data)
		exec (@querySupport)

	select @tempUserRoleID = data from @temp

	if(len(isnull(@tempUserRoleID,'')) > 0)	
	begin
		if(@tempUserRoleID = @adminRoleId OR @tempUserRoleID = @superadminRoleID)
		begin
			-- Don't filter the list for admins
			SELECT Cust_ID
			  ,Name
			  ,Type
			  ,Address1
			  ,Address2
			  ,City
			  ,State
			  ,PostalCode
			  ,PrimaryAgent
			  ,Active
			FROM HPCustomer 
			where ParentID is null 
				and Active =
					case isnull(@ActiveFilter,'')
						when 'ACTIVE' then 1
						when 'INACTIVE' then 0
						else active
					end
		end
		else if(@tempUserRoleID = @healthplanAdminRoleId)
		begin
			-- Get Id of the Customer associated with the user
			select top 1 @userCustomerId = HPCustomerId  from Link_SupUser_Admin_HPCustomer		
				where SupportToolUserId = @userid

			SELECT Cust_ID
			  ,Name
			  ,Type
			  ,Address1
			  ,Address2
			  ,City
			  ,State
			  ,PostalCode
			  ,PrimaryAgent
			  ,Active
			FROM HPCustomer 
			where ParentID is null 
				and Active =
					case isnull(@ActiveFilter,'')
						when 'ACTIVE' then 1
						when 'INACTIVE' then 0
						else active
					end
				and Cust_Id = @userCustomerId
		end
		else
		begin
			-- e.g. HP Agent

			-- Get Id of the Customer associated with the user
			set @querySupport = 'select CustomerId from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_membership 
				where userid = ''' + @Userid + ''''

			delete from @temp

			insert into @temp(data)
			exec (@querySupport)

			select @userCustomerId = data from @temp

			select @userCustomerId = c2.cust_id 
			from dbo.hpcustomer c1
				inner join dbo.hpcustomer c2 on c1.parentid = c2.cust_id
			where c1.cust_id = @userCustomerId

			SELECT Cust_ID
			  ,Name
			  ,Type
			  ,Address1
			  ,Address2
			  ,City
			  ,State
			  ,PostalCode
			  ,PrimaryAgent
			  ,Active
			FROM HPCustomer 
			where ParentID is null 
				and Active =
					case isnull(@ActiveFilter,'')
						when 'ACTIVE' then 1
						when 'INACTIVE' then 0
						else active
					end
				and Cust_Id = @userCustomerId

		end
	end

END