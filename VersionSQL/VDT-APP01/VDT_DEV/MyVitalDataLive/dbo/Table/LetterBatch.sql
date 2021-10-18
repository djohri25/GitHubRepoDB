/****** Object:  Table [dbo].[LetterBatch]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LetterBatch](
	[BatchID] [int] IDENTITY(1,1) NOT NULL,
	[LOB] [varchar](100) NULL,
	[ProcessedDate] [varchar](50) NULL,
	[RecordsProcessed] [varchar](50) NULL,
	[BrandingName] [varchar](100) NULL,
	[CMOrgReg] [varchar](100) NULL
) ON [PRIMARY]