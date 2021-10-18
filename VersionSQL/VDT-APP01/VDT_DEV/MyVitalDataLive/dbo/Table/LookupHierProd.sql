/****** Object:  Table [dbo].[LookupHierProd]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupHierProd](
	[hier_prod_cd] [varchar](50) NULL,
	[hier_prod_name] [varchar](50) NULL,
	[hier_prod_desc] [varchar](100) NULL,
	[audit_key] [varchar](50) NULL,
	[LoadDate] [datetime] NULL,
	[recordID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_LookupHierProd] PRIMARY KEY CLUSTERED 
(
	[recordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]