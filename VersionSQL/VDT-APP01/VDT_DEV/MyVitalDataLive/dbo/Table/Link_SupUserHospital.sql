/****** Object:  Table [dbo].[Link_SupUserHospital]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_SupUserHospital](
	[SupportToolUserId] [uniqueidentifier] NOT NULL,
	[HospitalId] [int] NOT NULL,
 CONSTRAINT [PK_Link_SupUserHospital] PRIMARY KEY CLUSTERED 
(
	[SupportToolUserId] ASC,
	[HospitalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]