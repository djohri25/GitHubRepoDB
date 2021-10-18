/****** Object:  Table [dbo].[TempADDMember]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TempADDMember](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[DispensingDate] [datetime] NOT NULL,
	[DOB] [datetime] NULL,
	[InsMemberID] [varchar](20) NULL,
	[isCompleteInit] [bit] NULL,
	[isCompleteCM] [bit] NULL,
	[isProcessed] [bit] NULL,
 CONSTRAINT [PK_TempADDMember] PRIMARY KEY CLUSTERED 
(
	[MVDID] ASC,
	[DispensingDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TempADDMember] ADD  CONSTRAINT [DF_TempADDMember_isCompleteInit]  DEFAULT ((0)) FOR [isCompleteInit]
ALTER TABLE [dbo].[TempADDMember] ADD  CONSTRAINT [DF_TempADDMember_isCompleteCM]  DEFAULT ((0)) FOR [isCompleteCM]
ALTER TABLE [dbo].[TempADDMember] ADD  CONSTRAINT [DF_TempADDMember_isProcessed]  DEFAULT ((0)) FOR [isProcessed]