/****** Object:  Table [dbo].[HPDiagnosis]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPDiagnosis](
	[Diagnosis_ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Cust_ID] [int] NULL,
	[Name] [nvarchar](50) NULL,
	[Active] [bit] NULL,
	[Type] [varchar](50) NULL,
 CONSTRAINT [PK_HPDiagnosis] PRIMARY KEY CLUSTERED 
(
	[Diagnosis_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[HPDiagnosis] ADD  CONSTRAINT [DF_HPDiagnosis_Active]  DEFAULT ((1)) FOR [Active]
ALTER TABLE [dbo].[HPDiagnosis]  WITH CHECK ADD  CONSTRAINT [FK_HPCustomer_HPDiagnosis] FOREIGN KEY([Cust_ID])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[HPDiagnosis] CHECK CONSTRAINT [FK_HPCustomer_HPDiagnosis]