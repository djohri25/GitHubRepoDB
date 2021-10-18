/****** Object:  Procedure [dbo].[Get_ActiveProfiles]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_ActiveProfiles]
	@Username varchar(50)
As

SET NOCOUNT ON

--	Note: there was a problem when a user with multiple profiles tried to retrieve the password
--	SELECT Password, 
--	(SELECT ICENUMBER FROM MainICENUMBERGroups WHERE MainICENUMBERGroups.ICEGROUP =
--	MainUserName.ICEGROUP) AS IceNumber, ICEGROUP
--	FROM MainUserName WHERE UserName = @Email

	declare @group varchar(50), @mvdid varchar(50)

	select @group = icegroup FROM MainUserName WHERE UserName = @Username
	SELECT @mvdid=icenumber FROM MainICENUMBERGroups where icegroup = @group and mainaccount = '1'

	SELECT Password,@mvdid AS IceNumber, ICEGROUP
	FROM MainUserName WHERE UserName = @Username