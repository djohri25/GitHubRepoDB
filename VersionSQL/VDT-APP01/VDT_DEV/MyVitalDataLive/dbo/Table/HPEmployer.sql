/****** Object:  Table [dbo].[HPEmployer]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPEmployer](
	[Employer_ID] [int] NOT NULL,
	[Cust_ID] [int] NULL,
	[Name] [nvarchar](50) NULL,
	[Active] [bit] NULL,
 CONSTRAINT [PK_HPEmployer] PRIMARY KEY CLUSTERED 
(
	[Employer_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[HPEmployer] ADD  CONSTRAINT [DF_HPEmployer_Active]  DEFAULT ((0)) FOR [Active]
ALTER TABLE [dbo].[HPEmployer]  WITH CHECK ADD  CONSTRAINT [FK_HPEmployer_HPCustomer] FOREIGN KEY([Cust_ID])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[HPEmployer] CHECK CONSTRAINT [FK_HPEmployer_HPCustomer]