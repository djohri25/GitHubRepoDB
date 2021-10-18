/****** Object:  Procedure [dbo].[HV_DeleteImportedItems]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Created:		9/10/08
-- Modified:	9/10/08
-- Description:	Deletes items previously imported from a CCD
-- =============================================
CREATE PROCEDURE dbo.HV_DeleteImportedItems
	@ICENUMBER varchar(15), 
	@HVID char(36)
AS
BEGIN
	BEGIN TRAN
		DELETE FROM MainImmunization
		WHERE     (ICENUMBER = @ICENUMBER) AND (HVID = @HVID) AND (HVFlag = 1) 
		DELETE FROM MainInsurance
		WHERE     (ICENUMBER = @ICENUMBER) AND (HVID = @HVID) AND (HVFlag = 1) 
		DELETE FROM MainMedication
		WHERE     (ICENUMBER = @ICENUMBER) AND (HVID = @HVID) AND (HVFlag = 1) 
		DELETE FROM MainSurgeries
		WHERE     (ICENUMBER = @ICENUMBER) AND (HVID = @HVID) AND (HVFlag = 1) 
	COMMIT TRAN
END