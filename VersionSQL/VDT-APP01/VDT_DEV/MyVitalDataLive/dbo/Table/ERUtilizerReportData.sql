/****** Object:  Table [dbo].[ERUtilizerReportData]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ERUtilizerReportData](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](200) NULL,
	[DOB] [date] NULL,
	[MVDID] [varchar](20) NULL,
	[CustID] [int] NULL,
	[InsMemberID] [varchar](50) NULL,
	[VisitDate] [date] NULL,
	[Facility] [varchar](100) NULL,
	[ChiefComplaint] [varchar](1000) NULL,
	[PCP_NPI] [varchar](50) NULL,
	[NPIName] [varchar](200) NULL,
	[ERVisitCount] [int] NULL,
	[LastERVisitID] [int] NULL,
	[LastERVisitFacilityNPI] [varchar](50) NULL,
	[PrimaryDiagnosis] [varchar](50) NULL,
	[SecondaryDiagnosis] [varchar](50) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_ERUtilizerReportData] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ERUtilizerReportData] ON [dbo].[ERUtilizerReportData]
(
	[MVDID] ASC,
	[LastERVisitFacilityNPI] ASC,
	[VisitDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ERUtilizerReportData_1] ON [dbo].[ERUtilizerReportData]
(
	[CustID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ERUtilizerReportData] ADD  CONSTRAINT [DF__ERUtilize__Creat__21ECA635]  DEFAULT (getdate()) FOR [Created]