/****** Object:  Table [dbo].[UserTimeKeeping]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[UserTimeKeeping](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](30) NULL,
	[CustId] [int] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[Note] [varchar](max) NULL,
	[Created] [datetime] NULL,
	[Updated] [datetime] NULL,
	[MemberId] [varchar](20) NULL,
 CONSTRAINT [PK_UserTimeKeeping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_UserTimeKeeping_Created] ON [dbo].[UserTimeKeeping]
(
	[Created] ASC,
	[Updated] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_UserTimeKeeping_Updated] ON [dbo].[UserTimeKeeping]
(
	[Updated] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[UserTimeKeeping] ADD  CONSTRAINT [DF__UserTimeK__Creat__0F8ECA2F]  DEFAULT (getutcdate()) FOR [Created]