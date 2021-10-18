/****** Object:  Table [dbo].[Link_TestDueStatus_Customer]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_TestDueStatus_Customer](
	[StatusID] [int] NOT NULL,
	[CustID] [int] NOT NULL,
	[RemoveAfterDayCount] [int] NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_Link_TestDueStatus_Customer] PRIMARY KEY CLUSTERED 
(
	[StatusID] ASC,
	[CustID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_TestDueStatus_Customer] ADD  CONSTRAINT [DF_Link_TestDueStatus_Customer_Created]  DEFAULT (getutcdate()) FOR [Created]