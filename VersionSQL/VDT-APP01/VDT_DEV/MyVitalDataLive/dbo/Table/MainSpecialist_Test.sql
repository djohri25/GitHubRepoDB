/****** Object:  Table [dbo].[MainSpecialist_Test]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainSpecialist_Test](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](20) NOT NULL,
	[LastName] [varchar](50) NULL,
	[FirstName] [varchar](50) NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](2) NULL,
	[Postal] [varchar](5) NULL,
	[Specialty] [varchar](50) NULL,
	[Phone] [varchar](10) NULL,
	[PhoneCell] [varchar](10) NULL,
	[FaxPhone] [varchar](10) NULL,
	[NurseName] [varchar](50) NULL,
	[NursePhone] [varchar](10) NULL,
	[RoleID] [int] NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[NPI] [varchar](100) NULL,
	[TIN] [varchar](100) NULL,
 CONSTRAINT [PK_MainContacts_Test] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]