/****** Object:  Table [dbo].[ABCBS_NurseLicense]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_NurseLicense](
	[RecordID] [nvarchar](50) NULL,
	[LicenseState] [nvarchar](50) NULL,
	[LicenseExpirationDate] [datetime] NULL,
	[License] [nvarchar](50) NULL,
	[LicenseCredentialDate] [nvarchar](50) NULL,
	[NetworkID] [nvarchar](255) NULL,
	[StateIssued] [nvarchar](50) NULL,
	[CompactState] [nvarchar](50) NULL,
	[SourceFileName] [nvarchar](255) NULL,
	[CreateDate] [datetime] NULL,
	[County] [nvarchar](50) NULL
) ON [PRIMARY]