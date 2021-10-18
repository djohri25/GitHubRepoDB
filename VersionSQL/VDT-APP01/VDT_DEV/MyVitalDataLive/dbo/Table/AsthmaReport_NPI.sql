/****** Object:  Table [dbo].[AsthmaReport_NPI]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AsthmaReport_NPI](
	[NPI] [varchar](20) NOT NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[CustID] [int] NOT NULL,
 CONSTRAINT [PK_AsthmaReport_NPI] PRIMARY KEY CLUSTERED 
(
	[NPI] ASC,
	[CustID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]