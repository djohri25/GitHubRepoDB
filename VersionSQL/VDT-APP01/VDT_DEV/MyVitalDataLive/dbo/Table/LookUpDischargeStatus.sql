/****** Object:  Table [dbo].[LookUpDischargeStatus]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookUpDischargeStatus](
	[dschg_status_key] [varchar](50) NULL,
	[edw_dschg_status_cd] [varchar](50) NULL,
	[edw_dschg_status_name] [varchar](50) NULL,
	[cms_dschg_status_cd] [varchar](50) NULL,
	[cms_dschg_status_name] [varchar](50) NULL,
	[cms_dschg_status_desc] [varchar](255) NULL,
	[data_source] [varchar](50) NULL,
	[data_source_val] [varchar](50) NULL,
	[data_source_desc] [varchar](255) NULL,
	[phi_sens_ind] [varchar](50) NULL,
	[audit_key] [varchar](50) NULL,
	[LoadDate] [datetime] NULL,
	[recordID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_LookUpDischargeStatus] PRIMARY KEY CLUSTERED 
(
	[recordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]