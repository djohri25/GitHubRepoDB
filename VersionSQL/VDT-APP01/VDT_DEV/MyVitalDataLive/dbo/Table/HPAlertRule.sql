/****** Object:  Table [dbo].[HPAlertRule]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPAlertRule](
	[Rule_ID] [smallint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Cust_ID] [int] NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](500) NULL,
	[Active] [bit] NULL,
	[AnyFacility] [bit] NULL,
	[AnyDisease] [bit] NULL,
	[AnyEmployer] [bit] NULL,
	[AnyHealthPlan] [bit] NULL,
	[AnyHealthPlanType] [bit] NULL,
	[AnyCounty] [bit] NULL,
	[Created] [datetime] NULL,
	[InNarcoticLockdown] [int] NULL,
	[AnyChiefComplaint] [bit] NULL,
	[AnyDiseaseManagement] [bit] NULL,
	[InCaseManagement] [int] NULL,
	[AnyDiagnosis] [bit] NULL,
	[AllOtherDiagnosis] [bit] NULL,
	[AnyCOPC] [bit] NULL,
	[IsNoteAlertRule] [bit] NULL,
 CONSTRAINT [PK_HPAlertRule] PRIMARY KEY CLUSTERED 
(
	[Rule_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_HPAlertRule_Cust_ID] ON [dbo].[HPAlertRule]
(
	[Cust_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[HPAlertRule] ADD  CONSTRAINT [DF_HPAlertRule_Active]  DEFAULT ((0)) FOR [Active]
ALTER TABLE [dbo].[HPAlertRule] ADD  CONSTRAINT [DF_HPAlertRule_AnyFacility]  DEFAULT ((0)) FOR [AnyFacility]
ALTER TABLE [dbo].[HPAlertRule] ADD  CONSTRAINT [DF_HPAlertRule_AnyDisease]  DEFAULT ((0)) FOR [AnyDisease]
ALTER TABLE [dbo].[HPAlertRule] ADD  CONSTRAINT [DF_HPAlertRule_AnyEmployer]  DEFAULT ((0)) FOR [AnyEmployer]
ALTER TABLE [dbo].[HPAlertRule] ADD  CONSTRAINT [DF_HPAlertRule_AnyHealthPlan]  DEFAULT ((0)) FOR [AnyHealthPlan]
ALTER TABLE [dbo].[HPAlertRule] ADD  CONSTRAINT [DF_HPAlertRule_AnyHealthPlanType]  DEFAULT ((0)) FOR [AnyHealthPlanType]
ALTER TABLE [dbo].[HPAlertRule] ADD  CONSTRAINT [DF_HPAlertRule_AnyCounty]  DEFAULT ((0)) FOR [AnyCounty]
ALTER TABLE [dbo].[HPAlertRule] ADD  CONSTRAINT [DF_HPAlertRule_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[HPAlertRule] ADD  CONSTRAINT [DF_HPAlertRule_AnyChiefComplaint]  DEFAULT ((0)) FOR [AnyChiefComplaint]
ALTER TABLE [dbo].[HPAlertRule] ADD  CONSTRAINT [DF_HPAlertRule_AnyDiseaseManagement]  DEFAULT ((0)) FOR [AnyDiseaseManagement]
ALTER TABLE [dbo].[HPAlertRule] ADD  CONSTRAINT [DF_HPAlertRule_AnyDiagnosis]  DEFAULT ((0)) FOR [AnyDiagnosis]
ALTER TABLE [dbo].[HPAlertRule] ADD  CONSTRAINT [DF_HPAlertRule_AllOtherDiagnosis]  DEFAULT ((0)) FOR [AllOtherDiagnosis]
ALTER TABLE [dbo].[HPAlertRule] ADD  CONSTRAINT [DF_HPAlertRule_AnyCOPC]  DEFAULT ((1)) FOR [AnyCOPC]
ALTER TABLE [dbo].[HPAlertRule] ADD  DEFAULT ((0)) FOR [IsNoteAlertRule]
ALTER TABLE [dbo].[HPAlertRule]  WITH CHECK ADD  CONSTRAINT [FK_HPAlertRule_HPCustomer] FOREIGN KEY([Cust_ID])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[HPAlertRule] CHECK CONSTRAINT [FK_HPAlertRule_HPCustomer]