/****** Object:  Table [dbo].[PromotionCode]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PromotionCode](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[PromotionCode] [nvarchar](20) NOT NULL,
	[MyVitalDataID] [nvarchar](20) NULL,
	[DateCreated] [datetime] NULL,
	[DateActivated] [datetime] NULL,
 CONSTRAINT [PK_PromotionCode] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]