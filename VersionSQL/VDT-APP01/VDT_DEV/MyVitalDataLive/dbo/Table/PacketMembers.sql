/****** Object:  Table [dbo].[PacketMembers]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PacketMembers](
	[FileName] [nvarchar](255) NULL,
	[FileTransferLocation] [nvarchar](255) NULL,
	[CreatedDate] [datetime] NULL,
	[MemberID] [nvarchar](50) NULL,
	[Name] [nvarchar](max) NULL,
	[Email] [nvarchar](255) NULL,
	[Address] [nvarchar](max) NULL,
	[City] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[Zip] [nvarchar](50) NULL,
	[Weight] [float] NULL,
	[PkgType] [nvarchar](50) NULL,
	[Service] [nvarchar](50) NULL,
	[Billto] [nvarchar](50) NULL,
	[Country] [nvarchar](255) NULL,
	[Resind] [nvarchar](50) NULL,
	[Ref1] [nvarchar](50) NULL,
	[PrimaryLanguage] [nvarchar](255) NULL,
	[PrimaryLanguageOther] [nvarchar](255) NULL,
	[EligibleDentalBenefit] [nvarchar](1) NULL,
	[TobaccoUser] [nvarchar](10) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]