/****** Object:  Table [dbo].[ABCBS_ReferraltoNewDirections_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_ReferraltoNewDirections_Form](
	[MVDID] [varchar](20) NULL,
	[FormDate] [datetime] NULL,
	[FormAuthor] [varchar](100) NULL,
	[CaseID] [varchar](100) NULL,
	[Actions] [varchar](max) NULL,
	[q2MemFirstName] [varchar](max) NULL,
	[q2MemLastName] [varchar](max) NULL,
	[qDOB1] [varchar](max) NULL,
	[MemID] [varchar](max) NULL,
	[phoneNumber] [varchar](max) NULL,
	[DaytimePhone] [varchar](max) NULL,
	[CallPhoneNumber] [varchar](max) NULL,
	[qEmail] [varchar](max) NULL,
	[Addr1] [varchar](max) NULL,
	[Addr2] [varchar](max) NULL,
	[Addr3] [varchar](max) NULL,
	[AltAddr1] [varchar](max) NULL,
	[AltAddr2] [varchar](max) NULL,
	[AltAddr3] [varchar](max) NULL,
	[qMemberGuardian] [varchar](max) NULL,
	[qGuardiansName] [varchar](max) NULL,
	[q1RefDate] [datetime] NULL,
	[q1RefTo] [varchar](max) NULL,
	[q1RefFrom] [varchar](max) NULL,
	[q2UrgentReview] [varchar](max) NULL,
	[q3ReferralSource] [varchar](max) NULL,
	[qCareFlowRule] [varchar](max) NULL,
	[q1CareFlowRule] [varchar](max) NULL,
	[q2CareFlowRule] [varchar](max) NULL,
	[q3CareFlowRule] [varchar](max) NULL,
	[q4CareFlowRule] [varchar](max) NULL,
	[q5CareFlowRule] [varchar](max) NULL,
	[q6CareFlowRule] [varchar](max) NULL,
	[q7CareFlowRule] [varchar](max) NULL,
	[q8CareFlowRule] [varchar](max) NULL,
	[q9CareFlowRule] [varchar](max) NULL,
	[q10CareFlowRule] [varchar](max) NULL,
	[q11CareFlowRule] [varchar](max) NULL,
	[q12CareFlowRule] [varchar](max) NULL,
	[q3OtherReferral] [varchar](max) NULL,
	[q3ABCBSReferral1] [varchar](max) NULL,
	[q3BHReferral] [varchar](max) NULL,
	[q3BHReferral1] [varchar](max) NULL,
	[q3BHReferral2] [varchar](max) NULL,
	[q3BHReferral3] [varchar](max) NULL,
	[q4CaseManager] [varchar](max) NULL,
	[q5CaseManagerPhone] [varchar](max) NULL,
	[q5CaseManageremail] [varchar](max) NULL,
	[q6ReqRefRecipient] [varchar](max) NULL,
	[q8Notes] [varchar](max) NULL,
	[q9DiscussedBH] [varchar](max) NULL,
	[qContactDiscussed] [varchar](max) NULL,
	[q10CallfromABCBSCM] [varchar](max) NULL,
	[q10CallfromNewDir] [varchar](max) NULL,
	[q10CallfromABCBSDietitian] [varchar](max) NULL,
	[q10CallfromABCBSPharmacy] [varchar](max) NULL,
	[q10CallfromABCBSSW] [varchar](max) NULL,
	[q11BestTimeToCallMember] [varchar](max) NULL,
	[qReasonReferral] [varchar](max) NULL,
	[qOtherReferral] [varchar](max) NULL,
	[qDetailedReason] [varchar](max) NULL,
	[q28MedHistory] [varchar](max) NULL,
	[q27memberPregnant] [varchar](max) NULL,
	[q27DueDate] [datetime] NULL,
	[q27OBProvider] [varchar](max) NULL,
	[q27SubstanceAbuse] [varchar](max) NULL,
	[q27Substances] [varchar](max) NULL,
	[q27ReferredFor] [varchar](max) NULL,
	[q27PCPRecord] [varchar](max) NULL,
	[q27CurrentTreatingPCP] [varchar](max) NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LoadDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IC_ABCBS_ReferraltoNewDirections_Form_MVDID] ON [dbo].[ABCBS_ReferraltoNewDirections_Form]
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_ReferraltoNewDirections_Form] ON [dbo].[ABCBS_ReferraltoNewDirections_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_ReferraltoNewDirections_Form_FormDate] ON [dbo].[ABCBS_ReferraltoNewDirections_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_ReferraltoNewDirections_Form] ADD  CONSTRAINT [df_LoadDate]  DEFAULT (getdate()) FOR [LoadDate]