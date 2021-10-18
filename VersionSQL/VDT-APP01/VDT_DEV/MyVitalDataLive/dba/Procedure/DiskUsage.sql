/****** Object:  Procedure [dba].[DiskUsage]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 03/25/2010
-- Description:	Returns the disk usage of the current database
-- =============================================
CREATE PROCEDURE dba.DiskUsage
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @data TABLE (Fileid int, FileGroup int, TotalExtents real, UsedExtents real, Name varchar(100),	FileName varchar(100))
	INSERT @data EXEC('DBCC SHOWFILESTATS WITH NO_INFOMSGS')
	DECLARE @log TABLE (Name varchar(100), Size real, PercentUsed real, Status int)
	INSERT @log EXEC('DBCC SQLPERF(logspace) WITH NO_INFOMSGS')
	SELECT db_name() 'Database', 'Data' 'Type', CONVERT(int,(TotalExtents)/16) SizeMB, CONVERT(int,(TotalExtents-UsedExtents)/16) FreeMB, ROUND((TotalExtents-UsedExtents)/TotalExtents*100, 1) FreePercent FROM @data
	UNION ALL
	SELECT db_name() 'Database', 'Log' 'Type', ROUND(Size, 0) SizeMB, ROUND((100-PercentUsed)*Size/100, 0) FreeMB, ROUND(100-PercentUsed, 1) FreePercent FROM @log WHERE name = db_name()
END