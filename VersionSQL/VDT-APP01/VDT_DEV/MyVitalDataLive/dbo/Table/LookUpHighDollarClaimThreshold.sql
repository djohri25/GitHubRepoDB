/****** Object:  Table [dbo].[LookUpHighDollarClaimThreshold]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookUpHighDollarClaimThreshold](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlanGroup] [varchar](100) NULL,
	[LOB] [varchar](100) NULL,
	[HighDollarThreshold] [decimal](18, 2) NOT NULL,
	[CustID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL
) ON [PRIMARY]