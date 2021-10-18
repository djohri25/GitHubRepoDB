/****** Object:  Table [dbo].[ParklandPCCICOPCRisk]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ParklandPCCICOPCRisk](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustID] [int] NOT NULL,
	[ReferenceID] [int] NULL,
	[MVDID] [varchar](15) NOT NULL,
	[MemberID] [varchar](9) NOT NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[Gender] [char](1) NULL,
	[dob] [date] NULL,
	[age] [tinyint] NULL,
	[Phone] [varchar](10) NULL,
	[ZipCode] [varchar](5) NULL,
	[AMR] [varchar](10) NULL,
	[AMR_cat] [varchar](10) NULL,
	[inpt_or_ed_as_u12] [tinyint] NULL,
	[PCPID] [varchar](15) NULL,
	[Pcp_Fullname] [varchar](100) NULL,
	[Pcp_Affil_Fullname] [varchar](100) NULL,
	[RiskScores] [varchar](10) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ParklandPCCICOPCRisk_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [IX_ParklandPCCICOPCRisk_CustID_MVDID_MemberID] ON [dbo].[ParklandPCCICOPCRisk]
(
	[CustID] ASC,
	[MVDID] ASC,
	[MemberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ParklandPCCICOPCRisk] ADD  CONSTRAINT [DF_ParklandPCCICOPCRisk_CustID]  DEFAULT ((10)) FOR [CustID]
ALTER TABLE [dbo].[ParklandPCCICOPCRisk] ADD  CONSTRAINT [DF_ParklandPCCICOPCRisk_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
ALTER TABLE [dbo].[ParklandPCCICOPCRisk] ADD  CONSTRAINT [DF_ParklandPCCICOPCRisk_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]