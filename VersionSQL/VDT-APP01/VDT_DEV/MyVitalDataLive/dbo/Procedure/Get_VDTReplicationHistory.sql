/****** Object:  Procedure [dbo].[Get_VDTReplicationHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
Get_VDTReplicationHistory
(
	@p_Id bigint = NULL OUTPUT,
	@p_JobId nvarchar(255) = NULL OUTPUT,
	@p_JobName nvarchar(255) = NULL OUTPUT,
	@p_InstanceId bigint = NULL OUTPUT,
	@p_Status int = -1 OUTPUT,
	@p_RespondedFlag bit = 0 OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_Id bigint;

	SELECT
	@v_Id = MAX( Id )
	FROM
	VDTReplicationHistory
	WHERE
	CASE
	WHEN @p_JobId IS NULL AND @p_JobName IS NULL THEN 0
	WHEN @p_JobId = JobId THEN 1
	WHEN @p_JobName = JobName THEN 1
	ELSE 0
	END = 1;

	IF ( @v_Id IS NOT NULL )
	BEGIN
		SELECT
		@p_Id = Id,
		@p_JobId = JobId,
		@p_JobName = JobName,
		@p_InstanceID = InstanceID,
		@p_Status = Status,
		@p_RespondedFlag = RespondedFlag
		FROM
		VDTReplicationHistory
		WHERE
		Id = @v_Id;
	END;
END;