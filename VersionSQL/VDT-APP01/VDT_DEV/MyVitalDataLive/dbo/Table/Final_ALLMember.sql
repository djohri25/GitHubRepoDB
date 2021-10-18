/****** Object:  Table [dbo].[Final_ALLMember]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Final_ALLMember](
	[ID] [int] NOT NULL,
	[mvdid] [varchar](50) NOT NULL,
	[MemberID] [varchar](50) NULL,
	[DOB] [smalldatetime] NULL,
	[HasAsthma] [bit] NULL,
	[HasDiabetes] [bit] NULL,
	[CustID] [int] NULL,
	[CreateDate] [date] NULL,
	[TIN] [nchar](50) NULL,
	[NPI] [nchar](50) NULL,
	[Service_Location_ID] [nchar](50) NULL,
	[PCPID] [nchar](50) NULL,
	[LOB] [nchar](10) NULL,
	[MonthID] [char](6) NULL,
	[TestLookupID] [int] NULL,
	[TestStatusID] [int] NULL,
	[StatusIDSaveDate] [datetime] NULL,
	[StatusUpdatedBy] [varchar](50) NULL,
	[MemberFirstName] [varchar](50) NULL,
	[MemberLastName] [varchar](50) NULL,
	[ERVisitCount] [int] NULL,
	[TestList] [varchar](2000) NULL,
	[TestDueList] [varchar](2000) NULL,
 CONSTRAINT [PK_Final_ALLMember_Temp] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_Final_ALLMember_5] ON [dbo].[Final_ALLMember]
(
	[CustID] ASC,
	[TIN] ASC
)
INCLUDE([MemberID],[NPI],[MonthID],[ID],[mvdid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_Final_ALLMember_Temp_1] ON [dbo].[Final_ALLMember]
(
	[mvdid] ASC,
	[MonthID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_Final_ALLMember_Temp_3] ON [dbo].[Final_ALLMember]
(
	[mvdid] ASC,
	[CustID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_Final_ALLMember_Temp_5] ON [dbo].[Final_ALLMember]
(
	[CustID] ASC
)
INCLUDE([MemberID],[TIN],[NPI]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[Final_ALLMember] ADD  CONSTRAINT [DF_Final_ALLMember_Temp_ERVisitCount]  DEFAULT ((0)) FOR [ERVisitCount]