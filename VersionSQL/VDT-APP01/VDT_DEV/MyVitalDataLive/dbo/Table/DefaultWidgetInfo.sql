/****** Object:  Table [dbo].[DefaultWidgetInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DefaultWidgetInfo](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](50) NOT NULL,
	[WidgetName] [varchar](50) NOT NULL,
	[Cust_ID] [int] NOT NULL,
	[ProductId] [int] NULL,
 CONSTRAINT [PK_DefaultWidgetInfo_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [UK_DefaultWidgetInfo_UserName_WidgetName_CustID] ON [dbo].[DefaultWidgetInfo]
(
	[UserName] ASC,
	[WidgetName] ASC,
	[Cust_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]