/****** Object:  Table [dbo].[ABCBS_RobustDx]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_RobustDx](
	[ICD10] [varchar](30) NOT NULL,
	[ICD10_Description] [varchar](max) NULL,
	[CCSR1] [varchar](50) NULL,
	[CCSR2] [varchar](50) NULL,
	[CCSR3] [varchar](50) NULL,
	[CCSR4] [varchar](50) NULL,
	[Rules] [varchar](50) NULL,
 CONSTRAINT [PK_ABCBS_RobustDx] PRIMARY KEY CLUSTERED 
(
	[ICD10] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]