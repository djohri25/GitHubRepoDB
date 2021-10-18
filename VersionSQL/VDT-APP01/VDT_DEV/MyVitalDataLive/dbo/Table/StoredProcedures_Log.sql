/****** Object:  Table [dbo].[StoredProcedures_Log]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[StoredProcedures_Log](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SPName] [nvarchar](100) NULL,
	[UserID] [nvarchar](50) NULL,
	[UserID_SSO] [nvarchar](50) NULL,
	[CallDate] [datetime] NULL,
	[Parameters] [nvarchar](1000) NULL,
 CONSTRAINT [PK_StoredProcedures_Log] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[StoredProcedures_Log] ADD  CONSTRAINT [DF_StoredProcedures_Log_CallDate]  DEFAULT (getutcdate()) FOR [CallDate]