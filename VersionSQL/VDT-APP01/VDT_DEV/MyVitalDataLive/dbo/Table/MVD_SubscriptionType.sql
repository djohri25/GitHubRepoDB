/****** Object:  Table [dbo].[MVD_SubscriptionType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MVD_SubscriptionType](
	[ID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Price] [money] NULL,
	[AdditionalProfileCount] [int] NULL,
	[DurationValue] [int] NULL,
	[DurationUnit] [varchar](50) NULL
) ON [PRIMARY]