/****** Object:  Table [dbo].[SSO_Log]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SSO_Log](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](50) NULL,
	[UserTIN] [varchar](50) NULL,
	[Action] [varchar](max) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_SSO_Log] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[SSO_Log] ADD  CONSTRAINT [DF_SSO_Log_Created]  DEFAULT (getutcdate()) FOR [Created]