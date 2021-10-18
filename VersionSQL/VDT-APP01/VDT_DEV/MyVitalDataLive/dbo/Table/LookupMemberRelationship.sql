/****** Object:  Table [dbo].[LookupMemberRelationship]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupMemberRelationship](
	[mbr_rel_key] [varchar](100) NULL,
	[mbr_rel_val3_cd] [varchar](100) NULL,
	[mbr_rel_val3_name] [varchar](100) NULL,
	[data_source] [varchar](100) NULL,
	[data_source_val] [varchar](100) NULL,
	[data_source_desc] [varchar](500) NULL,
	[audit_key] [varchar](100) NULL,
	[LoadDate] [datetime] NULL,
	[recordID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_LookupMemberRelationship] PRIMARY KEY CLUSTERED 
(
	[recordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]