/****** Object:  Table [dbo].[CFR_Rule_Exclusion]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CFR_Rule_Exclusion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RuleID] [int] NULL,
	[ExclusionID] [int] NULL
) ON [PRIMARY]