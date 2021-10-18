/****** Object:  Table [dbo].[MainUserName]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainUserName](
	[UserName] [varchar](50) NOT NULL,
	[Password] [varchar](50) NULL,
	[ICEGROUP] [varchar](15) NULL,
	[IsReadOnly] [bit] NULL,
	[Active] [int] NULL,
	[SecQuestion] [int] NULL,
	[SecAnswer] [varchar](50) NULL,
	[MaxAttachment] [int] NULL,
	[BillingEmail] [varchar](100) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_MainUserName] PRIMARY KEY CLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MainUserName] ADD  CONSTRAINT [DF_MainUserName_IsReadOnly]  DEFAULT ((0)) FOR [IsReadOnly]
ALTER TABLE [dbo].[MainUserName] ADD  CONSTRAINT [DF_MainUserName_Active]  DEFAULT ((0)) FOR [Active]
ALTER TABLE [dbo].[MainUserName] ADD  CONSTRAINT [DF_MainUserName_MaxAttachment]  DEFAULT ((10240)) FOR [MaxAttachment]
ALTER TABLE [dbo].[MainUserName]  WITH CHECK ADD  CONSTRAINT [FK_MainUserName_IceGroup] FOREIGN KEY([ICEGROUP])
REFERENCES [dbo].[MainICEGROUP] ([ICEGROUP])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[MainUserName] CHECK CONSTRAINT [FK_MainUserName_IceGroup]
ALTER TABLE [dbo].[MainUserName]  WITH CHECK ADD  CONSTRAINT [FK_MainUserName_LookupSecurityQuestion] FOREIGN KEY([SecQuestion])
REFERENCES [dbo].[LookupSecurityQuestion] ([QuestionId])
ALTER TABLE [dbo].[MainUserName] CHECK CONSTRAINT [FK_MainUserName_LookupSecurityQuestion]