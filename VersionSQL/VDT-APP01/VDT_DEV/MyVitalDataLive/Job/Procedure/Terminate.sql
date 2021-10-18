/****** Object:  Procedure [Job].[Terminate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE Job.Terminate
AS
BEGIN
	SET NOCOUNT ON
	UPDATE	Job.Activities
	SET		StopFlag = 1
	WHERE	SPID = @@spid
END