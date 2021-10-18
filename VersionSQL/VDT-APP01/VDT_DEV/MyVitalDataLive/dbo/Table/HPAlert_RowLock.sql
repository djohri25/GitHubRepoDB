/****** Object:  Table [dbo].[HPAlert_RowLock]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPAlert_RowLock](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[HPAlertID] [int] NOT NULL,
	[Owner] [nvarchar](64) NOT NULL,
	[DateLocked] [datetime] NOT NULL,
 CONSTRAINT [PK_HPAlert_RowLock] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY],
 CONSTRAINT [IX_HPAlert_RowLock] UNIQUE NONCLUSTERED 
(
	[HPAlertID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[HPAlert_RowLock] ADD  CONSTRAINT [DF_HPAlert_RowLocks_LockedAt]  DEFAULT (getutcdate()) FOR [DateLocked]