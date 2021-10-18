/****** Object:  Table [dbo].[tempMainInsurance_History_MissingTermination2]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tempMainInsurance_History_MissingTermination2](
	[RecordNumber] [int] NOT NULL,
	[ICENUMBER] [varchar](20) NOT NULL,
	[EffectiveDate] [smalldatetime] NULL,
	[TerminationDate] [smalldatetime] NULL,
	[isProcessed] [bit] NULL,
 CONSTRAINT [PK_tempMainInsurance_History_MissingTermination2] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tempMainInsurance_History_MissingTermination2] ADD  CONSTRAINT [DF_tempMainInsurance_History_MissingTermination2_isProcessed]  DEFAULT ((0)) FOR [isProcessed]