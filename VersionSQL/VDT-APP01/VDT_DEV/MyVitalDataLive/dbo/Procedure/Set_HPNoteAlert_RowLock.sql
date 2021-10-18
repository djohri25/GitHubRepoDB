/****** Object:  Procedure [dbo].[Set_HPNoteAlert_RowLock]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 8/21/2013
-- Description:	If the specified owner is null, row lock is released for the 
--   specified record, otherwise, an attempt to lock row will be made and 
--   return the owner that successfully locks the row.  If row is already
--   locked to specified owner, the DateLocked is updated.  Note: DateLocked
--   that is more than 5 minutes old are expired and should be deleted.
-- =============================================
create PROCEDURE [dbo].[Set_HPNoteAlert_RowLock] 
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
		DELETE	HPNoteAlert_RowLock
		WHERE	HPNoteAlertID = @id
	END
	ELSE
	BEGIN
		DECLARE	@UTC datetime
		SET @UTC = GETUTCDATE()
		BEGIN TRAN
			
			DELETE	HPNoteAlert_RowLock
			WHERE	HPNoteAlertID = @id AND DateLocked < DATEADD(mi, -5, @UTC)
			
			SELECT	@result = Owner
			FROM	HPNoteAlert_RowLock
			WITH	(SERIALIZABLE)
			WHERE	HPNoteAlertID = @id
			
			IF @result IS NULL
				INSERT	HPNoteAlert_RowLock (HPNoteAlertID, Owner)
				VALUES	(@id, @owner)
			ELSE IF @result = @owner
				UPDATE	HPNoteAlert_RowLock
				SET		DateLocked = @UTC
				WHERE	HPNoteAlertID = @id
			ELSE
				SET		@owner = @result	
		COMMIT TRAN
	END
END