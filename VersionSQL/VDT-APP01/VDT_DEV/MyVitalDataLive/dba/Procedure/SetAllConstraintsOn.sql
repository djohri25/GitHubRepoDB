/****** Object:  Procedure [dba].[SetAllConstraintsOn]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 6/16/2010
-- Description:	Enables all constraints for all tables in current database
-- =============================================
CREATE PROCEDURE dba.SetAllConstraintsOn
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	EXEC sp_MSforeachtable @command1='PRINT ''?''', @command2='ALTER TABLE ? CHECK CONSTRAINT ALL'
END