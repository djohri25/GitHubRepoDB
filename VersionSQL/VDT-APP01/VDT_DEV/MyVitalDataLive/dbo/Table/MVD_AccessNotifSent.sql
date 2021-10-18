/****** Object:  Table [dbo].[MVD_AccessNotifSent]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MVD_AccessNotifSent](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RecipientEmail] [nvarchar](50) NULL,
	[RecipientFName] [nvarchar](50) NULL,
	[RecipientLName] [nvarchar](50) NOT NULL,
	[Subject] [nvarchar](100) NULL,
	[Body] [nvarchar](max) NULL,
	[Type] [nvarchar](50) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_MVD_AccessNotifSent] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[MVD_AccessNotifSent] ADD  CONSTRAINT [DF_MVD_AccessNotifSent_Created]  DEFAULT (getutcdate()) FOR [Created]