/****** Object:  Table [dbo].[Link_DuplicateRecords]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_DuplicateRecords](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MVDID_1] [varchar](20) NOT NULL,
	[MVDID_2] [varchar](20) NOT NULL,
	[Status] [varchar](50) NULL,
	[MergedRecordMVDID] [varchar](50) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_Link_NOTDuplicateRecords] PRIMARY KEY CLUSTERED 
(
	[MVDID_1] ASC,
	[MVDID_2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_DuplicateRecords] ADD  CONSTRAINT [DF_Link_NOTDuplicateRecords_Created]  DEFAULT (getutcdate()) FOR [Created]