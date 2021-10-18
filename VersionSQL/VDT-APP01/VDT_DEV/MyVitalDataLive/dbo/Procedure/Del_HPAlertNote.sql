/****** Object:  Procedure [dbo].[Del_HPAlertNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Del_HPAlertNote]
	@NoteID int,
	@UserId varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	--delete from hpAlertNote where ID = @NoteId
	
	update hpAlertNote set active = 0 where ID = @NoteId
END