/****** Object:  Table [dbo].[SubscriptionReport]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SubscriptionReport](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Name] [varchar](100) NULL,
	[Subject] [varchar](200) NULL,
	[ReportDate] [datetime] NULL,
	[Content] [varbinary](max) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_SubscriptionReport] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[SubscriptionReport] ADD  CONSTRAINT [DF_SubscriptionReport_Created]  DEFAULT (getutcdate()) FOR [Created]