/****** Object:  Table [dbo].[HPHealthPlan]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPHealthPlan](
	[HealthPlan_ID] [int] NOT NULL,
	[Cust_ID] [int] NULL,
	[Name] [nvarchar](50) NULL,
	[Address1] [nvarchar](50) NULL,
	[Address2] [nvarchar](50) NULL,
	[City] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[PostalCode] [nvarchar](50) NULL,
	[Active] [bit] NULL,
 CONSTRAINT [PK_HPHealthPlan] PRIMARY KEY CLUSTERED 
(
	[HealthPlan_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[HPHealthPlan] ADD  CONSTRAINT [DF_HPHealthPlan_Active]  DEFAULT ((0)) FOR [Active]
ALTER TABLE [dbo].[HPHealthPlan]  WITH CHECK ADD  CONSTRAINT [FK_HPHealthPlan_HPCustomer] FOREIGN KEY([Cust_ID])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[HPHealthPlan] CHECK CONSTRAINT [FK_HPHealthPlan_HPCustomer]