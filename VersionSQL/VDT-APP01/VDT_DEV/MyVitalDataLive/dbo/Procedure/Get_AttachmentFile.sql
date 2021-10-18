/****** Object:  Procedure [dbo].[Get_AttachmentFile]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_AttachmentFile]
	@IceNumber varchar(15), -- to check user permission
	@RecNum int
As


SET NOCOUNT ON

	SELECT [FileName], BinaryName, MIMEType, FileSize, Data FROM MainAttachments
	WHERE ICENUMBER = @IceNumber AND RecordNumber = @RecNum