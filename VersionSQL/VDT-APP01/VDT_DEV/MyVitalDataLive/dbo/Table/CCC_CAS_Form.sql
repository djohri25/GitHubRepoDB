/****** Object:  Table [dbo].[CCC_CAS_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CCC_CAS_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](20) NOT NULL,
	[q1c] [varchar](max) NULL,
	[q2c] [varchar](max) NULL,
	[q3c] [varchar](max) NULL,
	[q4c] [varchar](max) NULL,
	[q4ac] [varchar](max) NULL,
	[q4bc] [varchar](max) NULL,
	[q5c] [varchar](max) NULL,
	[q5ac] [varchar](max) NULL,
	[q6c] [varchar](max) NULL,
	[q7c] [varchar](max) NULL,
	[CaseID] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]