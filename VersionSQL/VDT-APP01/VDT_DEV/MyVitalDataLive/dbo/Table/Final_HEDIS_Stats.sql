/****** Object:  Table [dbo].[Final_HEDIS_Stats]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Final_HEDIS_Stats](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustID] [int] NULL,
	[LastClaimsFileName] [varchar](100) NULL,
	[LastClaimsServiceFromDate] [date] NULL,
	[LastHEDISRunDate] [date] NULL,
	[LastMonthIDProcessed] [char](6) NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_Final_HEDIS_Stats] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Final_HEDIS_Stats] ADD  CONSTRAINT [DF_Final_HEDIS_Stats_UpdateDate]  DEFAULT (getdate()) FOR [UpdateDate]