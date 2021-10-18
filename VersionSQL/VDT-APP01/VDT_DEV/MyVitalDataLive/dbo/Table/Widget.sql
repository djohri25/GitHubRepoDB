/****** Object:  Table [dbo].[Widget]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Widget](
	[ID] [int] NOT NULL,
	[WidgetName] [varchar](100) NOT NULL,
	[WidgetListTitle] [varchar](250) NULL,
	[WidgetTemplateUrl] [varchar](8000) NULL,
	[WidgetJSFile] [varchar](8000) NULL,
	[WidgetSpecifcEvents] [varchar](max) NULL,
	[DefaultLayout] [varchar](8000) NULL,
	[OrderNumber] [int] NULL,
	[WidgetGroup] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]