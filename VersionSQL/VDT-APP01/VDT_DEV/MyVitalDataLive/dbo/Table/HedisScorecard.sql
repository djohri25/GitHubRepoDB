/****** Object:  Table [dbo].[HedisScorecard]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HedisScorecard](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustID] [int] NOT NULL,
	[SubmeasureID] [int] NOT NULL,
	[Goal] [decimal](8, 2) NOT NULL,
	[Group] [varchar](20) NULL,
	[DRLink_Active] [bit] NULL,
	[PlanLink_Active] [bit] NULL,
	[AffinityQuality_Active] [bit] NULL,
	[MeasurePerformance_Active] [bit] NULL,
	[isIncentive] [bit] NOT NULL,
	[DRLink_BirthdayFilter] [bit] NOT NULL,
	[PriorYearRateAdmin] [decimal](8, 2) NULL,
	[PriorYearRateHybrid] [decimal](8, 2) NULL,
	[LOB] [varchar](10) NULL,
 CONSTRAINT [PK_HedisScorecard] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]