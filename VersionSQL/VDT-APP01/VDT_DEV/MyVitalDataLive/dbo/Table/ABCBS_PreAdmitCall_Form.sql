/****** Object:  Table [dbo].[ABCBS_PreAdmitCall_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_PreAdmitCall_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[q1DateofSurgeryScheduled] [datetime] NULL,
	[q2TypeofSurgery] [varchar](max) NULL,
	[q3NameOfHosp] [varchar](max) NULL,
	[q4InstructionPriorSurgery] [varchar](max) NULL,
	[q5CurrentMedicalConditons] [varchar](max) NULL,
	[q6Other] [varchar](max) NULL,
	[q7WhowillbeWithYou] [varchar](max) NULL,
	[q8Permission] [varchar](max) NULL,
	[q9GoodContactNumber] [varchar](max) NULL,
	[q10StayAtHosp] [varchar](max) NULL,
	[q11Discharge] [varchar](max) NULL,
	[q12Transition] [varchar](max) NULL,
	[q13Other] [varchar](max) NULL,
	[q14Services] [varchar](max) NULL,
	[q15WhatServices] [varchar](max) NULL,
	[q15Other] [varchar](max) NULL,
	[q16PCP] [varchar](max) NULL,
	[q17PCPName] [varchar](max) NULL,
	[q18PCPPhone] [varchar](max) NULL,
	[q19SurgeryDateChange] [varchar](max) NULL,
	[q20Appointment] [varchar](max) NULL,
	[q21Prescription] [varchar](max) NULL,
	[q22ContactCM] [varchar](max) NULL,
	[q23Comments] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_PreAdmitCall_Form] ON [dbo].[ABCBS_PreAdmitCall_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_PreAdmitCall_Form_FormDate] ON [dbo].[ABCBS_PreAdmitCall_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_PreAdmitCall_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]