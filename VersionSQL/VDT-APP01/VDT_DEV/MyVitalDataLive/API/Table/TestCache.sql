/****** Object:  Table [API].[TestCache]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [API].[TestCache](
	[Id] [nvarchar](449) NOT NULL,
	[Value] [varbinary](max) NOT NULL,
	[ExpiresAtTime] [datetimeoffset](7) NOT NULL,
	[SlidingExpirationInSeconds] [bigint] NULL,
	[AbsoluteExpiration] [datetimeoffset](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [Index_ExpiresAtTime] ON [API].[TestCache]
(
	[ExpiresAtTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]