/****** Object:  Procedure [Job].[Unregister]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE Job.Unregister
AS
BEGIN
	SET NOCOUNT ON
	DELETE	Job.Activities
	WHERE	SPID = @@spid
END