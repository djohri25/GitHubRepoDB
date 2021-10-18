/****** Object:  Procedure [dbo].[Set_PatientFollowupDetails]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:      Tim Thein
-- Create date: 9/22/2009
-- Description: Inserts a row into PatientFollowupDetails and updates status 
--              in a corresponding row in EDPatientStatus
-- =============================================
CREATE PROCEDURE dbo.Set_PatientFollowupDetails
	@MemberID VARCHAR(15), 
	@PatientFirstName VARCHAR(32), 
	@PatientLastName VARCHAR(32), 
	@FacilityID INT, 
	@DateVisited DATETIME, 
	@DateCalled DATETIME, 
	@IsComplete BIT, 
	@YN1 TINYINT, 
	@MC2 TINYINT, 
	@YN4 TINYINT, 
	@YN5 TINYINT, 
	@MC6 TINYINT, 
	@YN7 TINYINT, 
	@YN8 TINYINT, 
	@YN9 TINYINT, 
	@YN10 TINYINT, 
	@YN11 TINYINT, 
	@YN12 TINYINT, 
	@Text3 TEXT, 
	@Text6 TEXT, 
	@Text12 TEXT,
	@EDPatientStatusID INT, 
	@Status VARCHAR(16),
	@Username VARCHAR(50)
AS
BEGIN TRAN
	INSERT PatientFollowupDetails
		(MemberID, PatientFirstName, PatientLastName, FacilityID, 
		DateVisited, DateCalled, EDPatientStatusID, IsComplete, 
		YN1, MC2, YN4, YN5, MC6, YN7, YN8, YN9, YN10, YN11, YN12, 
		Text3, Text6, Text12, ModifiedBy)
	VALUES 
		(@MemberID, @PatientFirstName, @PatientLastName, @FacilityID, 
		@DateVisited, @DateCalled, @EDPatientStatusID, @IsComplete, 
		@YN1, @MC2, @YN4, @YN5, @MC6, @YN7, @YN8, @YN9, @YN10, @YN11, @YN12, 
		@Text3, @Text6, @Text12, @Username)
		
	UPDATE	EDPatientStatus
	SET		Status = @Status, ModifiedBy = @Username, DateModified = GETUTCDATE()
	WHERE	ID = @EDPatientStatusID
COMMIT TRAN