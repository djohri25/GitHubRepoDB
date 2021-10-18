/****** Object:  Table [dbo].[CarePlanLibraryAssessmentLink]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CarePlanLibraryAssessmentLink](
	[cpLinkNumber] [bigint] IDENTITY(1,1) NOT NULL,
	[cpProbNum] [bigint] NOT NULL,
	[cpAssessmentID] [nvarchar](50) NOT NULL,
	[cpAssessmentQuestion] [nvarchar](50) NOT NULL,
	[cpAssessmentResponse] [nvarchar](max) NOT NULL,
	[cpRequiredFlag] [smallint] NOT NULL,
	[cpLinkActiveDate] [datetime] NULL,
	[cpLinkInactiveDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
	[cpLibraryID] [int] NOT NULL,
	[Cust_ID] [varchar](200) NULL,
 CONSTRAINT [PK_CarePlanLibraryAssessmentLink] PRIMARY KEY CLUSTERED 
(
	[cpLinkNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[CarePlanLibraryAssessmentLink] ADD  CONSTRAINT [DF_CarePlanLibraryAssessmentLink_cpLibraryID]  DEFAULT ((1)) FOR [cpLibraryID]