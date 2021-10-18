/****** Object:  Table [dbo].[MVDApplicationSpec]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MVDApplicationSpec](
	[ApplicationID] [nvarchar](50) NOT NULL,
	[Type] [varchar](50) NULL,
	[Created] [datetime] NULL,
	[Notes] [varchar](200) NULL,
 CONSTRAINT [PK_MVDApplicationSpec] PRIMARY KEY CLUSTERED 
(
	[ApplicationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MVDApplicationSpec] ADD  CONSTRAINT [DF_MVDApplicationSpec_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[MVDApplicationSpec]  WITH CHECK ADD  CONSTRAINT [FK_MVDApplicationSpec_MVDApplication] FOREIGN KEY([ApplicationID])
REFERENCES [dbo].[MVDApplication] ([AppID])
ALTER TABLE [dbo].[MVDApplicationSpec] CHECK CONSTRAINT [FK_MVDApplicationSpec_MVDApplication]