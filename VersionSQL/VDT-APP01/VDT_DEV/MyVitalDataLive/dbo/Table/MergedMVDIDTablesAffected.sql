/****** Object:  Table [dbo].[MergedMVDIDTablesAffected]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MergedMVDIDTablesAffected](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [varchar](50) NOT NULL,
	[ReplacedMVDID] [varchar](20) NOT NULL,
	[MergedPrimaryKeys] [varchar](max) NOT NULL,
	[Created] [datetime] NOT NULL,
 CONSTRAINT [PK_MergedMVDIDTablesAffected_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[MergedMVDIDTablesAffected] ADD  CONSTRAINT [DF_MergedMVDIDTablesAffected_Created]  DEFAULT (getdate()) FOR [Created]