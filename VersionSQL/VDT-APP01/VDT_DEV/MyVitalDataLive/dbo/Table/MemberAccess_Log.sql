/****** Object:  Table [dbo].[MemberAccess_Log]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MemberAccess_Log](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [nvarchar](50) NULL,
	[LoggingDate] [datetime] NULL,
	[PatientID] [nvarchar](50) NULL,
	[PageName] [nvarchar](150) NULL,
	[Cust_ID] [varchar](50) NULL,
	[Result] [nvarchar](150) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]