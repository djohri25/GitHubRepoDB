/****** Object:  Table [dbo].[LookupGroup]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupGroup](
	[grp_span_hist_key] [varchar](255) NULL,
	[grp_key] [varchar](255) NULL,
	[span_chg_dt] [varchar](255) NULL,
	[span_eff_dt] [varchar](255) NULL,
	[span_term_dt] [varchar](255) NULL,
	[span_term_chg_dt] [varchar](255) NULL,
	[span_void_dt] [varchar](255) NULL,
	[span_void_id] [varchar](255) NULL,
	[span_void_ind] [varchar](255) NULL,
	[fake_span_ind] [varchar](255) NULL,
	[clone_span_ind] [varchar](255) NULL,
	[data_source] [varchar](255) NULL,
	[source_code] [varchar](255) NULL,
	[company_key] [varchar](255) NULL,
	[grp_id] [varchar](255) NULL,
	[grp_name] [varchar](255) NULL,
	[LoadDate] [datetime] NULL,
	[recordID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_LookupGroup] PRIMARY KEY CLUSTERED 
(
	[recordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]