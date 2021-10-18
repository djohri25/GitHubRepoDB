/****** Object:  Table [dbo].[Link_SupUser_Admin_HPCustomer]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_SupUser_Admin_HPCustomer](
	[SupportToolUserId] [uniqueidentifier] NOT NULL,
	[HPCustomerId] [int] NOT NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_Link_SupUser_Admin_HPCustomer_1] PRIMARY KEY CLUSTERED 
(
	[SupportToolUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_SupUser_Admin_HPCustomer] ADD  CONSTRAINT [DF_Link_SupUser_Admin_HPCustomer_ModifyDate]  DEFAULT (getutcdate()) FOR [ModifyDate]
ALTER TABLE [dbo].[Link_SupUser_Admin_HPCustomer]  WITH CHECK ADD  CONSTRAINT [FK_Link_SupUser_Admin_HPCustomer_HPCustomer] FOREIGN KEY([HPCustomerId])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[Link_SupUser_Admin_HPCustomer] CHECK CONSTRAINT [FK_Link_SupUser_Admin_HPCustomer_HPCustomer]