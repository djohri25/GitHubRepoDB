/****** Object:  Table [dbo].[LookupFamilyHistoryID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupFamilyHistoryID](
	[FamilyHistoryID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[FamilyHistoryName] [varchar](50) NULL,
	[FamilyHistoryNameSpanish] [varchar](100) NULL,
 CONSTRAINT [PK_LookupFamilyHistoryID] PRIMARY KEY CLUSTERED 
(
	[FamilyHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]