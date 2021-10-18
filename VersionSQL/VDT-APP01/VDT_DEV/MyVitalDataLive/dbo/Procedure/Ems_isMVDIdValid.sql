/****** Object:  Procedure [dbo].[Ems_isMVDIdValid]    Committed by VersionSQL https://www.versionsql.com ******/

----------------------------------------------------------------
-- Checks if the patient identified by @IceNum (MyVitalData ID)
-- exists in the system
----------------------------------------------------------------
CREATE Procedure [dbo].[Ems_isMVDValid]
	@IceNum varchar(15)

AS
	SET NOCOUNT ON
	DECLARE @Count int

	SELECT @Count = COUNT(*) FROM MainICENUMBERGroups WHERE ICENUMBER = @IceNum

	SELECT @Count