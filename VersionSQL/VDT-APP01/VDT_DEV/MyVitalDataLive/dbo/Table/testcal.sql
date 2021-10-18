/****** Object:  Table [dbo].[testcal]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[testcal](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](10) NULL,
	[DOB] [date] NULL,
	[Age]  AS (datediff(year,[DOB],getdate()))
) ON [PRIMARY]