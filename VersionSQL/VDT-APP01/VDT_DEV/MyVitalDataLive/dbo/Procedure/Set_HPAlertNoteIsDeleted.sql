/****** Object:  Procedure [dbo].[Set_HPAlertNoteIsDeleted]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 05/13/2019
-- Description:	Update store-proc for HPAlertNote to set IsDeleted flag.
-- =============================================
CREATE PROCEDURE [dbo].[Set_HPAlertNoteIsDeleted]
	@NoteId int,
	@IsDeleted bit,
	@UserName varchar(100),
	@ModifiedDate datetime = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Update HPAlertNote
	set IsDelete = @IsDeleted
	   ,ModifiedBy = @UserName
	   ,DateModified = ISNULL(@ModifiedDate,getutcdate())
	where ID = @NoteId
END