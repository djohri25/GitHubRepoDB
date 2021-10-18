/****** Object:  Procedure [dbo].[Del_Attachment]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Del_Attachment]

@RecNum int

as

SET NOCOUNT ON

DELETE MainAttachments WHERE RecordNumber = @RecNum