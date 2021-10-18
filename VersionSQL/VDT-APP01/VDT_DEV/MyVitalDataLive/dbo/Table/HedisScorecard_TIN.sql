/****** Object:  Table [dbo].[HedisScorecard_TIN]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HedisScorecard_TIN](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ScoreCardID] [int] NULL,
	[TIN] [varchar](50) NULL,
	[DRLink_Active] [bit] NULL,
	[PlanLink_Active] [bit] NULL,
	[AffinityQuality_Active] [bit] NULL,
 CONSTRAINT [PK_HedisScorecard_TIN] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[HedisScorecard_TIN] ADD  CONSTRAINT [DF_HedisScorecard_TIN_DRLink_Active]  DEFAULT ((0)) FOR [DRLink_Active]
ALTER TABLE [dbo].[HedisScorecard_TIN] ADD  CONSTRAINT [DF_HedisScorecard_TIN_PlanLink_Active]  DEFAULT ((0)) FOR [PlanLink_Active]
ALTER TABLE [dbo].[HedisScorecard_TIN] ADD  CONSTRAINT [DF_HedisScorecard_TIN_AffinityQuality_Active]  DEFAULT ((0)) FOR [AffinityQuality_Active]