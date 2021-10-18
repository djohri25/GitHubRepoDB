/****** Object:  Table [dbo].[MVD_AppRecord]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MVD_AppRecord](
	[RecordID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AppId] [nvarchar](50) NULL,
	[LocationID] [nvarchar](50) NULL,
	[UserName] [nvarchar](50) NULL,
	[AccessReason] [nvarchar](2000) NULL,
	[Action] [nvarchar](50) NULL,
	[MVDID] [varchar](15) NULL,
	[Criteria] [nvarchar](1000) NULL,
	[ResultStatus] [nvarchar](50) NULL,
	[ResultCount] [int] NULL,
	[Created] [datetime] NULL,
	[AlertSendDate] [datetime] NULL,
	[ChiefComplaint] [nvarchar](100) NULL,
	[EMSNote] [nvarchar](1000) NULL,
	[CancelNotification] [bit] NULL,
	[CancelNotifyReason] [nvarchar](100) NULL,
	[Status] [varchar](50) NULL,
	[UserFacilityID] [int] NULL,
 CONSTRAINT [PK_MVD_AppRecord] PRIMARY KEY CLUSTERED 
(
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MVD_AppRecord_Action_ResultStatus_ResultCount] ON [dbo].[MVD_AppRecord]
(
	[Action] ASC,
	[ResultStatus] ASC,
	[ResultCount] ASC
)
INCLUDE([UserName],[MVDID],[Created]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MVD_AppRecord_MVDID] ON [dbo].[MVD_AppRecord]
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MVD_AppRecord] ADD  CONSTRAINT [DF_MVD_AppRecord_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[MVD_AppRecord] ADD  CONSTRAINT [DF_MVD_AppRecord_CancelNotification]  DEFAULT ((0)) FOR [CancelNotification]