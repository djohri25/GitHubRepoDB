/****** Object:  Table [dbo].[MMEOverlapANDOpioidUseDisorder_p360d]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MMEOverlapANDOpioidUseDisorder_p360d](
	[MVDID] [varchar](30) NULL,
	[PartyKey] [int] NULL,
	[CFR_Indicator_MMEOverlap_p360d] [int] NULL,
	[CFR_Indicator_OpioidUseDisorder_p360d] [int] NULL,
	[CFR_Indicator_PredictedMMEOverlapSUDDx_f360d] [int] NULL,
	[Prob_Predicted_SUD] [decimal](12, 2) NULL
) ON [PRIMARY]