/****** Object:  Table [dbo].[HPCustomer]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPCustomer](
	[Cust_ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Name] [varchar](50) NULL,
	[Type] [int] NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[State] [char](2) NULL,
	[PostalCode] [varchar](10) NULL,
	[Phone] [varchar](50) NULL,
	[PrimaryAgent] [int] NULL,
	[Active] [bit] NULL,
	[ProvidesDMPrograms] [bit] NULL,
	[ProvidesNarcoticLockdown] [bit] NULL,
	[ProvidesInCaseManagement] [bit] NULL,
	[ParentID] [int] NULL,
	[PCPNotSetNote] [varchar](1000) NULL,
	[HealthcareProgramsSectionDesc] [varchar](300) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[ShowPatientRefSheet] [bit] NULL,
	[AliasCustID] [varchar](50) NULL,
	[DBName] [varchar](50) NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[Cust_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [IX_HPCustomerName] ON [dbo].[HPCustomer]
(
	[Name] ASC
)
INCLUDE([Address1],[Address2],[City],[State],[PostalCode],[Phone]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[HPCustomer] ADD  CONSTRAINT [DF_HPCustomer_Active]  DEFAULT ((0)) FOR [Active]
ALTER TABLE [dbo].[HPCustomer] ADD  CONSTRAINT [DF_HPCustomer_ProvidesDMPrograms]  DEFAULT ((1)) FOR [ProvidesDMPrograms]
ALTER TABLE [dbo].[HPCustomer] ADD  CONSTRAINT [DF_HPCustomer_ProvidesNarcoticLockdown]  DEFAULT ((1)) FOR [ProvidesNarcoticLockdown]
ALTER TABLE [dbo].[HPCustomer] ADD  CONSTRAINT [DF_HPCustomer_ProvidesInCaseManagement]  DEFAULT ((1)) FOR [ProvidesInCaseManagement]
ALTER TABLE [dbo].[HPCustomer] ADD  CONSTRAINT [DF_HPCustomer_ShowPatientRefSheet]  DEFAULT ((0)) FOR [ShowPatientRefSheet]