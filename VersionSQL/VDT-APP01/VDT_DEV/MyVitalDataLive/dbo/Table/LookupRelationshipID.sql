/****** Object:  Table [dbo].[LookupRelationshipID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupRelationshipID](
	[RelationshipID] [int] NOT NULL,
	[RelationshipName] [varchar](50) NULL,
	[RelationshipNameSpanish] [nvarchar](100) NULL,
 CONSTRAINT [PK_LookupRelationshipID] PRIMARY KEY CLUSTERED 
(
	[RelationshipID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]