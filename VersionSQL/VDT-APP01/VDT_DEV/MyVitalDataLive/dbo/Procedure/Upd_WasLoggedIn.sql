/****** Object:  Procedure [dbo].[Upd_WasLoggedIn]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_WasLoggedIn]  

@ICENUMBER varchar(15)

AS

SET NOCOUNT ON

UPDATE UserAdditionalInfo SET WasLoggedIn = '1', LastUpdate = getutcdate()
WHERE MVDID = @ICENUMBER