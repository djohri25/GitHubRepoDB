/****** Object:  Table [dbo].[UserPreference]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[UserPreference](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](50) NULL,
	[CustID] [int] NULL,
	[ProductTypeID] [int] NULL,
	[ProductID] [int] NULL,
	[UserDefinedLayout] [varchar](8000) NULL,
	[ApplicationId] [int] NULL
) ON [PRIMARY]