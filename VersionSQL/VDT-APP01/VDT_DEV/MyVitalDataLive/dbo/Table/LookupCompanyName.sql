/****** Object:  Table [dbo].[LookupCompanyName]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCompanyName](
	[company_key] [varchar](50) NULL,
	[company_name] [varchar](100) NULL,
	[common_emp_id] [varchar](50) NULL,
	[prov_fac_ind] [varchar](50) NULL,
	[emp_clinic_data_source] [varchar](50) NULL,
	[ext_drug_data_source] [varchar](50) NULL,
	[audit_key] [varchar](50) NULL,
	[incl_company_in_batch_rpt] [varchar](50) NULL,
	[LoadDate] [datetime] NULL,
	[recordID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_LookupCompanyName] PRIMARY KEY CLUSTERED 
(
	[recordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]