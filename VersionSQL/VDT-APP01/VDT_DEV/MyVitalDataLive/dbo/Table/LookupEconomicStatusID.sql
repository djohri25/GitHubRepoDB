/****** Object:  Table [dbo].[LookupEconomicStatusID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupEconomicStatusID](
	[EconomicStatusID] [int] NOT NULL,
	[EconomicStatusName] [varchar](20) NULL,
	[EconomicStatusNameSpanish] [nvarchar](40) NULL,
 CONSTRAINT [PK_LookupEconomicStatusID] PRIMARY KEY CLUSTERED 
(
	[EconomicStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]