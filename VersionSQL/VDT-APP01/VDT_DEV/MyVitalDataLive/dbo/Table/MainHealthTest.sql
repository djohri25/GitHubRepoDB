/****** Object:  Table [dbo].[MainHealthTest]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainHealthTest](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
	[TestId] [int] NULL,
	[DateDone] [datetime] NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_MainHealthTest] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MainHealthTest]  WITH CHECK ADD  CONSTRAINT [FK_MainHealthTest_LookupHealthTest] FOREIGN KEY([TestId])
REFERENCES [dbo].[LookupHealthTest] ([TestId])
ALTER TABLE [dbo].[MainHealthTest] CHECK CONSTRAINT [FK_MainHealthTest_LookupHealthTest]
ALTER TABLE [dbo].[MainHealthTest]  WITH CHECK ADD  CONSTRAINT [FK_MainHealthTest_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON DELETE CASCADE
ALTER TABLE [dbo].[MainHealthTest] CHECK CONSTRAINT [FK_MainHealthTest_MainPersonalDetails]