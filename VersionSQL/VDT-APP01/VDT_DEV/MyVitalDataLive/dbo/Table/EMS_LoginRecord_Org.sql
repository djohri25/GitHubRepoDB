/****** Object:  Table [dbo].[EMS_LoginRecord_Org]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EMS_LoginRecord_Org](
	[PrimaryKey] [int] NOT NULL,
	[EMS_ID] [nvarchar](50) NULL,
	[EmployeeID] [nvarchar](50) NULL,
	[LoginIP] [nvarchar](15) NULL,
	[Created] [datetime] NULL
) ON [PRIMARY]