/****** Object:  Table [dbo].[LookupRace]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupRace](
	[PrimaryKey] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RaceID] [int] NOT NULL,
	[RaceName] [varchar](50) NOT NULL,
	[RaceNameSpanish] [varchar](50) NULL,
 CONSTRAINT [PK_LookupRace] PRIMARY KEY CLUSTERED 
(
	[PrimaryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]