/****** Object:  Table [dbo].[LookupCS_MemberNoteForms_20210521]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCS_MemberNoteForms_20210521](
	[FormID] [int] NOT NULL,
	[FormName] [nvarchar](50) NULL,
	[ProcedureName] [nvarchar](50) NULL,
	[Type] [varchar](50) NULL,
	[Active] [bit] NULL,
	[Cust_IDs] [nvarchar](50) NULL,
	[DocFormType] [varchar](100) NULL,
	[DocFormGroup] [varchar](150) NULL
) ON [PRIMARY]