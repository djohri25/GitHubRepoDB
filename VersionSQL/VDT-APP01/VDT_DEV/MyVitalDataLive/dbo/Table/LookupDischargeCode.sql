/****** Object:  Table [dbo].[LookupDischargeCode]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupDischargeCode](
	[admit_type_key] [int] NOT NULL,
	[admit_type_cd] [varchar](50) NOT NULL,
	[admit_type_name] [varchar](50) NOT NULL,
	[data_source] [varchar](50) NOT NULL,
	[valid_ind] [varchar](50) NOT NULL,
	[audit_key] [int] NOT NULL,
	[recordID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_LookupDischargeCode] PRIMARY KEY CLUSTERED 
(
	[recordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]