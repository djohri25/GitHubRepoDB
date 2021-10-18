/****** Object:  Table [dbo].[QuickActionType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[QuickActionType](
	[Id] [tinyint] IDENTITY(1,1) NOT NULL,
	[TypeName] [varchar](50) NOT NULL,
	[TypeDescription] [varchar](250) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [varchar](20) NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_QuickActionType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[QuickActionType] ADD  CONSTRAINT [DF_QuickActionType_CreatedDate]  DEFAULT (getutcdate()) FOR [CreatedDate]
ALTER TABLE [dbo].[QuickActionType] ADD  CONSTRAINT [DF_QuickActionType_UpdatedDate]  DEFAULT (getutcdate()) FOR [UpdatedDate]
ALTER TABLE [dbo].[QuickActionType] ADD  CONSTRAINT [DF_QuickActionType_IsActive]  DEFAULT ((1)) FOR [IsActive]