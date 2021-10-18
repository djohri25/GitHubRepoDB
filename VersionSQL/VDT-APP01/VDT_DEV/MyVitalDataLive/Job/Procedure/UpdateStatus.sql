/****** Object:  Procedure [Job].[UpdateStatus]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE Job.UpdateStatus
	@Status nvarchar(128)
AS
BEGIN
	SET NOCOUNT ON
	UPDATE	Job.Activities
	SET		[Status] = @Status
	WHERE	SPID = @@spid
END