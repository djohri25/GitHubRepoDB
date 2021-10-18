/****** Object:  Table [dbo].[Workflow_Columns]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Workflow_Columns](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Cust_IDs] [nvarchar](max) NOT NULL,
	[columnName] [nvarchar](max) NOT NULL,
	[displayLabel] [nvarchar](max) NULL,
	[filterType] [int] NULL,
	[inputType] [int] NULL,
	[uniqueFilterflag] [bit] NULL,
	[operators] [int] NULL,
	[values] [varchar](max) NULL,
	[validationType] [int] NULL,
	[validationMin] [int] NULL,
	[validationMax] [int] NULL,
	[validationStep] [int] NULL,
	[optgroup] [nvarchar](max) NULL,
	[tableName] [nvarchar](max) NULL,
	[linkName] [nvarchar](50) NULL,
 CONSTRAINT [PK_Workflow_Columns] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[Workflow_Columns] ADD  DEFAULT (' ') FOR [Cust_IDs]
ALTER TABLE [dbo].[Workflow_Columns] ADD  DEFAULT ((0)) FOR [uniqueFilterflag]
ALTER TABLE [dbo].[Workflow_Columns] ADD  DEFAULT ((0)) FOR [validationMin]
ALTER TABLE [dbo].[Workflow_Columns] ADD  DEFAULT ((1000)) FOR [validationMax]
ALTER TABLE [dbo].[Workflow_Columns] ADD  DEFAULT ((1)) FOR [validationStep]