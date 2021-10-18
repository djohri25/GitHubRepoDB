/****** Object:  Table [dbo].[HPDiseaseManagement]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPDiseaseManagement](
	[DM_ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Name] [varchar](50) NULL,
	[Cust_ID] [int] NULL,
	[Active] [bit] NULL,
 CONSTRAINT [PK_LookupDiseaseManagement] PRIMARY KEY CLUSTERED 
(
	[DM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[HPDiseaseManagement] ADD  CONSTRAINT [DF_LookupDiseaseManagement_Active]  DEFAULT ((1)) FOR [Active]
ALTER TABLE [dbo].[HPDiseaseManagement]  WITH CHECK ADD  CONSTRAINT [FK_HPDiseaseManagement_HPCustomer] FOREIGN KEY([Cust_ID])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[HPDiseaseManagement] CHECK CONSTRAINT [FK_HPDiseaseManagement_HPCustomer]