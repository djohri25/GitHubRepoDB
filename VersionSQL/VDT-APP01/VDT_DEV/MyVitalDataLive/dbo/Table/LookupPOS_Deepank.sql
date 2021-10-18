/****** Object:  Table [dbo].[LookupPOS_Deepank]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupPOS_Deepank](
	[data_source] [varchar](50) NULL,
	[data_source_val] [varchar](50) NULL,
	[data_source_desc] [varchar](200) NULL,
	[audit_key] [varchar](50) NULL,
	[place_of_svc_key] [varchar](50) NULL,
	[place_of_svc_cd] [varchar](50) NULL,
	[place_of_svc_name] [varchar](200) NULL,
	[drg_incl_cd] [varchar](50) NULL,
	[phi_sens_ind] [varchar](50) NULL,
	[LoadDate] [datetime] NULL
) ON [PRIMARY]