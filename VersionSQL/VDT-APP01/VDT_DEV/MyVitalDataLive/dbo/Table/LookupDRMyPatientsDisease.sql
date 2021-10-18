/****** Object:  Table [dbo].[LookupDRMyPatientsDisease]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupDRMyPatientsDisease](
	[ID] [int] NOT NULL,
	[Name] [varchar](50) NULL,
	[Abbreviation] [varchar](10) NULL,
	[OrderInd] [varchar](10) NULL,
 CONSTRAINT [PK_LookupDRMyPatientsDisease] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]