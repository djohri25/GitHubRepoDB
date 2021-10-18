/****** Object:  Procedure [dbo].[Get_WasLoggedIn]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Returns the flag indicating whether the user was ever logged in to the site or not.
*/
CREATE Procedure [dbo].[Get_WasLoggedIn]  

@ICENUMBER varchar(15)

as

set nocount on

BEGIN

	SELECT isNull(WasLoggedIn,'0') FROM dbo.UserAdditionalInfo WHERE MVDID = @ICENUMBER

END