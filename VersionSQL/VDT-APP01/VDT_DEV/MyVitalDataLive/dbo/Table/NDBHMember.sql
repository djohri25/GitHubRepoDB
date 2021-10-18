/****** Object:  Table [dbo].[NDBHMember]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[NDBHMember](
	[MVDID] [varchar](30) NULL,
	[MemberID] [varchar](30) NULL,
	[MemberLastName] [varchar](255) NULL,
	[MemberFirstName] [varchar](255) NULL,
	[DateOfBirth] [date] NULL,
	[Gender] [varchar](10) NULL,
	[CMOrgRegion] [varchar](255) NULL,
	[ERCount] [int] NULL,
	[Category] [varchar](255) NULL
) ON [PRIMARY]