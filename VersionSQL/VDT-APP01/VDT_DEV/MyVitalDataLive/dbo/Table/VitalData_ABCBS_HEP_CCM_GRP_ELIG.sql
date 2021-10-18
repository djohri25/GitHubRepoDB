/****** Object:  Table [dbo].[VitalData_ABCBS_HEP_CCM_GRP_ELIG]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[VitalData_ABCBS_HEP_CCM_GRP_ELIG](
	[MEMBER_ID] [nvarchar](20) NULL,
	[LINE_OF_BUSINESS] [nvarchar](5) NULL,
	[HEP_GRP_ELIG_IND] [nvarchar](1) NULL,
	[HEP_CASEFIND_IND] [nvarchar](1) NULL,
	[CCM_GRP_ELIG_IND] [nvarchar](1) NULL,
	[DENTAL_XTRA_IND] [nvarchar](1) NULL,
	[LOAD_DT] [nvarchar](50) NULL,
	[ETL_LOAD_DATE] [datetime] NULL
) ON [PRIMARY]