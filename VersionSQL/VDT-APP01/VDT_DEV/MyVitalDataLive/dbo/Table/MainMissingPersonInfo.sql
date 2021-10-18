/****** Object:  Table [dbo].[MainMissingPersonInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainMissingPersonInfo](
	[PrimaryKey] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[IceNumber] [varchar](20) NOT NULL,
	[FirstName] [nvarchar](25) NULL,
	[LastName] [nvarchar](25) NULL,
	[Alias] [nvarchar](50) NULL,
	[Gender] [nvarchar](10) NULL,
	[Race] [nvarchar](10) NULL,
	[DOB] [datetime] NULL,
	[Height] [int] NULL,
	[Weight] [nvarchar](25) NULL,
	[HairColor] [nvarchar](25) NULL,
	[EyeColor] [nvarchar](25) NULL,
	[BloodType] [nvarchar](10) NULL,
	[Characteristics] [nvarchar](500) NULL,
	[Clothing] [nvarchar](500) NULL,
	[MedicationTaken] [nvarchar](500) NULL,
	[DiseasesConditions] [nvarchar](500) NULL,
	[Miscellaneous] [nvarchar](1500) NULL,
	[MissingAddress1] [nvarchar](50) NULL,
	[MissingAddress2] [nvarchar](50) NULL,
	[MissingCity] [nvarchar](25) NULL,
	[MissingState] [nvarchar](10) NULL,
	[MissingZip] [nvarchar](10) NULL,
	[MissingDate] [datetime] NULL,
	[Circumstances] [nvarchar](500) NULL,
	[ContactName] [nvarchar](150) NULL,
	[ContactPhone] [nvarchar](20) NULL,
	[LastModified] [datetime] NULL,
	[ImageData] [varbinary](max) NULL,
 CONSTRAINT [PK_MainMissingPersonInfo] PRIMARY KEY CLUSTERED 
(
	[PrimaryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]