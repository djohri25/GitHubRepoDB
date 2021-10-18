/****** Object:  Table [dbo].[ImportErrorLog]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ImportErrorLog](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Date] [datetime] NULL,
	[ProcedureName] [nvarchar](50) NULL,
	[Message] [nvarchar](max) NULL,
	[LineNumber] [nvarchar](50) NULL,
	[DBName] [varchar](20) NULL,
	[AdditionalInfo] [nvarchar](max) NULL,
 CONSTRAINT [PK_ImportErrorLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[ImportErrorLog] ADD  CONSTRAINT [DF_ImportErrorLog_Date]  DEFAULT (getutcdate()) FOR [Date]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/2/2010
-- Description:	<Description,,>
-- 06/08/2017	Marc De Luca	Changed @recipientEmail
-- =============================================
CREATE TRIGGER [dbo].[Notify_Administrator]
   ON [dbo].[ImportErrorLog]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcedureName varchar(50), @Message nvarchar(max),
		@DBName varchar(20), @AdditionalInfo varchar(max),
		@emailBody varchar(max), @recipientEmail varchar(1000)

	select @ProcedureName = procedureName,
		@Message = Message,
		@DBName = DBName,
		@AdditionalInfo = AdditionalInfo
	from inserted

	select @emailBody = '',
		@recipientEmail = 'alerts@vitaldatatech.com'
		
	select @emailBody = 'Error in import procedure' + nchar(13) + nchar(10)
		+ nchar(13) + nchar(10)
		+ 'Procedure name: ' + ISNULL(@procedureName,'') + nchar(13) + nchar(10)
		+ 'Message: ' + ISNULL(@Message,'') + nchar(13) + nchar(10)
		+ 'DBName: ' + ISNULL(@DBName,'') + nchar(13) + nchar(10)
		+ 'Additional Info: ' + ISNULL(@AdditionalInfo,'')

	EXEC msdb.dbo.sp_send_dbmail 
	@profile_name = 'VD-APP01',
	@recipients=@recipientEmail,
	@subject='Import Error',
	@body=@emailBody
END

ALTER TABLE [dbo].[ImportErrorLog] DISABLE TRIGGER [Notify_Administrator]