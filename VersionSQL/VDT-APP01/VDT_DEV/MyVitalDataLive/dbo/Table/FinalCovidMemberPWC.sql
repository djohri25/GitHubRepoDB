/****** Object:  Table [dbo].[FinalCovidMemberPWC]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[FinalCovidMemberPWC](
	[MemberID] [varchar](15) NULL,
	[State] [varchar](2) NULL,
	[City] [varchar](50) NULL,
	[countyname] [varchar](30) NULL,
	[Zipcode] [varchar](9) NULL,
	[CmOrgRegion] [varchar](50) NULL,
	[LOB] [varchar](2) NULL,
	[MVDID] [varchar](30) NULL,
	[MemberFirstName] [varchar](50) NULL,
	[MemberLastName] [varchar](50) NULL,
	[Age] [int] NULL,
	[Sex] [varchar](1) NULL,
	[LatestDxDate] [datetime] NULL,
	[FirstDxDate] [datetime] NULL,
	[Loaddate] [date] NULL
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [idx_FinalCovidMemberPWC_Loaddate] ON [dbo].[FinalCovidMemberPWC]
(
	[Loaddate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]