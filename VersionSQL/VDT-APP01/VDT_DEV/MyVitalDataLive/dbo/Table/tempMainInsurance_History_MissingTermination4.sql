/****** Object:  Table [dbo].[tempMainInsurance_History_MissingTermination4]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tempMainInsurance_History_MissingTermination4](
	[RecordNumber] [int] IDENTITY(1,1) NOT NULL,
	[ICENUMBER] [varchar](20) NOT NULL,
	[EffectiveDate] [smalldatetime] NULL,
	[TerminationDate] [smalldatetime] NULL,
	[isProcessed] [bit] NULL,
 CONSTRAINT [PK_tempMainInsurance_History_MissingTermination4] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tempMainInsurance_History_MissingTermination4] ADD  CONSTRAINT [DF_tempMainInsurance_History_MissingTermination4_isProcessed]  DEFAULT ((0)) FOR [isProcessed]