/****** Object:  Table [dbo].[Diag_Cost]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Diag_Cost](
	[ParentDiagCode] [varchar](50) NULL,
	[ICDVersion] [varchar](10) NULL,
	[DiagnosisDesc] [varchar](200) NULL,
	[ChildDiagCodes] [varchar](max) NULL,
	[Outpatient$] [decimal](38, 2) NULL,
	[InPatient$] [decimal](38, 2) NULL,
	[Emergency$] [decimal](38, 2) NULL,
	[RX$] [decimal](38, 2) NULL,
	[LAB$] [decimal](38, 2) NULL,
	[Other$] [decimal](38, 2) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]