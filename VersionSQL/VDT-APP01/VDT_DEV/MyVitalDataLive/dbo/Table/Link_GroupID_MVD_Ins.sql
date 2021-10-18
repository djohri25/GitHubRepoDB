/****** Object:  Table [dbo].[Link_GroupID_MVD_Ins]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_GroupID_MVD_Ins](
	[MVDGroupId] [nvarchar](50) NOT NULL,
	[InsGroupId] [nvarchar](20) NULL,
	[GroupId_834] [nvarchar](20) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_Link_MVDGroup_InsGroup] PRIMARY KEY CLUSTERED 
(
	[MVDGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_GroupID_MVD_Ins] ADD  CONSTRAINT [DF_Link_MVDGroup_InsGroup_Created]  DEFAULT (getutcdate()) FOR [Created]