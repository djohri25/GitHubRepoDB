/****** Object:  Table [dbo].[CCC_StakeholderGroup]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CCC_StakeholderGroup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StakeholderGroup] [varchar](150) NULL,
	[UserType] [varchar](100) NULL,
	[Created] [datetime] NULL,
	[Updated] [datetime] NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[CCC_StakeholderGroup] ADD  DEFAULT (getutcdate()) FOR [Created]