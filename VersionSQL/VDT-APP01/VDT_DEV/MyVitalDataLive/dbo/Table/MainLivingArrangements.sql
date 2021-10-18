/****** Object:  Table [dbo].[MainLivingArrangements]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainLivingArrangements](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NOT NULL,
	[LivingWithID] [int] NULL,
	[ContactName] [varchar](50) NULL,
	[ContactPhone] [varchar](10) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_MainLivingArrangements] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainLivingArrangements] ON [dbo].[MainLivingArrangements]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MainLivingArrangements]  WITH CHECK ADD  CONSTRAINT [FK_MainLivingArrangements_LookupLivingWithID] FOREIGN KEY([LivingWithID])
REFERENCES [dbo].[LookupLivingWithID] ([LivingWithID])
ALTER TABLE [dbo].[MainLivingArrangements] CHECK CONSTRAINT [FK_MainLivingArrangements_LookupLivingWithID]
ALTER TABLE [dbo].[MainLivingArrangements]  WITH CHECK ADD  CONSTRAINT [FK_MainLivingArrangements_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[MainLivingArrangements] CHECK CONSTRAINT [FK_MainLivingArrangements_MainPersonalDetails]