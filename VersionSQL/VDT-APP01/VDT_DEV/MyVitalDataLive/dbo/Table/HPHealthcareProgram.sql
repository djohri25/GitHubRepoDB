/****** Object:  Table [dbo].[HPHealthcareProgram]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPHealthcareProgram](
	[Name] [varchar](100) NOT NULL,
	[Cust_ID] [int] NOT NULL,
	[Phone] [varchar](50) NULL,
	[Extension] [varchar](10) NULL,
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Description] [varchar](300) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_HPHealthcareProgram_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[HPHealthcareProgram] ADD  CONSTRAINT [DF_HPHealthcareProgram_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[HPHealthcareProgram]  WITH CHECK ADD  CONSTRAINT [FK_HPHealthcareProgram_HPCustomer] FOREIGN KEY([Cust_ID])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[HPHealthcareProgram] CHECK CONSTRAINT [FK_HPHealthcareProgram_HPCustomer]