/****** Object:  Procedure [Job].[Register]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE Job.Register
AS
BEGIN
	SET NOCOUNT ON
	INSERT Job.Activities DEFAULT VALUES
END