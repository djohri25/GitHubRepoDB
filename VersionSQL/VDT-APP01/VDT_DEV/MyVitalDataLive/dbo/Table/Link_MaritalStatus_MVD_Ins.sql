/****** Object:  Table [dbo].[Link_MaritalStatus_MVD_Ins]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_MaritalStatus_MVD_Ins](
	[MVDMaritalStatusId] [int] NOT NULL,
	[InsMaritalStatusId] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Link_MaritalStatus_MVD_Ins] PRIMARY KEY CLUSTERED 
(
	[MVDMaritalStatusId] ASC,
	[InsMaritalStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]