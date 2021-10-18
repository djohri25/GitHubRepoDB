/****** Object:  Table [Job].[Activities]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Job].[Activities](
	[SPID] [int] NOT NULL,
	[Name] [nvarchar](64) NULL,
	[StopFlag] [bit] NOT NULL,
	[Status] [nvarchar](128) NULL,
 CONSTRAINT [PK_Activities] PRIMARY KEY CLUSTERED 
(
	[SPID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [Job].[Activities] ADD  CONSTRAINT [DF_Activities_SPID]  DEFAULT (@@spid) FOR [SPID]
ALTER TABLE [Job].[Activities] ADD  CONSTRAINT [DF_Activities_Name]  DEFAULT (object_name(@@procid)) FOR [Name]
ALTER TABLE [Job].[Activities] ADD  CONSTRAINT [DF_Activities_StopFlag]  DEFAULT ((0)) FOR [StopFlag]