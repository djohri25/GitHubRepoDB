/****** Object:  Procedure [dbo].[Respond_VDTReplicationHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
Respond_VDTReplicationHistory
(
	@p_JobName nvarchar(255)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_Id bigint;
	DECLARE @v_JobId nvarchar(255);
	DECLARE @v_InstanceId bigint;
	DECLARE @v_Status int;
	DECLARE @v_RespondedFlag bit;

-- Get the most recent run for the job
	SELECT
	@v_Id = MAX( Id )
	FROM
	VDTReplicationHistory
	WHERE
	JobName = @p_JobName;

-- Confirm that the job has completed
	EXEC Get_VDTReplicationHistory
		@p_Id = @v_Id OUTPUT,
		@p_JobId = @v_JobId OUTPUT,
		@p_JobName = @p_JobName,
		@p_InstanceId = @v_InstanceId OUTPUT,
		@p_Status = @v_Status OUTPUT,
		@p_RespondedFlag = @v_RespondedFlag OUTPUT;

-- Should only be able to respond to completed jobs that have not been processed
	IF ( @v_Status = 1 AND @v_RespondedFlag = 0 )
	BEGIN
		UPDATE
		VDTReplicationHistory
		SET
		RespondedFlag = 1
		WHERE
		Id = @v_Id;
	END;
END;