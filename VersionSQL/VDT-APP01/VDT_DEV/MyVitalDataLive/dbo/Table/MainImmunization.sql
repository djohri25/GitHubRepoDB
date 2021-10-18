/****** Object:  Table [dbo].[MainImmunization]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainImmunization](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
	[ImmunId] [int] NULL,
	[ImmunizationName] [nvarchar](127) NULL,
	[DateDone] [datetime] NULL,
	[DateDue] [datetime] NULL,
	[DateApproximate] [bit] NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[HVID] [char](36) NULL,
	[HVFlag] [tinyint] NOT NULL,
	[ReadOnly] [bit] NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[UpdatedBy] [nvarchar](250) NULL,
	[UpdatedByOrganization] [varchar](250) NULL,
	[UpdatedByContact] [nvarchar](64) NULL,
	[Organization] [nvarchar](256) NULL,
	[ImmunizationCode] [varchar](20) NULL,
	[ClaimID] [int] NULL,
 CONSTRAINT [PK_MainImmunization] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainImmunization] ON [dbo].[MainImmunization]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainImmunization_1] ON [dbo].[MainImmunization]
(
	[ImmunizationCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MainImmunization] ADD  CONSTRAINT [DF_MainImmunization_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[MainImmunization] ADD  CONSTRAINT [DF_MainImmunization_ModifyDate]  DEFAULT (getutcdate()) FOR [ModifyDate]
ALTER TABLE [dbo].[MainImmunization] ADD  CONSTRAINT [DF_MainImmunization_HVFlag]  DEFAULT ((0)) FOR [HVFlag]
ALTER TABLE [dbo].[MainImmunization] ADD  CONSTRAINT [DF_MainImmunization_ReadOnly]  DEFAULT ((0)) FOR [ReadOnly]
ALTER TABLE [dbo].[MainImmunization]  WITH CHECK ADD  CONSTRAINT [FK_MainImmunization_LookupImmunization] FOREIGN KEY([ImmunId])
REFERENCES [dbo].[LookupImmunization] ([ImmunId])
ALTER TABLE [dbo].[MainImmunization] CHECK CONSTRAINT [FK_MainImmunization_LookupImmunization]
ALTER TABLE [dbo].[MainImmunization]  WITH CHECK ADD  CONSTRAINT [FK_MainImmunization_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON DELETE CASCADE
ALTER TABLE [dbo].[MainImmunization] CHECK CONSTRAINT [FK_MainImmunization_MainPersonalDetails]