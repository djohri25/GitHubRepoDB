/****** Object:  Table [dbo].[LookupHealthTest]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupHealthTest](
	[TestId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TestName] [varchar](50) NULL,
	[TestNameSpanish] [nvarchar](100) NULL,
 CONSTRAINT [PK_LookupHealthTest] PRIMARY KEY CLUSTERED 
(
	[TestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]