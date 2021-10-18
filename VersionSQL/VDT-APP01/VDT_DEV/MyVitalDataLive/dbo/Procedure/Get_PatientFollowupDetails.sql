/****** Object:  Procedure [dbo].[Get_PatientFollowupDetails]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.Get_PatientFollowupDetails
	@EDPatientStatusID int
AS
	SELECT	TOP 1
			ID, MemberID, CustID, PatientFirstName, PatientLastName, FacilityID, DateVisited, 
			DateCalled, EDPatientStatusID, IsComplete, YN1, MC2, YN4, YN5, MC6, 
			YN7, YN8, YN9, YN10, YN11, YN12, Text3, Text6, Text12, 
			ModifiedBy, DateCreated, DateModified
	FROM	PatientFollowupDetails
	WHERE	EDPatientStatusID = @EDPatientStatusID
	ORDER BY DateModified DESC