/****** Object:  Table [dbo].[LookupBehaviorHealthAreaofExpertise]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupBehaviorHealthAreaofExpertise](
	[BehavioralHealthCode] [varchar](50) NULL,
	[Description] [varchar](255) NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]