/****** Object:  Table [dbo].[Final_MemberOwner]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Final_MemberOwner](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustID] [smallint] NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[OwnerType] [varchar](50) NOT NULL,
	[UserID] [nvarchar](128) NULL,
	[GroupID] [smallint] NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[CreatedBy] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[OwnerName] [varchar](50) NULL,
	[UpdatedBy] [varchar](50) NULL,
	[UpdatedDate] [datetime] NULL,
	[FirstName] [varchar](100) NULL,
	[LastName] [varchar](100) NULL,
	[IsDeactivated] [bit] NULL,
	[AssignmentTypeCodeID] [int] NULL,
 CONSTRAINT [PK_Final_MemberOwner_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_Final_MemberOwner_UpdatedDate] ON [dbo].[Final_MemberOwner]
(
	[UpdatedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MVDID_OwnerType_IsDeactivated] ON [dbo].[Final_MemberOwner]
(
	[MVDID] ASC
)
INCLUDE([OwnerType],[IsDeactivated]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_OwnerName] ON [dbo].[Final_MemberOwner]
(
	[OwnerName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[Final_MemberOwner] ADD  CONSTRAINT [DF_FinalMemberOwner_OwnerType]  DEFAULT ((1)) FOR [OwnerType]