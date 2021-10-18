/****** Object:  Table [dbo].[MainAttachments]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainAttachments](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NOT NULL,
	[FileName] [varchar](250) NULL,
	[BinaryName] [varchar](50) NULL,
	[MIMEType] [varchar](50) NULL,
	[Description] [varchar](250) NULL,
	[FileSize] [int] NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[Data] [varbinary](max) NULL,
 CONSTRAINT [PK_MainAttachments] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainAttachments] ON [dbo].[MainAttachments]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MainAttachments]  WITH CHECK ADD  CONSTRAINT [FK_MainAttachments_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[MainAttachments] CHECK CONSTRAINT [FK_MainAttachments_MainPersonalDetails]