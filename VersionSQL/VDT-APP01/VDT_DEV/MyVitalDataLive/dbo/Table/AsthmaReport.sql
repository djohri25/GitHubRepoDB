/****** Object:  Table [dbo].[AsthmaReport]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AsthmaReport](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InsMemberId] [varchar](50) NULL,
	[Facility] [varchar](50) NULL,
	[VisitDate] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[FirstName] [varchar](50) NULL,
	[HomePhone] [varchar](50) NULL,
	[DOB] [varchar](50) NULL,
	[StartDate] [varchar](50) NULL,
	[RefillDate] [varchar](50) NULL,
	[PrescribedBy] [varchar](100) NULL,
	[RxDrug] [varchar](200) NULL,
	[RxPharmacy] [varchar](100) NULL,
	[PCPName] [varchar](100) NULL,
	[customerName] [varchar](100) NULL,
	[DateRange] [int] NULL,
	[PCP_NPI] [varchar](50) NULL,
	[ERVisitCount] [int] NULL,
	[CustID] [int] NULL,
 CONSTRAINT [PK_AsthmaReport] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]