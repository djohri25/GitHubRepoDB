/****** Object:  Table [dbo].[UserAdditionalInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[UserAdditionalInfo](
	[MVDID] [nvarchar](15) NOT NULL,
	[IsPackageSent] [bit] NULL,
	[LastUpdate] [datetime] NULL,
	[WasLoggedIn] [bit] NULL,
	[SurveyShowAlways] [bit] NULL,
	[HealthPlanUserNote] [nvarchar](2000) NULL,
	[HealthPlanNoteLastUpdate] [datetime] NULL,
 CONSTRAINT [PK_UserAdditionalInfo] PRIMARY KEY CLUSTERED 
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[UserAdditionalInfo] ADD  CONSTRAINT [DF_UserAdditionalInfo_UpdateDate]  DEFAULT (getutcdate()) FOR [LastUpdate]
ALTER TABLE [dbo].[UserAdditionalInfo] ADD  CONSTRAINT [DF_UserAdditionalInfo_WasLoggedIn]  DEFAULT ((0)) FOR [WasLoggedIn]
ALTER TABLE [dbo].[UserAdditionalInfo] ADD  CONSTRAINT [DF_UserAdditionalInfo_SurveyShowAlways]  DEFAULT ((0)) FOR [SurveyShowAlways]