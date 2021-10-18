/****** Object:  Table [dbo].[MDGroup]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MDGroup](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[GroupName] [varchar](50) NULL,
	[Active] [bit] NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[IsNoteAlertGroup] [bit] NULL,
	[CustID_Import] [int] NULL,
	[Active_Members] [int] NULL,
	[SecondaryName] [varchar](100) NULL,
	[TIN] [varchar](50) NULL,
 CONSTRAINT [PK_MDGroup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_MDGroup] ON [dbo].[MDGroup]
(
	[CustID_Import] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MDGroup_GroupName_CustID_Import] ON [dbo].[MDGroup]
(
	[GroupName] ASC,
	[CustID_Import] ASC
)
INCLUDE([SecondaryName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MDGroup] ADD  CONSTRAINT [DF_MDGroup_Active]  DEFAULT ((0)) FOR [Active]
ALTER TABLE [dbo].[MDGroup] ADD  CONSTRAINT [DF_MDGroup_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[MDGroup] ADD  CONSTRAINT [DF_MDGroup_ModifyDate]  DEFAULT (getutcdate()) FOR [ModifyDate]
ALTER TABLE [dbo].[MDGroup] ADD  DEFAULT ((0)) FOR [IsNoteAlertGroup]
ALTER TABLE [dbo].[MDGroup] ADD  CONSTRAINT [DF_MDGroup_CustID_Import]  DEFAULT ((0)) FOR [CustID_Import]