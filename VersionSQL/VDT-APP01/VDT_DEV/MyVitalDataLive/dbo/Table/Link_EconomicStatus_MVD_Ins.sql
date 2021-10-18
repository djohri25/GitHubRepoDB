/****** Object:  Table [dbo].[Link_EconomicStatus_MVD_Ins]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_EconomicStatus_MVD_Ins](
	[MVDEconomicStatusId] [int] NOT NULL,
	[InsEconomicStatusId] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Link_EconomicStatus_MVD_Ins] PRIMARY KEY CLUSTERED 
(
	[MVDEconomicStatusId] ASC,
	[InsEconomicStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]