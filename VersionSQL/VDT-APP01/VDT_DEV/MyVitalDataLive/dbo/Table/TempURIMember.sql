/****** Object:  Table [dbo].[TempURIMember]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TempURIMember](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[EpisodeDate] [datetime] NOT NULL,
	[DOB] [datetime] NULL,
	[InsMemberID] [varchar](20) NULL,
	[isProcessed] [bit] NULL,
	[FacilityNPI] [varchar](20) NULL,
 CONSTRAINT [PK_TempURIMember] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TempURIMember] ADD  CONSTRAINT [DF_TempURIMember_isProcessed]  DEFAULT ((0)) FOR [isProcessed]