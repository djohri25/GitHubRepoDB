/****** Object:  Procedure [dbo].[Upd_HPMemberNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Upd_HPMemberNote]
	@NoteID int,
	@UserID varchar(50),
	@Note varchar(2000),
	@StatusID int,
	@Result int out
AS
BEGIN
	SET NOCOUNT ON;

	set @Result = -1

	declare @mvdid varchar(50)
	
	update HPAlertNote set
		note = @note,
		AlertStatusID = @StatusID,
		modifiedBy = @UserID,
		datemodified = getutcdate()
	where ID = @NoteID

	select @mvdid = mvdid from HPAlertNote where ID= @NoteID
	
	EXEC Upd_HPMemberUpdater
		@MVDID = @MVDID,
		@UpdaterUsername = @UserID,
		@StatusID = @StatusID
		
	set @Result = 0
END