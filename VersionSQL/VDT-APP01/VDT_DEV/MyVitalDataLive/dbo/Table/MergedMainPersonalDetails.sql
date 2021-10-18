/****** Object:  Table [dbo].[MergedMainPersonalDetails]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MergedMainPersonalDetails](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RecordNumber] [int] NULL,
	[ICENUMBER] [varchar](20) NOT NULL,
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
	[Created] [datetime] NOT NULL,
 CONSTRAINT [PK_MergedMainPersonalDetails_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MergedMainPersonalDetails] ADD  CONSTRAINT [DF_MergedMainPersonalDetails_Created]  DEFAULT (getdate()) FOR [Created]