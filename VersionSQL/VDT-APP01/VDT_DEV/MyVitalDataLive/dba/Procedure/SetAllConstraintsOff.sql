/****** Object:  Procedure [dba].[SetAllConstraintsOff]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 6/16/2010
-- Description:	Disables all constraints for all tables in current database
-- =============================================
CREATE PROCEDURE dba.SetAllConstraintsOff 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
END