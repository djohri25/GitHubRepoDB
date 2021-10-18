/****** Object:  Table [dbo].[MainMemberMed]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainMemberMed](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustID] [int] NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[NDC] [varchar](20) NOT NULL,
	[RxStartDate] [datetime] NOT NULL,
	[RxDrug] [varchar](100) NULL,
	[PrescribedBy] [varchar](250) NULL,
	[RxPharmacy] [varchar](100) NULL,
	[HowMuch] [varchar](50) NULL,
	[HowOften] [varchar](50) NULL,
	[WhyTaking] [varchar](50) NULL,
	[CreatedBy] [varchar](250) NULL,
	[CreatedDate] [datetime] NULL,
	[SessionID] [varchar](40) NULL,
	[Route] [varchar](50) NULL,
	[DaysSupply] [varchar](50) NULL,
	[DrugStrength] [varchar](12) NULL,
 CONSTRAINT [PK_MainMemberMed] PRIMARY KEY CLUSTERED 
(
	[CustID] ASC,
	[MVDID] ASC,
	[NDC] ASC,
	[RxStartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_MainMemberMed_CreatedDate] ON [dbo].[MainMemberMed]
(
	[CreatedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]