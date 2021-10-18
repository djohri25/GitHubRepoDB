/****** Object:  Procedure [dbo].[Upd_HPAlertNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Upd_HPAlertNote]
	@NoteID int,
	@UserID varchar(50),
	@Note varchar(max),
	@StatusID int,
	@AlertID int,		-- NOTE: it's not necessarily the same alert to which the note is assigned
						--	For example: all notes can be displayed for particular member, not only for specific alert
	@Result int out
AS
BEGIN
	SET NOCOUNT ON;

	set @Result = -1

	update hpAlertNote set
		note = @note,
		AlertStatusID = @StatusID,
		modifiedBy = @UserID,		
		modifiedByType = 'HP',
		datemodified = getutcdate()
	where ID = @NoteID

	update HPAlert 
	set StatusID = @StatusID, DateModified = GETUTCDATE(), ModifiedBy = @UserID
	where ID = @AlertID

	set @Result = 0
END