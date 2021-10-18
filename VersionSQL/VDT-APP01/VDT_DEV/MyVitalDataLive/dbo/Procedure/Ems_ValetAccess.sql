/****** Object:  Procedure [dbo].[Ems_ValetAccess]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Ems_ValetAccess]
	@IceNum varchar(15),
	@Valet varchar(15)
	
AS

	SET NOCOUNT ON
	DECLARE @Count int

	SELECT @Count = COUNT(*) FROM MainICENUMBERGroups WHERE ICENUMBER = @IceNum
	AND SecondaryICENUMBER = @Valet

	IF @Count = 1
		UPDATE MainICENUMBERGroups SET ModifyDate = GETUTCDATE() WHERE ICENUMBER = @IceNum
		AND SecondaryICENUMBER = @Valet
	
	SELECT @Count