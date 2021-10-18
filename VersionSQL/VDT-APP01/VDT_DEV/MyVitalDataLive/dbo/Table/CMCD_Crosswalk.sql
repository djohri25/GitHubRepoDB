/****** Object:  Table [dbo].[CMCD_Crosswalk]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CMCD_Crosswalk](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Medicaid1] [varchar](50) NULL,
	[Medicaid2] [varchar](50) NULL,
	[EffectiveDate1] [datetime] NULL,
	[TerminationDate1] [datetime] NULL,
	[EffectiveDate2] [datetime] NULL,
	[TerminationDate2] [datetime] NULL,
 CONSTRAINT [PK_CMCD_Crosswalk] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]