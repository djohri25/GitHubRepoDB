/****** Object:  Table [dbo].[TempAsthmaReport]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TempAsthmaReport](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Icenumber] [varchar](15) NULL,
	[InsMemberId] [varchar](50) NULL,
	[VisitDate] [datetime] NULL,
	[PhoneNumber] [varchar](50) NULL,
	[Facility] [varchar](200) NULL,
	[CustID] [int] NULL,
	[CustomerName] [varchar](50) NULL,
 CONSTRAINT [PK_TempAsthmaReport] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_TempAsthmaReport] ON [dbo].[TempAsthmaReport]
(
	[Icenumber] ASC
)
INCLUDE([VisitDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]