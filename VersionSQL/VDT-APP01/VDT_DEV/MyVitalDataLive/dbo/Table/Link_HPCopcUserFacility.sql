/****** Object:  Table [dbo].[Link_HPCopcUserFacility]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPCopcUserFacility](
	[UserID] [varchar](50) NOT NULL,
	[FacilityID] [int] NOT NULL,
 CONSTRAINT [PK_Link_HPCopcUserFacility] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[FacilityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]