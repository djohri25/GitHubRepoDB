/****** Object:  Table [dbo].[LookupSubgroup]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupSubgroup](
	[sub_grp_span_hist_key] [varchar](50) NULL,
	[sub_grp_key] [varchar](50) NULL,
	[span_chg_dt] [varchar](50) NULL,
	[span_eff_dt] [varchar](50) NULL,
	[span_term_dt] [varchar](50) NULL,
	[span_term_chg_dt] [varchar](50) NULL,
	[span_void_dt] [varchar](50) NULL,
	[span_void_id] [varchar](50) NULL,
	[span_void_ind] [varchar](50) NULL,
	[fake_span_ind] [varchar](50) NULL,
	[clone_span_ind] [varchar](50) NULL,
	[data_source] [varchar](50) NULL,
	[source_code] [varchar](50) NULL,
	[grp_key] [varchar](50) NULL,
	[grp_id] [varchar](50) NULL,
	[sub_grp_id] [varchar](50) NULL,
	[sub_grp_name] [varchar](100) NULL,
	[LoadDate] [datetime] NULL,
	[recordID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_LookupSubgroup] PRIMARY KEY CLUSTERED 
(
	[recordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]