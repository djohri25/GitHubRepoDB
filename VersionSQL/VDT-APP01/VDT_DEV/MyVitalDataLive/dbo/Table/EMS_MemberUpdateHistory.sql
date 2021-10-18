/****** Object:  Table [dbo].[EMS_MemberUpdateHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EMS_MemberUpdateHistory](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[EmployeeID] [varchar](50) NULL,
	[MvdID] [varchar](20) NULL,
	[SectionID] [varchar](50) NULL,
	[Action] [varchar](50) NULL,
	[Created] [datetime] NULL,
	[HistoryRecordID] [int] NULL,
	[MainRecordID] [int] NULL,
 CONSTRAINT [PK_EMS_MemberUpdateHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[EMS_MemberUpdateHistory] ADD  CONSTRAINT [DF_EMS_MemberUpdateHistory_Created]  DEFAULT (getutcdate()) FOR [Created]