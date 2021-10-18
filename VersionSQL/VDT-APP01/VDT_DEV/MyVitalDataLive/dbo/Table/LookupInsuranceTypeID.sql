/****** Object:  Table [dbo].[LookupInsuranceTypeID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupInsuranceTypeID](
	[InsuranceTypeID] [int] NOT NULL,
	[InsuranceTypeName] [varchar](50) NOT NULL,
	[InsuranceTypeNameSpanish] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_LookupInsuranceTypeID] PRIMARY KEY CLUSTERED 
(
	[InsuranceTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_LookupInsuranceTypeID] ON [dbo].[LookupInsuranceTypeID]
(
	[InsuranceTypeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]