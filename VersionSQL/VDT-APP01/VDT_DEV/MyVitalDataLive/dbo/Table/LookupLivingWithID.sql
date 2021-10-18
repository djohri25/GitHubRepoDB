/****** Object:  Table [dbo].[LookupLivingWithID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupLivingWithID](
	[LivingWithID] [int] IDENTITY(0,1) NOT FOR REPLICATION NOT NULL,
	[LivingWithName] [varchar](20) NULL,
	[LivingWithNameSpanish] [nvarchar](100) NULL,
 CONSTRAINT [PK_LookupLivingWithID] PRIMARY KEY CLUSTERED 
(
	[LivingWithID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]