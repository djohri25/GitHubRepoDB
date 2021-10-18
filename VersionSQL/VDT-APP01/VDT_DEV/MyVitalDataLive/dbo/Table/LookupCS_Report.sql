/****** Object:  Table [dbo].[LookupCS_Report]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCS_Report](
	[ReportID] [int] NOT NULL,
	[ReportName] [nvarchar](50) NULL,
	[TemplateID] [varchar](50) NULL,
	[ProcedureName] [varchar](150) NULL,
	[ReportPath] [varchar](100) NULL,
	[Type] [varchar](50) NULL,
	[Active] [bit] NULL,
	[Cust_IDs] [nvarchar](50) NULL,
	[ReportGroup] [varchar](50) NULL,
	[TemplateName] [varchar](100) NULL,
	[ReportParamsJSON] [varchar](max) NULL,
 CONSTRAINT [PK_LookupCS_Report] PRIMARY KEY CLUSTERED 
(
	[ReportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[LookupCS_Report] ADD  CONSTRAINT [DF__LookupCS___Activ__7BE62D87]  DEFAULT ((1)) FOR [Active]