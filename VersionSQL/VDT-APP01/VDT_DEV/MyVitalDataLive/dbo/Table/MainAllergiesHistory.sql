/****** Object:  Table [dbo].[MainAllergiesHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainAllergiesHistory](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RecordNumber] [int] NOT NULL,
	[ICENUMBER] [varchar](20) NOT NULL,
	[AllergenTypeId] [int] NULL,
	[AllergenName] [varchar](25) NULL,
	[Reaction] [varchar](150) NULL,
	[HVID] [char](36) NULL,
	[HVFlag] [tinyint] NOT NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[ReadOnly] [bit] NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[UpdatedBy] [nvarchar](250) NULL,
	[UpdatedByOrganization] [varchar](250) NULL,
	[UpdatedByContact] [nvarchar](64) NULL,
	[Organization] [nvarchar](256) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_MainAllergiesHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MainAllergiesHistory] ADD  CONSTRAINT [DF_MainAllergiesHistory_HVFlag]  DEFAULT ((0)) FOR [HVFlag]
ALTER TABLE [dbo].[MainAllergiesHistory] ADD  CONSTRAINT [DF_MainAllergiesHistory_ReadOnly]  DEFAULT ((0)) FOR [ReadOnly]
ALTER TABLE [dbo].[MainAllergiesHistory] ADD  CONSTRAINT [DF_MainAllergiesHistory_Created]  DEFAULT (getutcdate()) FOR [Created]