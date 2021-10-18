/****** Object:  Table [dbo].[LookupCS_ReportImagePath]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCS_ReportImagePath](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReportID] [int] NULL,
	[CustID] [int] NULL,
	[FullImagePath] [varchar](100) NULL,
 CONSTRAINT [PK_LookupCS_ReportImagePath_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[LookupCS_ReportImagePath]  WITH CHECK ADD  CONSTRAINT [FK_LookupCS_ReportImagePath_LookupCS_Report_ReportID_CustID] FOREIGN KEY([CustID])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[LookupCS_ReportImagePath] CHECK CONSTRAINT [FK_LookupCS_ReportImagePath_LookupCS_Report_ReportID_CustID]