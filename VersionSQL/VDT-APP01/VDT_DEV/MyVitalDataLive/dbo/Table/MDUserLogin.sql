/****** Object:  Table [dbo].[MDUserLogin]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MDUserLogin](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](50) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_MDUserLogin] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MDUserLogin] ADD  CONSTRAINT [DF_MDUserLogin_Created]  DEFAULT (getdate()) FOR [Created]