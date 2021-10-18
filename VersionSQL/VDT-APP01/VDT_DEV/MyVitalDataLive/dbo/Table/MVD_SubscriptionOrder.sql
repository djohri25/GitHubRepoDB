/****** Object:  Table [dbo].[MVD_SubscriptionOrder]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MVD_SubscriptionOrder](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TransactionID] [varchar](50) NULL,
	[SubscriptionType] [int] NULL,
	[Email] [varchar](50) NULL,
	[FirstNameOnCard] [varchar](50) NULL,
	[LastNameOnCard] [varchar](50) NULL,
	[CardType] [varchar](50) NULL,
	[CardNumber] [varchar](50) NULL,
	[CardVerificationCode] [varchar](10) NULL,
	[CardExpirationMonth] [int] NULL,
	[CardExpirationYear] [int] NULL,
	[BillingAddress1] [varchar](50) NULL,
	[BillingAddress2] [varchar](50) NULL,
	[BillingCity] [varchar](100) NULL,
	[BillingState] [varchar](100) NULL,
	[BillingZip] [varchar](10) NULL,
	[ProcessedDate] [datetime] NULL,
	[Created] [datetime] NULL,
	[GrossAmount] [money] NULL,
	[FeeAmount] [money] NULL,
	[SubscriptionName] [varchar](50) NULL,
	[SubscriptionLength] [int] NULL,
	[NewAccountURL] [varchar](1000) NULL,
	[IsAccountCreated] [bit] NULL,
	[IsReminderEmailSent] [bit] NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[MVD_SubscriptionOrder] ADD  CONSTRAINT [DF_MVD_SubscriptionOrder_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[MVD_SubscriptionOrder] ADD  DEFAULT ((0)) FOR [IsAccountCreated]
ALTER TABLE [dbo].[MVD_SubscriptionOrder] ADD  DEFAULT ((0)) FOR [IsReminderEmailSent]