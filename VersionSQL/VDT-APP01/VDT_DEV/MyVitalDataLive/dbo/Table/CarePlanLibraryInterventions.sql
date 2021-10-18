/****** Object:  Table [dbo].[CarePlanLibraryInterventions]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CarePlanLibraryInterventions](
	[cpInterventionNum] [bigint] NOT NULL,
	[cpGoalNum] [bigint] NOT NULL,
	[cpInterventionText] [nvarchar](max) NOT NULL,
	[cpInterventionActiveDate] [datetime] NULL,
	[cpInterventionInactiveDate] [datetime] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
 CONSTRAINT [PK_CarePlanLibraryInterventions] PRIMARY KEY CLUSTERED 
(
	[cpInterventionNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[CarePlanLibraryInterventions] ADD  CONSTRAINT [DF_CarePlanLibraryInterventions_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
ALTER TABLE [dbo].[CarePlanLibraryInterventions] ADD  CONSTRAINT [DF_CarePlanLibraryInterventions_CreatedBy]  DEFAULT (suser_sname()) FOR [CreatedBy]