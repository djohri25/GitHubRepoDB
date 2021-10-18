/****** Object:  Table [dbo].[HCC_Member_Mapping]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HCC_Member_Mapping](
	[COMM_PAT_ID] [varchar](50) NULL,
	[MBR_YEAR] [varchar](4) NULL,
	[ADJ_RiskScore] [decimal](10, 2) NULL,
	[NONADJ_RiskScore] [decimal](10, 2) NULL,
	[CCCode] [varchar](500) NULL,
	[Created] [datetime] NULL,
	[Updated] [datetime] NULL,
	[MVDID] [varchar](30) NULL
) ON [PRIMARY]