/****** Object:  Table [dbo].[LookupCondition]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCondition](
	[ConditionId] [int] NOT NULL,
	[ConditionName] [nvarchar](50) NULL,
	[ConditionNameSpanish] [varchar](100) NULL,
 CONSTRAINT [PK_LookupCondition] PRIMARY KEY CLUSTERED 
(
	[ConditionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]