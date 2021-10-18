/****** Object:  Procedure [dbo].[Get_AccountStatus]    Committed by VersionSQL https://www.versionsql.com ******/

create PROCEDURE [dbo].[Get_AccountStatus]
	@IceNumber varchar(15)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT MainAccount FROM MainICENUMBERGroups WHERE ICENUMBER = @IceNumber
END