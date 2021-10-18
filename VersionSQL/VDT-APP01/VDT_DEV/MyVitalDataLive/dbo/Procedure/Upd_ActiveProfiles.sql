/****** Object:  Procedure [dbo].[Upd_ActiveProfiles]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_ActiveProfiles]
	@Username varchar(50)
As

SET NOCOUNT ON

	UPDATE MainUserName SET Active = 1, ModifyDate = GETUTCDATE() WHERE UserName = @Username