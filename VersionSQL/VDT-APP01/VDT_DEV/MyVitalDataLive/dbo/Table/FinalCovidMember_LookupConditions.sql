/****** Object:  Table [dbo].[FinalCovidMember_LookupConditions]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[FinalCovidMember_LookupConditions](
	[memberid] [varchar](15) NULL,
	[condition] [varchar](300) NULL,
	[conditionvalue] [varchar](2) NULL,
	[Loaddate] [datetime] NULL
) ON [PRIMARY]