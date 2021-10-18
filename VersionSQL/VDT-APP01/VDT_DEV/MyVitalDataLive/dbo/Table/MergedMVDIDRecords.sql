/****** Object:  Table [dbo].[MergedMVDIDRecords]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MergedMVDIDRecords](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RetainedMVDID] [varchar](20) NOT NULL,
	[ReplacedMVDID] [varchar](20) NOT NULL,
	[RetainedMemberID] [varchar](20) NOT NULL,
	[ReplacedMemberID] [varchar](20) NOT NULL,
	[Created] [datetime] NOT NULL,
 CONSTRAINT [PK_MergedMVDIDRecords_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MergedMVDIDRecords] ADD  CONSTRAINT [DF_MergedMVDIDRecords_Created]  DEFAULT (getdate()) FOR [Created]