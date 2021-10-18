/****** Object:  Procedure [dbo].[uspGetUserByUserType]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 09/01/2020
-- Description:	Get list of users by usertype.
-- exec uspGetUserByUserType 'VDT_UserType_Supervisory'
-- =============================================
create PROCEDURE [dbo].[uspGetUserByUserType]
	@userType varchar(250)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select distinct
		au.Id,
		au.UserName,
		au.FirstName,
		au.LastName
	from AspnetUsers au
	join AspNetUserInfo aui on au.Id = aui.UserId
	where aui.Groups like '%'+@userType+'%'
	order by au.LastName, au.FirstName, au.UserName
END