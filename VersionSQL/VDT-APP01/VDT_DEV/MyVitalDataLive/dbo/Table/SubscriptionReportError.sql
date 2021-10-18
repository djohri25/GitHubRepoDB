/****** Object:  Table [dbo].[SubscriptionReportError]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SubscriptionReportError](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Message] [varchar](4000) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_SubscriptionReportError] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[SubscriptionReportError] ADD  CONSTRAINT [DF_SubscriptionReportError_Created]  DEFAULT (getutcdate()) FOR [Created]