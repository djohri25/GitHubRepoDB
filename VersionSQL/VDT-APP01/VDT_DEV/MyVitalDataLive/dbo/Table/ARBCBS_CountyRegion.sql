/****** Object:  Table [dbo].[ARBCBS_CountyRegion]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ARBCBS_CountyRegion](
	[State] [varchar](2) NOT NULL,
	[CountyName] [varchar](max) NULL,
	[UserName] [varchar](100) NOT NULL,
	[Status] [smallint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[ARBCBS_CountyRegion] ADD  DEFAULT ('') FOR [UserName]
ALTER TABLE [dbo].[ARBCBS_CountyRegion] ADD  DEFAULT ((1)) FOR [Status]