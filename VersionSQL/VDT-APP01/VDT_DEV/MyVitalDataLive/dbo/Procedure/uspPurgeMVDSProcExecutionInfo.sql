/****** Object:  Procedure [dbo].[uspPurgeMVDSProcExecutionInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
uspPurgeMVDSProcExecutionInfo
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_num_days_to_keep bigint = 3;

	DELETE FROM
	MVDSProcExecutionInfo
	WHERE
	start_time <= CAST( DATEADD( DAY, -1 * @v_num_days_to_keep, getDate() ) AS date );
END;