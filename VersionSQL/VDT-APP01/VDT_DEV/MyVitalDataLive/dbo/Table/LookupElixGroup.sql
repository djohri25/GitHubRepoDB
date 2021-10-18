/****** Object:  Table [dbo].[LookupElixGroup]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupElixGroup](
	[GroupID] [int] NOT NULL,
	[GroupName] [varchar](60) NULL,
	[Abbr] [varchar](20) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[VW_Weight] [int] NULL,
	[SID30_Weight] [int] NULL,
	[SID29_Weight] [int] NULL,
 CONSTRAINT [PK_LookupElixGroup] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[LookupElixGroup] ADD  CONSTRAINT [DF_LookupElixGroup_CreateDate]  DEFAULT (getutcdate()) FOR [CreateDate]