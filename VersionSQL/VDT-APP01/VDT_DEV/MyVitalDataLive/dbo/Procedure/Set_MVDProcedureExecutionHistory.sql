/****** Object:  Procedure [dbo].[Set_MVDProcedureExecutionHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
Set_MVDProcedureExecutionHistory
AS
BEGIN
	INSERT INTO
	MVDProcedureExecutionHistory
	(
		ProcedureName,
		ExecutionDatetime
	)
	SELECT
	p.name procedure_name,
	getDate() execution_datetime
	FROM
	sys.dm_exec_requests r
	CROSS APPLY sys.dm_exec_sql_text( r.sql_handle ) t
	INNER JOIN sys.procedures p
	ON p.object_id = t.objectid;
END;