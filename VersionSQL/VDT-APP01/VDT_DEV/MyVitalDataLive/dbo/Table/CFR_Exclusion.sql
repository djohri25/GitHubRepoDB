/****** Object:  Table [dbo].[CFR_Exclusion]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CFR_Exclusion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Family] [varchar](255) NULL,
	[Exclusion] [varchar](255) NULL,
	[Description] [varchar](1000) NULL
) ON [PRIMARY]