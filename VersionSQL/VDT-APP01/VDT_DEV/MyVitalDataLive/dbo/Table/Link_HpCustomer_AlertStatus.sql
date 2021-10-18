/****** Object:  Table [dbo].[Link_HpCustomer_AlertStatus]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HpCustomer_AlertStatus](
	[CustID] [int] NOT NULL,
	[StatusID] [int] NOT NULL,
 CONSTRAINT [PK_Link_HpCustomer_AlertStatus] PRIMARY KEY CLUSTERED 
(
	[CustID] ASC,
	[StatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]