/****** Object:  Table [dbo].[SendSMS]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SendSMS](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RecordAccessID] [int] NULL,
	[Phone] [nvarchar](20) NULL,
	[Text] [nvarchar](300) NULL,
	[SentDate] [datetime] NULL,
	[Status] [nvarchar](50) NULL,
	[StatusCode] [nvarchar](10) NULL,
	[TrackingTag] [nvarchar](30) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_RecordAccessed_SMS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[SendSMS] ADD  CONSTRAINT [DF_RecordAccessed_SMS_Created]  DEFAULT (getutcdate()) FOR [Created]