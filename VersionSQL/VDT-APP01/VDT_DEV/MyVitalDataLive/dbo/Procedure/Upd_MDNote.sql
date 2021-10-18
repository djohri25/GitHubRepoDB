/****** Object:  Procedure [dbo].[Upd_MDNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 7/7/2009
-- Description:	Update MD note
-- =============================================
CREATE PROCEDURE [dbo].[Upd_MDNote]
	@RecordID int,
	@Text varchar(2000),
	@UserID varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	update hpAlertNote
	set Note = @Text, ModifiedBy = @UserID, ModifiedByType = 'MD', DateModified = GETUTCDATE()
	where ID = @RecordID
	

	--update MD_Note 
	--	set Text = @Text,ModifyByUserID = @UserID, ModifyDate = getutcdate()
	--where ID = @RecordID
END