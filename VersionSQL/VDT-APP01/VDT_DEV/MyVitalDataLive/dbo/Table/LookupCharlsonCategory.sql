/****** Object:  Table [dbo].[LookupCharlsonCategory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCharlsonCategory](
	[CategoryID] [int] NOT NULL,
	[Category] [varchar](30) NULL,
	[CategoryDesc] [varchar](300) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_LookupCharlsonCategory] PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[LookupCharlsonCategory] ADD  CONSTRAINT [DF_LookupCharlsonCategory_CreateDate]  DEFAULT (getutcdate()) FOR [CreateDate]