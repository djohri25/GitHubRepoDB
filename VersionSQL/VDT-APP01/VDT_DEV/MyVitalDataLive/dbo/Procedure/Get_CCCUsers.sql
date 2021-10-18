/****** Object:  Procedure [dbo].[Get_CCCUsers]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dbo].[Get_CCCUsers]
AS
BEGIN
	
	Select U.UserId as 'UserID', AM.FirstName, AM.LastName, AM.Active as UserStatus, U.LoweredUserName as 'UserName', SHG.SHGroupID, SHG.ManagerName
	from MVDSupportLive.dbo.aspnet_Users U
	join MVDSupportLive.dbo.aspnet_Membership AM on AM.UserId = U.UserId
	LEFT JOIN dbo.Link_CCC_UserSHGroup SHG ON SHG.UserID = AM.UserId
	where AM.CustomerId = 15

END