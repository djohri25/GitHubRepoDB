/****** Object:  Table [dbo].[LookupCarePlanLibrary]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCarePlanLibrary](
	[cpLibraryID] [int] NOT NULL,
	[cpLibraryDescription] [nvarchar](max) NULL,
	[cpLibraryStatus] [bit] NOT NULL,
	[cpLibraryCreateDate] [date] NOT NULL,
	[cpLibraryInactiveDate] [date] NULL,
	[cpLibraryCustIDList] [nvarchar](50) NULL,
 CONSTRAINT [PK_LookupCarePlanLibrary] PRIMARY KEY CLUSTERED 
(
	[cpLibraryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[LookupCarePlanLibrary] ADD  CONSTRAINT [DF_LookupCarePlanLibrary_cpLibraryStatus]  DEFAULT ((1)) FOR [cpLibraryStatus]