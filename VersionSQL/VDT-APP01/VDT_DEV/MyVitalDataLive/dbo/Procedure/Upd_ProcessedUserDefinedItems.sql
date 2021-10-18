/****** Object:  Procedure [dbo].[Upd_ProcessedUserDefinedItems]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 11/12/2009
-- Description:	Update processed flag of user defined items
--	@ItemList - comma separated list of codes to update
--	@UpdAll - if 1 update all unprocessed items
-- =============================================
CREATE PROCEDURE [dbo].[Upd_ProcessedUserDefinedItems]
	@ItemType varchar(50),
	@ItemList varchar(max),
	@UpdAll bit
AS
BEGIN
	SET NOCOUNT ON;

	IF @ItemType = 'DIAGNOSIS'
		UPDATE	ImportErrorUnknownItemLog
		SET		IsProcessed = 1
		WHERE	ItemType = @ItemType AND ItemCode IN
				(
					SELECT	code
					FROM	LookupUserDefDiagnosis
					WHERE	IsProcessed = 0
				)
	ELSE IF @ItemType = 'MEDICATION'
		UPDATE	ImportErrorUnknownItemLog
		SET		IsProcessed = 1
		WHERE	ItemType = @ItemType AND ItemCode IN
				(
					SELECT	code
					FROM	LookupUserDefMedication
					WHERE	IsProcessed = 0
				)
	ELSE IF @ItemType = 'PROCEDURE'
		UPDATE	ImportErrorUnknownItemLog
		SET		IsProcessed = 1
		WHERE	ItemType = @ItemType AND ItemCode IN
				(
					SELECT	code
					FROM	LookupUserDefProcedure
					WHERE	IsProcessed = 0
				)
	ELSE
		RAISERROR('Value of @ItemType is undefined.', 9, 0)
		
	-- Don't process new user defined items again
	IF @ItemType = 'DIAGNOSIS'
		UPDATE	LookupUserDefDiagnosis
		SET		IsProcessed = 1, ProcessedDate = (GETUTCDATE())
		WHERE	IsProcessed = 0
	ELSE IF @ItemType = 'MEDICATION'
		UPDATE	LookupUserDefMedication
		SET		IsProcessed = 1, ProcessedDate = (GETUTCDATE())
		WHERE	IsProcessed = 0
	ELSE IF @ItemType = 'PROCEDURE'
		UPDATE	LookupUserDefProcedure
		SET		IsProcessed = 1, ProcessedDate = (GETUTCDATE())
		WHERE	IsProcessed = 0
	
END