/****** Object:  Table [dbo].[MemberGeocode]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MemberGeocode](
	[MemberID] [varchar](15) NULL,
	[Lat] [nvarchar](255) NULL,
	[Lon] [nvarchar](255) NULL,
	[GeoCode] [nvarchar](255) NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MemberID] ON [dbo].[MemberGeocode]
(
	[MemberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]