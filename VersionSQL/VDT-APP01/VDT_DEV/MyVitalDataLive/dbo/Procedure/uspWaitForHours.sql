/****** Object:  Procedure [dbo].[uspWaitForHours]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
uspWaitForHours
(
	@p_Hours int
)
AS
BEGIN
	DECLARE @v_hours varchar(255) = CONCAT( @p_Hours, ':00' );

	WAITFOR DELAY @v_hours;
	EXECUTE sp_helpdb;
END;