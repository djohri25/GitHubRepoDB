/****** Object:  Table [dbo].[LetterMembersInvalidAddress]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LetterMembersInvalidAddress](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[MemberID] [varchar](15) NULL,
	[MemberFirstName] [varchar](50) NULL,
	[MemberLastName] [varchar](50) NULL,
	[Address1] [varchar](100) NULL,
	[Address2] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](2) NULL,
	[Zipcode] [varchar](9) NULL,
	[DateOfBirth] [date] NULL,
	[SubscriberID] [varchar](10) NULL,
	[Suffix] [varchar](15) NULL,
	[ProcessedDate] [date] NULL
) ON [PRIMARY]

CREATE CLUSTERED INDEX [IC_ID] ON [dbo].[LetterMembersInvalidAddress]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]