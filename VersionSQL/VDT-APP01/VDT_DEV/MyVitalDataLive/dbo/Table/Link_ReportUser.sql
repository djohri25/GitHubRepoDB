/****** Object:  Table [dbo].[Link_ReportUser]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_ReportUser](
	[ReportID] [int] NOT NULL,
	[UserID] [uniqueidentifier] NOT NULL,
	[Viewed] [bit] NULL,
 CONSTRAINT [PK_Link_ReportUser] PRIMARY KEY CLUSTERED 
(
	[ReportID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_ReportUser]  WITH CHECK ADD  CONSTRAINT [FK_Link_ReportUser_SubscriptionReport] FOREIGN KEY([ReportID])
REFERENCES [dbo].[SubscriptionReport] ([ID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Link_ReportUser] CHECK CONSTRAINT [FK_Link_ReportUser_SubscriptionReport]