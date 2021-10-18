/****** Object:  Table [dbo].[LookupOrganDonorTypeID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupOrganDonorTypeID](
	[OrganDonorID] [int] NOT NULL,
	[OrganDonorName] [nvarchar](20) NULL,
	[OrganDonorNameSpanish] [nvarchar](40) NULL,
 CONSTRAINT [PK_LookupYesNo] PRIMARY KEY CLUSTERED 
(
	[OrganDonorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]