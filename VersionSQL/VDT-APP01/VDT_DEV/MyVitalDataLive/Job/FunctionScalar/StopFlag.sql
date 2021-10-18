/****** Object:  Function [Job].[StopFlag]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION Job.StopFlag ()
RETURNS int
AS
BEGIN
	DECLARE @StopFlag int
	SELECT	@StopFlag = StopFlag
	FROM	Job.Activities
	WHERE	SPID = @@spid
	RETURN	ISNULL(@StopFlag, 1)
END