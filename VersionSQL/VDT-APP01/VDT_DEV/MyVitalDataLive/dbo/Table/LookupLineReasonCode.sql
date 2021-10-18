/****** Object:  Table [dbo].[LookupLineReasonCode]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupLineReasonCode](
	[src_ln_rsn_cd] [varchar](50) NULL,
	[data_source] [varchar](50) NULL,
	[src_ln_rsn_name] [varchar](1000) NULL,
	[src_ln_rsn_keyword] [varchar](50) NULL,
	[audit_key] [varchar](50) NULL,
	[LoadDate] [datetime] NULL,
	[recordID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_LookupLineReasonCode] PRIMARY KEY CLUSTERED 
(
	[recordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]