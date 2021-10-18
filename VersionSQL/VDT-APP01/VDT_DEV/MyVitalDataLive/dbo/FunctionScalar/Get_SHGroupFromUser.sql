/****** Object:  Function [dbo].[Get_SHGroupFromUser]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE function [dbo].[Get_SHGroupFromUser]
(@UserFullName	varchar(100))
RETURNS varchar(150)
AS
BEGIN

--Declare @UserFullName	varchar(100)
--Set @UserFullName = 'Cynthia Garza'
Declare @SHGroup varchar(150)

Select top 1 @SHGroup=  SG.StakeholderGroup 
from MVDSupportLIVE.dbo.aspnet_Membership M JOIN MVDSupportLive.dbo.aspnet_Users U ON U.userid = M.UserId
JOIN dbo.Link_CCC_UserSHGroup SHG ON SHG.UserID = U.UserID 
JOIN.dbo.CCC_StakeHolderGroup SG ON SG.ID = SHG.SHGroupID
Where M.FirstName + ' ' + M.LastName = @UserFullName

Return @SHGroup 

END