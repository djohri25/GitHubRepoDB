/****** Object:  Function [dbo].[HPAlert_RowLock_Status]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 9/18/2009
-- Description:	Returns either NULL or the owner of the row lock on HPAlert table
-- =============================================
CREATE FUNCTION [dbo].[HPAlert_RowLock_Status] 
(
	@id int
)
RETURNS nvarchar(64)
AS
BEGIN
	DECLARE @result nvarchar(64)

	SELECT	@result = Owner
	FROM	HPAlert_RowLock
	WHERE	HPAlertID = @id AND DateLocked >= DATEADD(mi, -5, GETUTCDATE())

	RETURN @result
END