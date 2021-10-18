/****** Object:  Table [dbo].[MemberReferral]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MemberReferral](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[DocID] [bigint] NULL,
	[ParentDocID] [bigint] NULL,
	[MemberID] [varchar](30) NULL,
	[TaskID] [bigint] NULL,
	[TaskSource] [nvarchar](100) NULL,
	[CaseProgram] [varchar](100) NULL,
	[ParentReferralID] [bigint] NULL,
	[NonViableReason] [nvarchar](100) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CheckAssignment] [bit] NULL,
	[Cust_ID] [int] NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[MemberReferral] ADD  DEFAULT (getutcdate()) FOR [CreatedDate]