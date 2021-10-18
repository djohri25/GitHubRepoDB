/****** Object:  Procedure [dbo].[Del_HPMemberNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Del_HPMemberNote]
	@NoteID int,
	@UserId varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	declare @mvdid varchar(50)
	
	select @mvdid = mvdid from HPAlertNote where ID= @NoteID
	
	delete from HPAlertNote where ID = @NoteId

	EXEC Upd_HPMemberUpdater
		@MVDID = @MVDID,
		@UpdaterUsername = @UserID
END