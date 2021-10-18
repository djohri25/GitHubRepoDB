/****** Object:  Table [dbo].[MainCarePlanMemberIndex]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainCarePlanMemberIndex](
	[CarePlanID] [int] IDENTITY(1,1) NOT NULL,
	[Cust_ID] [nvarchar](50) NOT NULL,
	[MVDID] [nvarchar](50) NOT NULL,
	[cpLibraryID] [int] NOT NULL,
	[CarePlanDate] [datetime] NOT NULL,
	[Author] [nvarchar](50) NULL,
	[Language] [nvarchar](20) NULL,
	[CaseID] [varchar](100) NULL,
	[cpInactiveDate] [datetime] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
	[CarePlanType] [nvarchar](50) NULL,
	[CarePlanStatus] [int] NULL,
	[Activated] [bit] NOT NULL,
	[ActivatedDate] [datetime] NULL,
	[ActivatedBy] [nvarchar](100) NULL,
 CONSTRAINT [PK_MainCarePlanMemberIndex] PRIMARY KEY CLUSTERED 
(
	[CarePlanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_MainCarePlanMemberIndex_UpdatedDate] ON [dbo].[MainCarePlanMemberIndex]
(
	[UpdatedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MainCarePlanMemberIndex] ADD  CONSTRAINT [DF__MainCareP__CareP__5250B1C5]  DEFAULT (N'CASE MANAGEMENT') FOR [CarePlanType]
ALTER TABLE [dbo].[MainCarePlanMemberIndex] ADD  CONSTRAINT [DF__MainCareP__CareP__5344D5FE]  DEFAULT ((0)) FOR [CarePlanStatus]
ALTER TABLE [dbo].[MainCarePlanMemberIndex] ADD  CONSTRAINT [DF_MainCarePlanMemberIndex_Activated]  DEFAULT ((0)) FOR [Activated]