/****** Object:  Table [dbo].[Link_HPFacilityCustomer]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPFacilityCustomer](
	[Cust_ID] [int] NOT NULL,
	[Facility_ID] [int] NOT NULL,
 CONSTRAINT [PK_Link_HPFacilityCustomer] PRIMARY KEY CLUSTERED 
(
	[Cust_ID] ASC,
	[Facility_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPFacilityCustomer]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPFacilityCustomer_HPCustomer] FOREIGN KEY([Cust_ID])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[Link_HPFacilityCustomer] CHECK CONSTRAINT [FK_Link_HPFacilityCustomer_HPCustomer]