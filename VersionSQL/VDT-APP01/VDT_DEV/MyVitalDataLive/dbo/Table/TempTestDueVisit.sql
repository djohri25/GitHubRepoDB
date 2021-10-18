/****** Object:  Table [dbo].[TempTestDueVisit]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TempTestDueVisit](
	[VisitID] [int] NOT NULL,
	[MVDID] [varchar](20) NULL,
	[VisitDate] [datetime] NULL,
 CONSTRAINT [PK_TempTestDueVisits] PRIMARY KEY CLUSTERED 
(
	[VisitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]