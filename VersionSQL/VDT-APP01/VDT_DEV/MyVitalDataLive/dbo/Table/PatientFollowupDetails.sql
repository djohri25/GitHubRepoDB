/****** Object:  Table [dbo].[PatientFollowupDetails]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PatientFollowupDetails](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[MemberID] [varchar](15) NULL,
	[CustID] [int] NULL,
	[PatientFirstName] [varchar](32) NOT NULL,
	[PatientLastName] [varchar](32) NOT NULL,
	[FacilityID] [int] NOT NULL,
	[DateVisited] [datetime] NOT NULL,
	[DateCalled] [datetime] NOT NULL,
	[EDPatientStatusID] [int] NOT NULL,
	[IsComplete] [bit] NOT NULL,
	[YN1] [tinyint] NULL,
	[MC2] [tinyint] NULL,
	[YN4] [tinyint] NULL,
	[YN5] [tinyint] NULL,
	[MC6] [tinyint] NULL,
	[YN7] [tinyint] NULL,
	[YN8] [tinyint] NULL,
	[YN9] [tinyint] NULL,
	[YN10] [tinyint] NULL,
	[YN11] [tinyint] NULL,
	[YN12] [tinyint] NULL,
	[Text3] [text] NULL,
	[Text6] [text] NULL,
	[Text12] [text] NULL,
	[ModifiedBy] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateModified] [datetime] NOT NULL,
 CONSTRAINT [PK_PatientFollowupDetails] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[PatientFollowupDetails] ADD  CONSTRAINT [DF_PatientFollowupDetails_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
ALTER TABLE [dbo].[PatientFollowupDetails] ADD  CONSTRAINT [DF_PatientFollowupDetails_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]