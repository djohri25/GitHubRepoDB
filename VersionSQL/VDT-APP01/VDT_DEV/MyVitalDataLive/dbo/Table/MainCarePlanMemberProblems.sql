/****** Object:  Table [dbo].[MainCarePlanMemberProblems]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainCarePlanMemberProblems](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CarePlanID] [bigint] NOT NULL,
	[seq] [int] NOT NULL,
	[idDate] [datetime] NULL,
	[priority] [smallint] NULL,
	[problemNum] [int] NULL,
	[problemFreeText] [varchar](max) NULL,
	[status] [int] NULL,
	[cpInactiveDate] [datetime] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
	[Optionality] [int] NOT NULL,
	[Comments] [nvarchar](max) NULL,
	[Closed] [bit] NULL,
 CONSTRAINT [PK_MainCarePlanMemberProblems] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_MainCarePlanMemberProblems_UpdatedDate] ON [dbo].[MainCarePlanMemberProblems]
(
	[UpdatedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MainCarePlanMemberProblems] ADD  CONSTRAINT [DF__MainCareP__Optio__3218EC5D]  DEFAULT ((0)) FOR [Optionality]