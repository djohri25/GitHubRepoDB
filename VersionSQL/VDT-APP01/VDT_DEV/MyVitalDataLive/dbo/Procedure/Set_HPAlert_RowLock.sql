/****** Object:  Procedure [dbo].[Set_HPAlert_RowLock]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 9/18/2009
-- Description:	If the specified owner is null, row lock is released for the 
--   specified record, otherwise, an attempt to lock row will be made and 
--   return the owner that successfully locks the row.  If row is already
--   locked to specified owner, the DateLocked is updated.  Note: DateLocked
--   that is more than 5 minutes old are expired and should be deleted.
-- =============================================
CREATE PROCEDURE [dbo].[Set_HPAlert_RowLock] 
	@id int, 
	@owner nvarchar(64) = NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @result nvarchar(64)
	SET	@result = NULL
	IF @owner IS NULL
	BEGIN
		DELETE	HPAlert_RowLock
		WHERE	HPAlertID = @id
	END
	ELSE
	BEGIN
		DECLARE	@UTC datetime
		SET @UTC = GETUTCDATE()
		BEGIN TRAN
			
			DELETE	HPAlert_RowLock
			WHERE	HPAlertID = @id AND DateLocked < DATEADD(mi, -5, @UTC)
			
			SELECT	@result = Owner
			FROM	HPAlert_RowLock
			WITH	(SERIALIZABLE)
			WHERE	HPAlertID = @id
			
			IF @result IS NULL
				INSERT	HPAlert_RowLock (HPAlertID, Owner)
				VALUES	(@id, @owner)
			ELSE IF @result = @owner
				UPDATE	HPAlert_RowLock
				SET		DateLocked = @UTC
				WHERE	HPAlertID = @id
			ELSE
				SET		@owner = @result	
		COMMIT TRAN
	END
END