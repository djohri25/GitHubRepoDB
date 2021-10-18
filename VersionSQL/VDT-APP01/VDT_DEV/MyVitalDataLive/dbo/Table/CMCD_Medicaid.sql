/****** Object:  Table [dbo].[CMCD_Medicaid]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CMCD_Medicaid](
	[NPI] [varchar](50) NOT NULL,
	[Medicaid] [varchar](50) NOT NULL,
 CONSTRAINT [PK_CMCD_Medicaid] PRIMARY KEY CLUSTERED 
(
	[NPI] ASC,
	[Medicaid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]