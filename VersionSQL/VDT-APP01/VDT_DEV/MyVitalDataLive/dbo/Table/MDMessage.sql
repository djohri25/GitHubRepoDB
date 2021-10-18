/****** Object:  Table [dbo].[MDMessage]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MDMessage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RecipientDoctorID] [varchar](50) NOT NULL,
	[Subject] [varchar](100) NULL,
	[MessageText] [varchar](max) NULL,
	[Sender] [varchar](100) NULL,
	[Created] [datetime] NULL,
	[ExpirationDate] [datetime] NULL,
 CONSTRAINT [PK_MDMessage] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MDMessage_RecipientDoctorID_ExpirationDate] ON [dbo].[MDMessage]
(
	[RecipientDoctorID] ASC,
	[ExpirationDate] ASC
)
INCLUDE([Created]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MDMessage] ADD  CONSTRAINT [DF_MDMessage_Created]  DEFAULT (getutcdate()) FOR [Created]