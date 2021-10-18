/****** Object:  Table [dbo].[EMS_LoginRecord]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EMS_LoginRecord](
	[PrimaryKey] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[EMS_ID] [nvarchar](50) NULL,
	[EmployeeID] [nvarchar](50) NULL,
	[LoginIP] [nvarchar](15) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_EMS_LoginRecord] PRIMARY KEY CLUSTERED 
(
	[PrimaryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[EMS_LoginRecord] ADD  CONSTRAINT [DF_EMS_LoginRecord_Created]  DEFAULT (getutcdate()) FOR [Created]