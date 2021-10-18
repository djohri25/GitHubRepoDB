/****** Object:  Table [dbo].[LookupBillType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupBillType](
	[bill_type_key] [varchar](50) NULL,
	[bill_type_cd] [varchar](50) NULL,
	[bill_type_desc] [varchar](100) NULL,
	[bill_type_cat_cd] [varchar](50) NULL,
	[bill_type_cat_name] [varchar](50) NULL,
	[bill_type_freq_cd] [varchar](50) NULL,
	[bill_type_freq_desc] [varchar](300) NULL,
	[bill_type_freq_use_desc] [varchar](300) NULL,
	[drg_incl_ind] [varchar](50) NULL,
	[valid_ind] [varchar](50) NULL,
	[phi_sens_ind] [varchar](50) NULL,
	[data_source] [varchar](50) NULL,
	[audit_key] [varchar](50) NULL,
	[LoadDate] [datetime] NULL,
	[recordID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_LookupBillType] PRIMARY KEY CLUSTERED 
(
	[recordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]