/****** Object:  Table [dbo].[dash_taskage]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[dash_taskage](
	[ID] [bigint] NOT NULL,
	[Title] [nvarchar](100) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[Owner] [varchar](100) NULL,
	[Status] [varchar](100) NULL,
	[TaskAge] [int] NULL,
	[DaysPastDue] [int] NULL,
	[CmOrgRegion] [varchar](50) NULL,
	[LOB] [varchar](255) NULL,
	[company_name] [varchar](100) NULL
) ON [PRIMARY]