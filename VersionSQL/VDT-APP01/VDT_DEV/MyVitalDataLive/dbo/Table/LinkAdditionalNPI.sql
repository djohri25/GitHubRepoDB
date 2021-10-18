/****** Object:  Table [dbo].[LinkAdditionalNPI]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LinkAdditionalNPI](
	[ProviderID] [varchar](15) NULL,
	[NPI] [int] NULL,
	[TIN] [int] NULL,
	[AdditionalNPI] [int] NULL,
	[Created] [datetime] NULL
) ON [PRIMARY]