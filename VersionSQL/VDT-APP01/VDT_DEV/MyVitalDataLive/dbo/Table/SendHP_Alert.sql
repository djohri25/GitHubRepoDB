/****** Object:  Table [dbo].[SendHP_Alert]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SendHP_Alert](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RecordAccessID] [int] NULL,
	[CustomerID] [int] NULL,
	[RecipientEmail] [varchar](50) NULL,
	[InsMemberId] [varchar](50) NULL,
	[InsMemberFName] [varchar](50) NULL,
	[InsMemberLName] [varchar](50) NULL,
	[AccessDate] [datetime] NULL,
	[NPI] [varchar](50) NULL,
	[FacilityName] [varchar](50) NULL,
	[ChiefComplaint] [varchar](100) NULL,
	[EMSNote] [varchar](1000) NULL,
	[SentDate] [datetime] NULL,
	[Status] [varchar](50) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_SendHPM_Alert] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[SendHP_Alert] ADD  CONSTRAINT [DF_SendHPM_Alert_Created]  DEFAULT (getutcdate()) FOR [Created]