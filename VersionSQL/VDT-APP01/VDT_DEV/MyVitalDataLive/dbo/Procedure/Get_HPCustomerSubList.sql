/****** Object:  Procedure [dbo].[Get_HPCustomerSubList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 12/09/2009
-- Description:	Returns the list of Health Plan subcustomers matching 
--	the criteria
--	@CustomerID - ID of the customers the subcustomers are selected for
--  @User - currently logged in user. The return list will contain only his subcustomer.
--		Unless, @User has admin or superadmin rights then the list contains all customers matching @ActiveFilter
--	@ActiveFilter - might have the following values: ALL, ACTIVE, INACTIVE
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPCustomerSubList]
	@CustomerID int,
	@User varchar(50),
	@ActiveFilter varchar(15)
AS
BEGIN
	SET NOCOUNT ON;

	declare @adminRoleId varchar(50), @superadminRoleId varchar(50),
		@querySupport varchar(1000), @userId varchar(50), @userCustomerId int,	
		@tempUserRoleID varchar(50)

	-- Retrieve Admin and Superadmin role Ids
	EXEC Get_SupportUserRoleID @RoleName = 'Admin', @RoleID = @adminRoleId OUTPUT
	EXEC Get_SupportUserRoleID @RoleName = 'superadmin', @RoleID = @superadminRoleId OUTPUT

	declare @temp table(data varchar(50))

	-- Get userId
	set @querySupport = 'select UserId from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Users 
		where username = ''' + @User + ''''

	insert into @temp(data)
		exec (@querySupport)

	select @userId = data from @temp
	delete from @temp

	set @querySupport = 'select roleID from ' + dbo.Get_SupportDBName() +'.dbo.aspnet_UsersInRoles 
				where userid = ''' + @userId + ''' '

	insert into @temp(data)
		exec (@querySupport)

	select @tempUserRoleID = data from @temp

	if(len(isnull(@tempUserRoleID,'')) > 0 )	
	begin
		if @tempUserRoleID = @adminRoleId OR @tempUserRoleID = @superadminRoleID
			OR EXISTS (
				select SupportToolUserId 
				from dbo.Link_SupUser_Admin_HPCustomer 
				where SupportToolUserId = @userId and HPCustomerId = @CustomerID)
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
			where ParentID = @CustomerID	
		end
		else
		begin
			-- Get Id of the Customer associated with the user
			set @querySupport = 'select CustomerId from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_membership 
				where userid = ''' + @Userid + ''''

			delete from @temp

			insert into @temp(data)
			exec (@querySupport)

			select @userCustomerId = data from @temp

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
			where ParentID = @CustomerID
				and cust_id = @userCustomerID
		
		end
		
	end
END