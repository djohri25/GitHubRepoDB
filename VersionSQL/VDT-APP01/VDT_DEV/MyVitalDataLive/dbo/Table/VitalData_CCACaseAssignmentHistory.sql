/****** Object:  Table [dbo].[VitalData_CCACaseAssignmentHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[VitalData_CCACaseAssignmentHistory](
	[CCA_CaseId] [varchar](50) NULL,
	[CCA_CMCaseId] [varchar](50) NULL,
	[CCA_cid] [varchar](50) NULL,
	[externalId] [varchar](50) NULL,
	[MemberId] [varchar](50) NULL,
	[ContractID] [varchar](50) NULL,
	[CCA_UserId] [varchar](50) NULL,
	[NetworkID] [varchar](50) NULL,
	[CaseCreateDate] [varchar](50) NULL,
	[CaseCloseDate] [varchar](50) NULL,
	[CaseProgram] [varchar](50) NULL,
	[SOURCE_CODE] [varchar](50) NULL
) ON [PRIMARY]