/****** Object:  Table [dbo].[CopcFacility]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CopcFacility](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[FacilityName] [varchar](50) NULL,
	[Active] [bit] NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_CopcFacility] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[CopcFacility] ADD  CONSTRAINT [DF_CopcFacility_Active]  DEFAULT ((0)) FOR [Active]
ALTER TABLE [dbo].[CopcFacility] ADD  CONSTRAINT [DF_CopcFacility_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[CopcFacility] ADD  CONSTRAINT [DF_CopcFacility_ModifyDate]  DEFAULT (getutcdate()) FOR [ModifyDate]