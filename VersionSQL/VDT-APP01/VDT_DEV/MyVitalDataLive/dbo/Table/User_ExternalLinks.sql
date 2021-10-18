/****** Object:  Table [dbo].[User_ExternalLinks]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[User_ExternalLinks](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustID] [int] NOT NULL,
	[SortOrder] [int] NULL,
	[LinkTarget] [varchar](255) NULL,
	[LinkLabel] [varchar](255) NULL,
	[LinkHRef] [varchar](1000) NULL,
	[LinkImage] [varchar](255) NULL,
	[LinkIcon] [varchar](255) NULL,
	[InAppAction] [varchar](255) NULL,
	[AppObserverService] [varchar](255) NULL,
	[ObserverFunc] [varchar](255) NULL,
	[EventName] [varchar](255) NULL,
	[DataToPass] [varchar](255) NULL
) ON [PRIMARY]