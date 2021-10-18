/****** Object:  Procedure [dbo].[Get_UserDefinedItems]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 11/12/2009
-- Description:	Get the list of user defined items
--	GetAll - if 1 return all items defined by user
--		otherwise returns items not processed yet
-- =============================================
CREATE PROCEDURE [dbo].[Get_UserDefinedItems]
	@ItemType varchar(50),
	@GetAll bit = 0
AS
BEGIN
	SET NOCOUNT ON;

	IF @ItemType = 'DIAGNOSIS'
		SELECT	code
		FROM	LookupUserDefDiagnosis
		WHERE	@GetAll = 1 OR IsProcessed = 0
	ELSE IF @ItemType = 'MEDICATION'
		SELECT	code
		FROM	LookupUserDefMedication
		WHERE	@GetAll = 1 OR IsProcessed = 0
	ELSE IF @ItemType = 'PROCEDURE'
		SELECT	code
		FROM	LookupUserDefProcedure
		WHERE	@GetAll = 1 OR IsProcessed = 0
END