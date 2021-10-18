/****** Object:  Table [dbo].[DI_FirstName]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DI_FirstName](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Value] [nvarchar](max) NOT NULL,
	[Gender] [char](1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]