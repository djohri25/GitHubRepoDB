/****** Object:  Table [dbo].[ComputedMemberMaternity_bak]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ComputedMemberMaternity_bak](
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