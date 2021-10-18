/****** Object:  Table [dbo].[MainImage]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainImage](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](20) NOT NULL,
	[ImageName] [nvarchar](256) NULL,
	[ContentType] [varchar](64) NULL,
	[Data] [varbinary](max) NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateModified] [datetime] NOT NULL,
 CONSTRAINT [PK_MainImage] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]