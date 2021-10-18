/****** Object:  Procedure [dbo].[Upd_HVIDs]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 12/20/2007
-- Description:	Updates HealthVault user and record id
-- =============================================
CREATE PROCEDURE [dbo].[Upd_HVIDs] 
	-- Add the parameters for the stored procedure here
	@ICENUMBER varchar(15),
	@HVUserID char(36), 
	@HVRecordID char(36)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE MainICENUMBERGroups
	SET HVUserID = @HVUserID, HVRecordID = @HVRecordID, ModifyDate = GETUTCDATE()
	WHERE ICENUMBER = @ICENUMBER
END