/****** Object:  Table [dbo].[LookupDrugType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupDrugType](
	[DrugId] [varchar](1) NOT NULL,
	[DrugName] [varchar](50) NULL,
	[DrugNameSpanish] [nvarchar](100) NULL,
 CONSTRAINT [PK_LookupDrugType] PRIMARY KEY CLUSTERED 
(
	[DrugId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]