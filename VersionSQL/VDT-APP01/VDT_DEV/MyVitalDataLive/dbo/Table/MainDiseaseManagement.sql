/****** Object:  Table [dbo].[MainDiseaseManagement]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainDiseaseManagement](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
	[Created] [datetime] NULL,
	[DM_ID] [int] NULL,
	[name] [varchar](100) NULL,
 CONSTRAINT [PK_MainDiseaseManagement] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainDiseaseManagement] ON [dbo].[MainDiseaseManagement]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MainDiseaseManagement] ADD  CONSTRAINT [DF_MainDiseaseManagement_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[MainDiseaseManagement]  WITH CHECK ADD  CONSTRAINT [FK_MainDiseaseManagement_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[MainDiseaseManagement] CHECK CONSTRAINT [FK_MainDiseaseManagement_MainPersonalDetails]