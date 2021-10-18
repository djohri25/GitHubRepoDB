/****** Object:  Table [dbo].[HPTestDueGoal]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPTestDueGoal](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustID] [int] NULL,
	[TestDueID] [int] NULL,
	[Goal] [decimal](8, 2) NULL,
	[Created] [date] NULL,
	[PrevYearPerc] [int] NULL,
	[DRLink_Active] [bit] NULL,
	[PlankLink_Active] [bit] NULL,
 CONSTRAINT [PK_HPTestDueGoal] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_HPTestDueGoal] ON [dbo].[HPTestDueGoal]
(
	[CustID] ASC,
	[TestDueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[HPTestDueGoal] ADD  CONSTRAINT [DF_HPTestDueGoal_Created]  DEFAULT (getutcdate()) FOR [Created]