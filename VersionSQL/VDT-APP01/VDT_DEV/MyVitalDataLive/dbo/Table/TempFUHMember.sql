/****** Object:  Table [dbo].[TempFUHMember]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TempFUHMember](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[DischargeDate] [datetime] NOT NULL,
	[DOB] [datetime] NULL,
	[InsMemberID] [varchar](20) NULL,
	[Exist30DayFollowUp] [bit] NULL,
	[Exist7DayFollowUp] [bit] NULL,
	[isProcessed] [bit] NULL,
 CONSTRAINT [PK_TempFUHMember] PRIMARY KEY CLUSTERED 
(
	[MVDID] ASC,
	[DischargeDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TempFUHMember] ADD  CONSTRAINT [DF_TempFUHMember_Exist30DayFollowUp]  DEFAULT ((0)) FOR [Exist30DayFollowUp]
ALTER TABLE [dbo].[TempFUHMember] ADD  CONSTRAINT [DF_TempFUHMember_Exist7DayFollowUp]  DEFAULT ((0)) FOR [Exist7DayFollowUp]
ALTER TABLE [dbo].[TempFUHMember] ADD  CONSTRAINT [DF_TempFUHMember_isProcessed]  DEFAULT ((0)) FOR [isProcessed]