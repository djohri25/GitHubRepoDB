/****** Object:  Table [dbo].[LookupNDCOther]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupNDCOther](
	[LabelerName] [varchar](40) NULL,
	[LabelerCode] [varchar](5) NOT NULL,
	[ProductCode] [varchar](4) NOT NULL,
	[PackageSizeCode] [varchar](2) NOT NULL,
	[DrugCategory] [varchar](1) NULL,
	[DESIIndicator] [varchar](1) NULL,
	[DrugTypeIndicator] [varchar](1) NULL,
	[TerminationDate] [varchar](8) NULL,
	[UnitType] [varchar](3) NULL,
	[UnitsPerPkgSize] [varchar](10) NULL,
	[FDAApprovalDate] [varchar](8) NULL,
	[DateEnteredMarket] [varchar](8) NULL,
	[TherEquivCode] [varchar](2) NULL,
	[Filler] [varchar](1) NULL,
	[ProductName] [varchar](63) NULL,
	[NameFiller] [varchar](4) NULL,
 CONSTRAINT [PK_LookupNDCOther] PRIMARY KEY NONCLUSTERED 
(
	[LabelerCode] ASC,
	[ProductCode] ASC,
	[PackageSizeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE CLUSTERED INDEX [IX_LookupNDCOther] ON [dbo].[LookupNDCOther]
(
	[ProductCode] ASC,
	[LabelerCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]