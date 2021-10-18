/****** Object:  Table [dbo].[LookupMaritalStatusID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupMaritalStatusID](
	[MaritalStatusID] [int] NOT NULL,
	[MaritalStatusName] [varchar](20) NOT NULL,
	[MaritalStatusNameSpanish] [nvarchar](40) NOT NULL,
 CONSTRAINT [PK_LookupMaritalStatusID] PRIMARY KEY CLUSTERED 
(
	[MaritalStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]