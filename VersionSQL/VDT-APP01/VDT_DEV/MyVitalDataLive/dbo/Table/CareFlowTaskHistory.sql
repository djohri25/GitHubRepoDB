/****** Object:  Table [dbo].[CareFlowTaskHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CareFlowTaskHistory](
	[Id] [int] NOT NULL,
	[MVDID] [varchar](50) NOT NULL,
	[RuleId] [smallint] NOT NULL,
	[ExpirationDate] [datetime] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [varchar](20) NULL,
	[ProductId] [int] NOT NULL,
	[CustomerId] [int] NOT NULL,
	[StatusId] [int] NOT NULL,
	[OwnerGroup] [smallint] NULL
) ON [PRIMARY]