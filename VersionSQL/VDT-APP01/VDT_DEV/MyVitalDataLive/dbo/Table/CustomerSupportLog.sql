/****** Object:  Table [dbo].[CustomerSupportLog]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CustomerSupportLog](
	[RecordID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Agent_FirstName] [varchar](15) NULL,
	[Agent_LastName] [varchar](15) NULL,
	[CallDate] [smalldatetime] NULL,
	[CallTime] [varchar](15) NULL,
	[Category] [varchar](50) NULL,
	[Reporter_FirstName] [varchar](15) NULL,
	[Reporter_LastName] [varchar](15) NULL,
	[MVDId] [varchar](20) NULL,
	[Status] [varchar](15) NULL,
	[Comments] [nvarchar](250) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_Admin_Support_Log] PRIMARY KEY CLUSTERED 
(
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[CustomerSupportLog] ADD  CONSTRAINT [DF_Admin_Support_Log_Created]  DEFAULT (getutcdate()) FOR [Created]