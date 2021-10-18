/****** Object:  Table [dbo].[MainAllergies]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainAllergies](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NOT NULL,
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
 CONSTRAINT [PK_MainAllergies] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MainAllergies] ADD  CONSTRAINT [DF_MainAllergies_HVFlag]  DEFAULT ((0)) FOR [HVFlag]
ALTER TABLE [dbo].[MainAllergies] ADD  CONSTRAINT [DF_MainAllergies_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[MainAllergies] ADD  CONSTRAINT [DF_MainAllergies_ModifyDate]  DEFAULT (getutcdate()) FOR [ModifyDate]
ALTER TABLE [dbo].[MainAllergies] ADD  CONSTRAINT [DF_MainAllergies_ReadOnly]  DEFAULT ((0)) FOR [ReadOnly]
ALTER TABLE [dbo].[MainAllergies]  WITH CHECK ADD  CONSTRAINT [FK_MainAllergies_LookupAllergies] FOREIGN KEY([AllergenTypeId])
REFERENCES [dbo].[LookupAllergies] ([AllergenTypeId])
ALTER TABLE [dbo].[MainAllergies] CHECK CONSTRAINT [FK_MainAllergies_LookupAllergies]
ALTER TABLE [dbo].[MainAllergies]  WITH CHECK ADD  CONSTRAINT [FK_MainAllergies_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[MainAllergies] CHECK CONSTRAINT [FK_MainAllergies_MainPersonalDetails]