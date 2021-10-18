/****** Object:  Table [dbo].[LookupCS_MemberNoteForms]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCS_MemberNoteForms](
	[FormID] [int] NOT NULL,
	[FormName] [nvarchar](50) NULL,
	[ProcedureName] [nvarchar](50) NULL,
	[Type] [varchar](50) NULL,
	[Active] [bit] NULL,
	[Cust_IDs] [nvarchar](50) NULL,
	[DocFormType] [varchar](100) NULL,
	[DocFormGroup] [varchar](150) NULL,
	[LockingCategory] [varchar](128) NULL,
	[LockingValue] [varchar](5) NULL,
	[FormController] [varchar](250) NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_LookupCS_MemberNoteForms_ProcedureName] ON [dbo].[LookupCS_MemberNoteForms]
(
	[ProcedureName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]