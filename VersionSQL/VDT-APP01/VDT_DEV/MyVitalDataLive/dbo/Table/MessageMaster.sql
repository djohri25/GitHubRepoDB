/****** Object:  Table [dbo].[MessageMaster]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MessageMaster](
	[MessageID] [int] IDENTITY(1,1) NOT NULL,
	[DeviceID] [varchar](50) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[From] [varchar](50) NOT NULL,
	[Subject] [varchar](100) NOT NULL,
	[Date] [datetime] NOT NULL,
	[MessageText] [varchar](max) NOT NULL,
	[WasRead] [bit] NULL,
 CONSTRAINT [PK_MessageMaster] PRIMARY KEY CLUSTERED 
(
	[MessageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[MessageMaster] ADD  CONSTRAINT [DF_MessageMaster_Date]  DEFAULT (getutcdate()) FOR [Date]
ALTER TABLE [dbo].[MessageMaster] ADD  CONSTRAINT [DF_MessageMaster_WasRead]  DEFAULT ((0)) FOR [WasRead]