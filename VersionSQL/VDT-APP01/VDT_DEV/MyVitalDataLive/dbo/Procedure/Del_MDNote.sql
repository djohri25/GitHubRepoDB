/****** Object:  Procedure [dbo].[Del_MDNote]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Del_MDNote]
	@RecordID int,
	@UserID varchar(50)		-- Need in case we want to restrict access rights to notes
as

set nocount on

update HPAlertNote set active = 0 where ID = @RecordID

--Delete
--From MD_Note
--Where ID = @RecordID