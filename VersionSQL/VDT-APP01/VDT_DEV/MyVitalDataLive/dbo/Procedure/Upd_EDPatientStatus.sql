/****** Object:  Procedure [dbo].[Upd_EDPatientStatus]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.Upd_EDPatientStatus
	@id INT,
	@username VARCHAR(50),
	@status VARCHAR(16)
AS
	UPDATE	EDPatientStatus
	SET		Status = @status, ModifiedBy = @username, DateModified = GETUTCDATE()
	WHERE	ID = @id