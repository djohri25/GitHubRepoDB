/****** Object:  Table [dbo].[MainFamilyHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainFamilyHistory](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NOT NULL,
	[FamilyHistoryID] [int] NULL,
	[NA] [bit] NULL,
	[Father] [bit] NULL,
	[Mother] [bit] NULL,
	[Sister] [bit] NULL,
	[Brother] [bit] NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_MainFamilyHistory] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainFamilyHistory] ON [dbo].[MainFamilyHistory]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MainFamilyHistory]  WITH CHECK ADD  CONSTRAINT [FK_MainFamilyHistory_LookupFamilyHistoryID] FOREIGN KEY([FamilyHistoryID])
REFERENCES [dbo].[LookupFamilyHistoryID] ([FamilyHistoryID])
ALTER TABLE [dbo].[MainFamilyHistory] CHECK CONSTRAINT [FK_MainFamilyHistory_LookupFamilyHistoryID]
ALTER TABLE [dbo].[MainFamilyHistory]  WITH CHECK ADD  CONSTRAINT [FK_MainFamilyHistory_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[MainFamilyHistory] CHECK CONSTRAINT [FK_MainFamilyHistory_MainPersonalDetails]