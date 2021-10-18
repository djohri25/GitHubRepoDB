/****** Object:  Table [dbo].[LookupCodeTypeCondition]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCodeTypeCondition](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CodeType] [varchar](50) NULL,
	[ICDVersion] [varchar](50) NULL,
	[Code] [varchar](50) NULL,
	[Cancer] [bit] NULL,
	[WalmartCancer] [bit] NULL,
	[NonWalmartCancer] [bit] NULL,
	[NonWalmart] [bit] NULL,
	[COE] [bit] NULL,
	[NonCOE] [bit] NULL
) ON [PRIMARY]