/****** Object:  Procedure [dbo].[Get_CCCUsersFromGroups]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dbo].[Get_CCCUsersFromGroups]
(
	@GroupName		Varchar(100),	
	@UserName	Varchar(30),
	@GrpNm_out	varchar(100) out
)
AS 
BEGIN
--Declare @GroupName		Varchar(100),	@UserName	Varchar(30)
--Select @GroupName = 'Social Worker'--, @UserName = 'lhuddleston'

Declare @GrpNm Varchar(300) 

IF ISNULL(@UserName,'') <> ''
BEGIN
	
	select @GrpNm = sh.StakeholderGroup, @GroupName = NULL
	from CCC_StakeholderGroup SH
	JOIN Link_CCC_UserSHGroup SHG ON SH.ID = SHG.SHGroupID
	JOIN MVDSupportLive.DBO.aspnet_Users U  ON SHG.Userid = u.UserId
	Where U.LoweredUserName = @UserName
END

Select distinct U.FirstName+' '+ U.LastName as Name 
from Link_CCC_UserSHGroup SHG JOIN CCC_StakeholderGroup SH On SH.ID = SHG.SHGroupID
JOIN MVDSupportLive.DBO.aspnet_Membership U ON SHG.Userid = u.UserId
Where (SH.StakeholderGroup = LTRIM(RTRIM(@GroupName)) or SH.StakeholderGroup = LTRIM(RTRIM(@GrpNm)) )

Select @GrpNm_out = @GrpNm

END