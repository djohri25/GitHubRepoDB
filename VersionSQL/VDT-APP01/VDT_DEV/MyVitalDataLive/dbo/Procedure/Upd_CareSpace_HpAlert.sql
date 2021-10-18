/****** Object:  Procedure [dbo].[Upd_CareSpace_HpAlert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 03/07/2017
-- Description:	This storeproc will update HPAlert record with appropriate statusId based on carespace action.
-- =============================================
CREATE PROCEDURE [dbo].[Upd_CareSpace_HpAlert]
	@ID int,
	@Status int,
	@Username varchar(50),
	@Result int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SET @Result = -1

	IF EXISTS(SELECT ID FROM HPAlert WHERE ID = @ID and StatusID not in (2, 3))
	BEGIN
		-- update record in main rule table
		DECLARE	@UTC datetime
		SET		@UTC = GETUTCDATE() 
		UPDATE	HPAlert 
		SET		StatusID = @Status, ModifiedBy = @Username, DateModified = @UTC
		WHERE	ID = @ID	

		SET @Result = 0
	END
	else if exists(SELECT ID FROM HPAlert WHERE ID = @ID and StatusID in (2, 3))
	begin
		set @Result = -2
	end
END