/****** Object:  Table [dbo].[Link_HPAlertGroupAgent]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPAlertGroupAgent](
	[Group_ID] [smallint] NOT NULL,
	[Agent_ID] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Link_HPGroupAgent] PRIMARY KEY CLUSTERED 
(
	[Group_ID] ASC,
	[Agent_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPAlertGroupAgent]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPAlertGroupAgent_HPAlertGroup] FOREIGN KEY([Group_ID])
REFERENCES [dbo].[HPAlertGroup] ([ID])
ALTER TABLE [dbo].[Link_HPAlertGroupAgent] CHECK CONSTRAINT [FK_Link_HPAlertGroupAgent_HPAlertGroup]