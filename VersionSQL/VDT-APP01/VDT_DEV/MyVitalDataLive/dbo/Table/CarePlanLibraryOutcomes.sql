/****** Object:  Table [dbo].[CarePlanLibraryOutcomes]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CarePlanLibraryOutcomes](
	[cpOutcomeNum] [bigint] NOT NULL,
	[cpProbNum] [bigint] NOT NULL,
	[cpOutcomeText] [nvarchar](max) NOT NULL,
	[cpOutcomeActiveDate] [datetime] NULL,
	[cpOutcomeInactiveDate] [datetime] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
 CONSTRAINT [PK_CarePlanLibraryOutcome] PRIMARY KEY CLUSTERED 
(
	[cpOutcomeNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[CarePlanLibraryOutcomes] ADD  CONSTRAINT [DF_CarePlanLibraryOutcomes_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
ALTER TABLE [dbo].[CarePlanLibraryOutcomes] ADD  CONSTRAINT [DF_CarePlanLibraryOutcomes_CreatedBy]  DEFAULT (suser_sname()) FOR [CreatedBy]