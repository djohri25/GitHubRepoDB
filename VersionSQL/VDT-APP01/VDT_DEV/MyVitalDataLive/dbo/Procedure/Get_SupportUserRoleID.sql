/****** Object:  Procedure [dbo].[Get_SupportUserRoleID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: sw		
-- Create date: 2/4/2009
-- Description:	 Get ID of the user role in support database
-- =============================================
CREATE procedure [dbo].[Get_SupportUserRoleID]
	(@RoleName varchar(50), @RoleID varchar(50) out)
AS
BEGIN
	declare @query varchar(1000)
	declare @temp table(data varchar(50))

	set @query = 'select roleId from ' + dbo.Get_SupportDBName() + '.dbo.aspnet_Roles where RoleName = ''' + @RoleName + ''''
    
	insert into @temp(data)
		exec (@query)

	select @RoleID = data from @temp

END