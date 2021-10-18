/****** Object:  Procedure [dbo].[Set_Attachment]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_Attachment]  

@ICENUMBER varchar(15),
@FileName varchar(250),
@BinaryName varchar(50) = NULL,
@MIMEType varchar(50),
@Description varchar(250),
@FileSize int,
@Data varbinary(MAX) = NULL

AS

SET NOCOUNT ON

INSERT INTO MainAttachments
(ICENUMBER, [FileName], BinaryName, MIMEType, Description, FileSize, CreationDate, ModifyDate, Data) 
VALUES (@ICENUMBER, @FileName, @BinaryName, @MIMEType, @Description, @FileSize, 
GETUTCDATE(), GETUTCDATE(), @Data)