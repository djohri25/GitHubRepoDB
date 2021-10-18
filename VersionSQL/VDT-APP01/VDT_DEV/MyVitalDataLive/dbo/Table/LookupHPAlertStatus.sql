/****** Object:  Table [dbo].[LookupHPAlertStatus]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupHPAlertStatus](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NULL,
	[IsCompleted] [bit] NULL,
 CONSTRAINT [PK_LookupHPAlertStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[LookupHPAlertStatus] ADD  CONSTRAINT [DF_LookupHPAlertStatus_IsCompleted]  DEFAULT ((0)) FOR [IsCompleted]