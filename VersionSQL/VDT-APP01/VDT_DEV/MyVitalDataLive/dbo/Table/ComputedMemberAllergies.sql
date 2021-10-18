/****** Object:  Table [dbo].[ComputedMemberAllergies]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ComputedMemberAllergies](
	[RecordNumber] [int] NOT NULL,
	[ICENUMBER] [varchar](30) NOT NULL,
	[AllergenTypeId] [int] NULL,
	[AllergenName] [varchar](25) NULL,
	[Reaction] [varchar](150) NULL,
	[HVID] [char](36) NULL,
	[HVFlag] [tinyint] NOT NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[ReadOnly] [bit] NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[UpdatedBy] [nvarchar](250) NULL,
	[UpdatedByOrganization] [varchar](250) NULL,
	[UpdatedByContact] [nvarchar](64) NULL,
	[Organization] [nvarchar](256) NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IC_ComputedMemberAllergies_ICENUMBER] ON [dbo].[ComputedMemberAllergies]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]