/****** Object:  Table [dbo].[Link_ServiceAreaNPI]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_ServiceAreaNPI](
	[ServiceAreaID] [int] NOT NULL,
	[NPI] [varchar](20) NOT NULL
) ON [PRIMARY]