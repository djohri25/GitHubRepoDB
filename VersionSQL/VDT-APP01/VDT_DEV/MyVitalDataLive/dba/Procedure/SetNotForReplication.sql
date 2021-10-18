/****** Object:  Procedure [dba].[SetNotForReplication]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dba].[SetNotForReplication]
AS
	EXEC sp_msforeachtable @command1 = 
	'
		declare @int int
		set @int =object_id("?")
		EXEC sys.sp_identitycolumnforreplication @int, 1
	'