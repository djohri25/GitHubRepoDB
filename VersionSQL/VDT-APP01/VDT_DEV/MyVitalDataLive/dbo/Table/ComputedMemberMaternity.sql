/****** Object:  Table [dbo].[ComputedMemberMaternity]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ComputedMemberMaternity](
	[MVDID] [nvarchar](30) NOT NULL,
	[IsPregnant] [bit] NULL,
	[PregnantCode] [nchar](10) NULL,
	[PregnantDate] [date] NULL,
	[IsMiscarriage] [bit] NULL,
	[MiscarriageCode] [nchar](10) NULL,
	[MiscarriageDate] [date] NULL,
	[IsDelivered] [bit] NULL,
	[DeliveryCode] [nchar](10) NULL,
	[DeliveryDate] [date] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IsLateTerm] [bit] NULL,
	[Hypertension] [bit] NULL,
	[Diabetes] [bit] NULL,
	[SUD] [bit] NULL,
	[Depression] [bit] NULL,
	[DomesticAbuse] [bit] NULL,
	[MaternityRiskScore] [smallint] NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ComputedMemberMaternity_MVDID] ON [dbo].[ComputedMemberMaternity]
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ComputedMemberMaternity] ADD  CONSTRAINT [DF_ComputedMemberMaternity_IsLateTerm]  DEFAULT ((0)) FOR [IsLateTerm]
ALTER TABLE [dbo].[ComputedMemberMaternity] ADD  CONSTRAINT [DF_ComputedMemberMaternity_Hypertension]  DEFAULT ((0)) FOR [Hypertension]
ALTER TABLE [dbo].[ComputedMemberMaternity] ADD  CONSTRAINT [DF_ComputedMemberMaternity_Diabetes]  DEFAULT ((0)) FOR [Diabetes]
ALTER TABLE [dbo].[ComputedMemberMaternity] ADD  CONSTRAINT [DF_ComputedMemberMaternity_SUD]  DEFAULT ((0)) FOR [SUD]
ALTER TABLE [dbo].[ComputedMemberMaternity] ADD  CONSTRAINT [DF_ComputedMemberMaternity_Depression]  DEFAULT ((0)) FOR [Depression]
ALTER TABLE [dbo].[ComputedMemberMaternity] ADD  CONSTRAINT [DF_ComputedMemberMaternity_DomesticAbuse]  DEFAULT ((0)) FOR [DomesticAbuse]
ALTER TABLE [dbo].[ComputedMemberMaternity] ADD  CONSTRAINT [DF_ComputedMemberMaternity_MaternityRiskScore]  DEFAULT ((0)) FOR [MaternityRiskScore]