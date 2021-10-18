/****** Object:  Table [dbo].[MainInsurance_History]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainInsurance_History](
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
	[HistoryCreationDate] [datetime] NULL,
	[ProductType] [varchar](50) NULL,
 CONSTRAINT [PK_MainInsurance_History] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainInsurance_History_icenumber] ON [dbo].[MainInsurance_History]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
ALTER TABLE [dbo].[MainInsurance_History] ADD  CONSTRAINT [DF_MainInsurance_History_HVFlag]  DEFAULT ((0)) FOR [HVFlag]
ALTER TABLE [dbo].[MainInsurance_History] ADD  CONSTRAINT [DF_MainInsurance_History_ReadOnly]  DEFAULT ((0)) FOR [ReadOnly]
ALTER TABLE [dbo].[MainInsurance_History] ADD  DEFAULT (getutcdate()) FOR [HistoryCreationDate]