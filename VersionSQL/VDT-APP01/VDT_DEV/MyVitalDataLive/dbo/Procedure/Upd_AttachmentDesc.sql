/****** Object:  Procedure [dbo].[Upd_AttachmentDesc]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_AttachmentDesc]
	@RecNum int,
	@FileDesc varchar(50)
As

SET NOCOUNT ON

UPDATE MainAttachments SET Description = @FileDesc, ModifyDate = GETUTCDATE() WHERE RecordNumber = @RecNum