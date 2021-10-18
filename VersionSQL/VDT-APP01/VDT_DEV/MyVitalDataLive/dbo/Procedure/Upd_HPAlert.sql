/****** Object:  Procedure [dbo].[Upd_HPAlert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/06/2008
-- Description:	 Updates an Agent Alert
-- =============================================
CREATE PROCEDURE [dbo].[Upd_HPAlert]
	@ID int,
	@Status int,
	@Username nvarchar(64),
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;

	SET @Result = -1

	IF EXISTS(SELECT ID FROM HPAlert WHERE ID = @ID)
	BEGIN
		-- update record in main rule table
		DECLARE	@UTC datetime
		SET		@UTC = GETUTCDATE() 
		UPDATE	HPAlert 
		SET		StatusID = @Status, ModifiedBy = @Username, DateModified = @UTC
		WHERE	ID = @ID	

		SET @Result = 0
	END
END