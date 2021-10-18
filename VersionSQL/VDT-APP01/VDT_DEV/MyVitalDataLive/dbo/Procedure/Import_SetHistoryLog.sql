/****** Object:  Procedure [dbo].[Import_SetHistoryLog]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 2/17/2009
-- Description:	Create a history log for imported record
--	It can be used later to trace changes on MVD record.
-- Action: A - add, U - update, D - delete
-- =============================================
CREATE PROCEDURE [dbo].[Import_SetHistoryLog]
	@MVDID varchar(20),
	@ImportRecordID int,
	@HPAssignedID varchar(50),
	@MVDRecordID int,
	@Action char(1),
	@RecordType varchar(50),
	@Customer varchar(50),
	@SourceName varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	--insert into [156465-APP1].[HPM_Import].dbo.ImportHistory
	INSERT INTO ImportHistory 
		(MVDID, ImportRecordID, HPAssignedID, MVDRecordID, [Action], RecordType, Customer, SourceName, DBName)
	VALUES
		(@MVDID, @ImportRecordID, @HPAssignedID, @MVDRecordID, @Action, @RecordType, @Customer, @SourceName, DB_Name())
END