/****** Object:  Table [dbo].[MainPersonalDetails]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainPersonalDetails](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NOT NULL,
	[LastName] [varchar](50) NULL,
	[FirstName] [varchar](50) NULL,
	[GenderID] [int] NULL,
	[SSN] [varchar](9) NULL,
	[DOB] [smalldatetime] NULL,
	[Address1] [varchar](128) NULL,
	[Address2] [varchar](128) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](2) NULL,
	[PostalCode] [varchar](5) NULL,
	[HomePhone] [varchar](10) NULL,
	[CellPhone] [varchar](10) NULL,
	[WorkPhone] [varchar](10) NULL,
	[FaxPhone] [varchar](10) NULL,
	[Email] [varchar](100) NULL,
	[BloodTypeID] [int] NULL,
	[OrganDonor] [varchar](3) NULL,
	[HeightInches] [int] NULL,
	[WeightLbs] [int] NULL,
	[MaritalStatusID] [int] NULL,
	[EconomicStatusID] [int] NULL,
	[Occupation] [varchar](50) NULL,
	[Hours] [varchar](50) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[MaxAttachmentLimit] [int] NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[UpdatedBy] [nvarchar](250) NULL,
	[UpdatedByOrganization] [varchar](250) NULL,
	[UpdatedByContact] [nvarchar](64) NULL,
	[Organization] [nvarchar](256) NULL,
	[Language] [nvarchar](50) NULL,
	[Ethnicity] [nvarchar](50) NULL,
	[CreatedByNPI] [varchar](20) NULL,
	[UpdatedByNPI] [varchar](20) NULL,
	[InCaseManagement] [bit] NULL,
	[NarcoticLockdown] [bit] NULL,
	[MiddleName] [nvarchar](50) NULL,
	[CaseManagementStartDate] [datetime] NULL,
	[Age]  AS (datediff(year,[DOB],getdate())),
	[BMI]  AS (case when [WeightLbs]=(0) OR [HeightInches]=(0) then (0) else CONVERT([decimal](10,2),(703)*(CONVERT([decimal](10,2),[WeightLbs],0)/(CONVERT([decimal](10,2),[HeightInches],0)*CONVERT([decimal](10,2),[HeightInches],0))),0) end),
	[NextBirthDate]  AS (case when CONVERT([date],dateadd(year,datepart(year,getdate())-datepart(year,[DOB]),[DOB]))<getdate() then dateadd(year,(1),CONVERT([date],dateadd(year,datepart(year,getdate())-datepart(year,[DOB]),[DOB]))) else CONVERT([date],dateadd(year,datepart(year,getdate())-datepart(year,[DOB]),[DOB])) end),
 CONSTRAINT [PK_PersonalDetails_NEW] PRIMARY KEY NONCLUSTERED 
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

CREATE UNIQUE CLUSTERED INDEX [IX_MainPersonalDetails_RecordNumber] ON [dbo].[MainPersonalDetails]
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_MainPersonalDetails] ON [dbo].[MainPersonalDetails]
(
	[DOB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainPersonalDetails_1] ON [dbo].[MainPersonalDetails]
(
	[LastName] ASC,
	[FirstName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
ALTER TABLE [dbo].[MainPersonalDetails]  WITH NOCHECK ADD  CONSTRAINT [FK_MainPersonalDetails_NEW_LookupBloodTypeID] FOREIGN KEY([BloodTypeID])
REFERENCES [dbo].[LookupBloodTypeID] ([BloodTypeID])
ON UPDATE CASCADE
ALTER TABLE [dbo].[MainPersonalDetails] CHECK CONSTRAINT [FK_MainPersonalDetails_NEW_LookupBloodTypeID]
ALTER TABLE [dbo].[MainPersonalDetails]  WITH NOCHECK ADD  CONSTRAINT [FK_MainPersonalDetails_NEW_LookupEconomicStatusID] FOREIGN KEY([EconomicStatusID])
REFERENCES [dbo].[LookupEconomicStatusID] ([EconomicStatusID])
ON UPDATE CASCADE
ALTER TABLE [dbo].[MainPersonalDetails] CHECK CONSTRAINT [FK_MainPersonalDetails_NEW_LookupEconomicStatusID]
ALTER TABLE [dbo].[MainPersonalDetails]  WITH NOCHECK ADD  CONSTRAINT [FK_MainPersonalDetails_NEW_LookupMaritalStatusID] FOREIGN KEY([MaritalStatusID])
REFERENCES [dbo].[LookupMaritalStatusID] ([MaritalStatusID])
ON UPDATE CASCADE
ALTER TABLE [dbo].[MainPersonalDetails] CHECK CONSTRAINT [FK_MainPersonalDetails_NEW_LookupMaritalStatusID]