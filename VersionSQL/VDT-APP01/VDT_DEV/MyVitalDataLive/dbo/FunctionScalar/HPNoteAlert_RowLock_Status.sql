/****** Object:  Function [dbo].[HPNoteAlert_RowLock_Status]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 8/21/2013
-- Description:	Returns either NULL or the owner of the row lock on HPAlert table
-- =============================================
create FUNCTION [dbo].[HPNoteAlert_RowLock_Status] 
(
	@id int
)
RETURNS nvarchar(64)
AS
BEGIN
	DECLARE @result nvarchar(64)

	SELECT	@result = Owner
	FROM	HPNoteAlert_RowLock
	WHERE	HPNoteAlertID = @id AND DateLocked >= DATEADD(mi, -5, GETUTCDATE())

	RETURN @result
END