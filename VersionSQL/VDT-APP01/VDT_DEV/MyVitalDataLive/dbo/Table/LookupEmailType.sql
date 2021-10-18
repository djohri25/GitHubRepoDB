/****** Object:  Table [dbo].[LookupEmailType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupEmailType](
	[email_type_key] [varchar](100) NULL,
	[email_type_cd] [varchar](100) NULL,
	[email_type_name] [varchar](100) NULL,
	[data_source] [varchar](100) NULL,
	[data_source_val] [varchar](100) NULL,
	[data_source_desc] [varchar](100) NULL,
	[audit_key] [varchar](100) NULL,
	[recordID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_LookupEmailType] PRIMARY KEY CLUSTERED 
(
	[recordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]