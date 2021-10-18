/****** Object:  Table [dbo].[CMCD_DISCHARGE_DATA_From_SSIS]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CMCD_DISCHARGE_DATA_From_SSIS](
	[GUID] [varchar](50) NULL,
	[MRN] [varchar](50) NULL,
	[CSN] [varchar](50) NULL,
	[PATIENT_NAME] [varchar](50) NULL,
	[DOB] [date] NULL,
	[ADMIT_DATE] [datetime] NULL,
	[CLASS] [varchar](50) NULL,
	[MEDICAIDE_NUMBER] [varchar](50) NULL,
	[VISIT_REASON] [varchar](100) NULL,
	[PCP] [varchar](50) NULL,
	[DISCHARGE_DISPOSITION] [varchar](100) NULL,
	[PATIENTS_HOME_NUMBER] [varchar](50) NULL,
	[Type] [varchar](50) NULL
) ON [PRIMARY]