/****** Object:  Procedure [dbo].[CheckReplicationStatus]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
CheckReplicationStatus
(
	@p_JobName nvarchar(255),
	@p_CompletedYN bit = 0 OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_Id bigint;
	DECLARE @v_JobId nvarchar(255);
	DECLARE @v_InstanceId bigint;
	DECLARE @v_Status int;
	DECLARE @v_RespondedFlag bit;

	DECLARE @v_JobStartDateTime datetime;

	DECLARE @v_SubscriberDB nvarchar(255) = CONCAT( 'MyVitalData', REPLACE( @p_JobName, 'Replication Job ', '' ) );
	DECLARE @v_ShortDBName nvarchar(255) = REPLACE( @p_JobName, 'Replication Job ', '' );

	DECLARE @v_ComputedJobNameLive nvarchar(255) = 'Daily - Run Computed Procedures-Live';
	DECLARE @v_ComputedJobNameUAT nvarchar(255) = 'Daily - Run Computed Procedures';

	EXEC Get_VDTReplicationHistory
		@p_Id = @v_Id OUTPUT,
		@p_JobId = @v_JobId OUTPUT,
		@p_JobName = @p_JobName,
		@p_InstanceId = @v_InstanceId OUTPUT,
		@p_Status = @v_Status OUTPUT,
		@p_RespondedFlag = @v_RespondedFlag OUTPUT;

-- If the job is completed and has not been responded to
	IF ( @v_Status = 1 AND @v_RespondedFlag = 0 )
	BEGIN
		IF ( @v_ShortDBName = 'Live' )
		BEGIN
			EXEC msdb.dbo.sp_start_job @v_ComputedJobNameLive;
			EXEC Respond_VDTReplicationHistory @p_JobName;
		END
		ELSE
		BEGIN
			IF ( @v_ShortDBName = 'UAT')
			BEGIN
				EXEC msdb.dbo.sp_start_job @v_ComputedJobNameUAT;
				EXEC Respond_VDTReplicationHistory @p_JobName;
			END;
		END;
	END;
END;