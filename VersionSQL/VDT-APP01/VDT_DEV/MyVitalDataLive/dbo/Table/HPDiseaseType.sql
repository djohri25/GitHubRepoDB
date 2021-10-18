/****** Object:  Table [dbo].[HPDiseaseType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPDiseaseType](
	[Disease_ID] [int] NOT NULL,
	[Cust_ID] [int] NULL,
	[Name] [nvarchar](50) NULL,
	[Active] [bit] NULL,
 CONSTRAINT [PK_HPDiseaseType] PRIMARY KEY CLUSTERED 
(
	[Disease_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[HPDiseaseType] ADD  CONSTRAINT [DF_HPDiseaseType_Active]  DEFAULT ((0)) FOR [Active]
ALTER TABLE [dbo].[HPDiseaseType]  WITH CHECK ADD  CONSTRAINT [FK_HPDiseaseType_HPCustomer] FOREIGN KEY([Cust_ID])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[HPDiseaseType] CHECK CONSTRAINT [FK_HPDiseaseType_HPCustomer]