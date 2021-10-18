/****** Object:  Table [dbo].[MDUser]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MDUser](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Username] [varchar](50) NULL,
	[Email] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
	[Active] [bit] NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[LastLogin] [datetime] NULL,
	[LastLoginIP] [varchar](50) NULL,
	[SecurityQ1] [int] NULL,
	[SecurityA1] [varchar](50) NULL,
	[SecurityQ2] [int] NULL,
	[SecurityA2] [varchar](50) NULL,
	[SecurityQ3] [int] NULL,
	[SecurityA3] [varchar](50) NULL,
	[Company] [varchar](50) NULL,
	[AccountName] [varchar](50) NULL,
	[ForcePasswordReset] [bit] NULL,
	[Organization] [varchar](50) NULL,
	[Phone] [varchar](50) NULL,
 CONSTRAINT [PK_MDUser] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MDUser] ON [dbo].[MDUser]
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MDUser] ADD  CONSTRAINT [DF_MDUser_Active]  DEFAULT ((0)) FOR [Active]
ALTER TABLE [dbo].[MDUser] ADD  CONSTRAINT [DF_MDUser_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[MDUser] ADD  CONSTRAINT [DF_MDUser_ModifyDate]  DEFAULT (getutcdate()) FOR [ModifyDate]
ALTER TABLE [dbo].[MDUser] ADD  CONSTRAINT [DF_MDUser_ForcePasswordReset]  DEFAULT ((1)) FOR [ForcePasswordReset]