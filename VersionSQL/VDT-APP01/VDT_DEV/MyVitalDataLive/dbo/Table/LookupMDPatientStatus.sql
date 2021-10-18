/****** Object:  Table [dbo].[LookupMDPatientStatus]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupMDPatientStatus](
	[ID] [int] NOT NULL,
	[Name] [varchar](50) NULL,
	[Color] [varchar](50) NULL,
 CONSTRAINT [PK_LookupMDPatientStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]