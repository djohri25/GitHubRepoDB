/****** Object:  Table [dbo].[HPHealthPlanType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPHealthPlanType](
	[HealthPlanType_ID] [int] NOT NULL,
	[Cust_ID] [int] NULL,
	[Name] [nvarchar](50) NULL,
	[Active] [bit] NULL,
 CONSTRAINT [PK_HPHealthPlanTypes] PRIMARY KEY CLUSTERED 
(
	[HealthPlanType_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[HPHealthPlanType]  WITH CHECK ADD  CONSTRAINT [FK_HPHealthPlanTypes_HPCustomer] FOREIGN KEY([Cust_ID])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[HPHealthPlanType] CHECK CONSTRAINT [FK_HPHealthPlanTypes_HPCustomer]