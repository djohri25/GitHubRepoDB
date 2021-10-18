/****** Object:  Table [dbo].[CarePlanLibraryIndex]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CarePlanLibraryIndex](
	[cpLibraryID] [bigint] IDENTITY(1,1) NOT NULL,
	[cpLibraryDescription] [nvarchar](max) NULL,
	[cpLibraryInactiveDate] [date] NULL,
	[cpLibraryCustID] [nvarchar](50) NULL,
	[cpLibrarySubPopList] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
 CONSTRAINT [PK_CarePlanLibraryIndex] PRIMARY KEY CLUSTERED 
(
	[cpLibraryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]