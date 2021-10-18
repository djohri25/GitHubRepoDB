/****** Object:  Table [dbo].[MainVTAdmin]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainVTAdmin](
	[Email] [varchar](50) NOT NULL,
	[Name] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
	[LastLogin] [datetime] NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_MainVTAdmin_1] PRIMARY KEY CLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MainVTAdmin] ADD  CONSTRAINT [DF_MainVTAdmin_CreationDate]  DEFAULT (getdate()) FOR [CreationDate]
ALTER TABLE [dbo].[MainVTAdmin] ADD  CONSTRAINT [DF_MainVTAdmin_ModifyDate]  DEFAULT (getdate()) FOR [ModifyDate]