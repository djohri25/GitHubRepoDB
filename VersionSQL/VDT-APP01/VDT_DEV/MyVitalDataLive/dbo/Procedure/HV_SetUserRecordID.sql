/****** Object:  Procedure [dbo].[HV_SetUserRecordID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Created: 6/11/08
-- Modified: 9/10/08
-- Description:	Sets HealthVault user and record IDs for an MVD profile and 
--              resets HVID to null since they won't apply after changing user and record IDs.
-- =============================================
CREATE PROCEDURE dbo.HV_SetUserRecordID
	@ICENUMBER varchar(15),
	@HVUserID char(36),
	@HVRecordID char(36)
AS
BEGIN
	DECLARE @CurrentHVUserID char(36), @CurrentHVRecordID char(36)
	SELECT @CurrentHVUserID = HVUserID, @CurrentHVRecordID = HVRecordID
	FROM MainICENUMBERGroups
	WHERE ICENUMBER = @ICENUMBER
	
	IF ISNULL(@CurrentHVUserID, 'null') <> ISNULL(@HVUserID, 'null') OR ISNULL(@CurrentHVRecordID, 'null') <> ISNULL(@HVRecordID, 'null')
	BEGIN
		BEGIN TRAN 
			UPDATE MainICENUMBERGroups
			SET HVUserID = @HVUserID, HVRecordID = @HVRecordID, ModifyDate = GETUTCDATE()
			WHERE ICENUMBER = @ICENUMBER
			
			UPDATE MainAllergies
			SET HVID = NULL
			WHERE ICENUMBER = @ICENUMBER
			
			UPDATE MainCareInfo
			SET HVID = NULL
			WHERE ICENUMBER = @ICENUMBER
			
			UPDATE MainImmunization
			SET HVID = NULL
			WHERE ICENUMBER = @ICENUMBER AND HVFlag = 0
			
			UPDATE MainInsurance
			SET HVID = NULL
			WHERE ICENUMBER = @ICENUMBER AND HVFlag = 0
			
			UPDATE MainMedication
			SET HVID = NULL
			WHERE ICENUMBER = @ICENUMBER AND HVFlag = 0
			
			UPDATE MainSurgeries
			SET HVID = NULL
			WHERE ICENUMBER = @ICENUMBER AND HVFlag = 0
		COMMIT TRAN
	END
END