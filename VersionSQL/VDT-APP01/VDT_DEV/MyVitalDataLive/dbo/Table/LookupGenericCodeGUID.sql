/****** Object:  Table [dbo].[LookupGenericCodeGUID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupGenericCodeGUID](
	[CodeId] [int] NOT NULL,
	[CodeGuid] [uniqueidentifier] NOT NULL
) ON [PRIMARY]