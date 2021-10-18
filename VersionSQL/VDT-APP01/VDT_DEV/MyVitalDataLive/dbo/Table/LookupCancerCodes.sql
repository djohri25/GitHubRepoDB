/****** Object:  Table [dbo].[LookupCancerCodes]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCancerCodes](
	[CodeType] [varchar](50) NULL,
	[ICDVersion] [varchar](50) NULL,
	[Code] [varchar](50) NULL,
	[Cancer] [bit] NULL,
	[WalmartCancer] [bit] NULL,
	[NonWalmartCancer] [bit] NULL
) ON [PRIMARY]