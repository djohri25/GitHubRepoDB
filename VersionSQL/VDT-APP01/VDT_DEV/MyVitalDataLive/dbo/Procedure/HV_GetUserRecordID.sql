/****** Object:  Procedure [dbo].[HV_GetUserRecordID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 12/30/07
-- Description:	Gets HealthVault user and record IDs
-- =============================================
CREATE PROCEDURE [dbo].[HV_GetUserRecordID]
	-- Add the parameters for the stored procedure here
	@ICENUMBER varchar(15), 
	@HVUserID char(36) OUT,
	@HVRecordID char(36) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @HVUserID = HVUserID, @HVRecordID = HVRecordID
	FROM MainICENUMBERGroups
	WHERE ICENUMBER = @ICENUMBER
END