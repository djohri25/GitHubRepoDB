/****** Object:  Procedure [dbo].[Get_PatientFollowupPreviousCalls]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.Get_PatientFollowupPreviousCalls
	@EDPatientStatusID	int	
AS
BEGIN
	SELECT	DateCalled
	FROM	PatientFollowupDetails
	WHERE	EDPatientStatusID = @EDPatientStatusID
	ORDER	BY DateCalled DESC
END