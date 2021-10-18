/****** Object:  Procedure [dbo].[Get_AttachmentTotal]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_AttachmentTotal]
	@IceNumber varchar(15)
As
	SET NOCOUNT ON

	SELECT ISNULL(SUM(FileSize)/1048576.0,0) FROM MainAttachments WHERE ICENUMBER = @IceNumber