/****** Object:  Table [dbo].[MainPlaces]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainPlaces](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NOT NULL,
	[Name] [varchar](50) NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](2) NULL,
	[Postal] [varchar](5) NULL,
	[Phone] [varchar](10) NULL,
	[FaxPhone] [varchar](10) NULL,
	[WebSite] [varchar](200) NULL,
	[PlacesTypeID] [int] NULL,
	[RoomLoc] [varchar](50) NULL,
	[Direction] [varchar](150) NULL,
	[Note] [varchar](250) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_MainPlaces] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainPlaces] ON [dbo].[MainPlaces]
(
	[ICENUMBER] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MainPlaces]  WITH CHECK ADD  CONSTRAINT [FK_MainPlaces_LookupPlacesTypeID1] FOREIGN KEY([PlacesTypeID])
REFERENCES [dbo].[LookupPlacesTypeID] ([PlacesTypeID])
ALTER TABLE [dbo].[MainPlaces] CHECK CONSTRAINT [FK_MainPlaces_LookupPlacesTypeID1]
ALTER TABLE [dbo].[MainPlaces]  WITH CHECK ADD  CONSTRAINT [FK_MainPlaces_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[MainPlaces] CHECK CONSTRAINT [FK_MainPlaces_MainPersonalDetails]