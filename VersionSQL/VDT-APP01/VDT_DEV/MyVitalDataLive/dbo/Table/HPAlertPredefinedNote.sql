/****** Object:  Table [dbo].[HPAlertPredefinedNote]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPAlertPredefinedNote](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustID] [int] NULL,
	[ShortName] [varchar](50) NULL,
	[Note] [varchar](max) NULL,
	[Created] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
	[ModifiedBy] [varchar](50) NULL,
	[StatusID] [varchar](50) NULL,
	[AlertGroupID] [int] NULL,
 CONSTRAINT [PK_HPAlertPredefinedNote] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[HPAlertPredefinedNote] ADD  CONSTRAINT [DF_HPAlertPredefinedNote_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[HPAlertPredefinedNote] ADD  CONSTRAINT [DF_Table_1_ModifyDate]  DEFAULT (getutcdate()) FOR [ModifiedDate]