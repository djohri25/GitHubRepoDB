/****** Object:  Table [dbo].[temp_final_covid_member_positive_without_contact]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[temp_final_covid_member_positive_without_contact](
	[MemberID] [varchar](15) NULL,
	[MVDID] [varchar](30) NULL,
	[MemberLastName] [varchar](50) NULL,
	[MemberFirstName] [varchar](50) NULL,
	[cmOrgRegion] [varchar](50) NULL,
	[LatestDxDate] [date] NULL,
	[FirstDxDate] [date] NULL,
	[lob] [varchar](2) NULL,
	[gender] [varchar](1) NULL,
	[age] [int] NULL,
	[city] [varchar](50) NULL,
	[state] [varchar](2) NULL,
	[zip] [varchar](9) NULL,
	[county] [varchar](30) NULL
) ON [PRIMARY]