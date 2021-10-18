/****** Object:  Table [dbo].[Temp_LookupHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Temp_LookupHistory](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Entered_PatientID] [varchar](50) NULL,
	[SearchType] [varchar](50) NULL,
	[Result] [varchar](50) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_Temp_LookupHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Temp_LookupHistory] ADD  CONSTRAINT [DF_Temp_LookupHistory_Created]  DEFAULT (getutcdate()) FOR [Created]