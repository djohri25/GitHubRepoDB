/****** Object:  Table [dbo].[MainInsurance]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainInsurance](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NOT NULL,
	[Name] [varchar](50) NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](2) NULL,
	[Postal] [varchar](5) NULL,
	[Phone] [varchar](50) NULL,
	[FaxPhone] [varchar](10) NULL,
	[PolicyHolderName] [varchar](50) NULL,
	[GroupNumber] [varchar](50) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[WebSite] [varchar](200) NULL,
	[InsuranceTypeID] [int] NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[Medicaid] [varchar](50) NULL,
	[MedicareNumber] [varchar](50) NULL,
	[HVID] [char](36) NULL,
	[HVFlag] [tinyint] NOT NULL,
	[ReadOnly] [bit] NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[UpdatedBy] [nvarchar](250) NULL,
	[UpdatedByOrganization] [varchar](250) NULL,
	[UpdatedByContact] [nvarchar](64) NULL,
	[CreatedByNPI] [varchar](20) NULL,
	[UpdatedByNPI] [varchar](20) NULL,
	[EffectiveDate] [smalldatetime] NULL,
	[TerminationDate] [smalldatetime] NULL,
	[CHIP_ID] [varchar](30) NULL,
	[ProductType] [varchar](50) NULL,
 CONSTRAINT [PK_MainInsurance] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainInsurance] ON [dbo].[MainInsurance]
(
	[ICENUMBER] ASC,
	[Name] ASC
)
INCLUDE([Medicaid],[MedicareNumber],[EffectiveDate],[TerminationDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_MainInsurance_Expire] ON [dbo].[MainInsurance]
(
	[TerminationDate] DESC,
	[EffectiveDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainInsurance_Medicaid] ON [dbo].[MainInsurance]
(
	[Medicaid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MainInsurance] ADD  CONSTRAINT [DF_MainInsurance_HVFlag]  DEFAULT ((0)) FOR [HVFlag]
ALTER TABLE [dbo].[MainInsurance] ADD  CONSTRAINT [DF_MainInsurance_ReadOnly]  DEFAULT ((0)) FOR [ReadOnly]
ALTER TABLE [dbo].[MainInsurance]  WITH CHECK ADD  CONSTRAINT [FK_MainInsurance_LookupInsuranceTypeID] FOREIGN KEY([InsuranceTypeID])
REFERENCES [dbo].[LookupInsuranceTypeID] ([InsuranceTypeID])
ON UPDATE CASCADE
ALTER TABLE [dbo].[MainInsurance] CHECK CONSTRAINT [FK_MainInsurance_LookupInsuranceTypeID]