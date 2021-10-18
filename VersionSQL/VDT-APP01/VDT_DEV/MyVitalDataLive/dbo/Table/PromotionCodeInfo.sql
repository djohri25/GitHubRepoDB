/****** Object:  Table [dbo].[PromotionCodeInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PromotionCodeInfo](
	[PromotionCode] [nvarchar](20) NOT NULL,
	[IsSendWelcomeEmail] [bit] NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_PromotionCodeInfo] PRIMARY KEY CLUSTERED 
(
	[PromotionCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[PromotionCodeInfo] ADD  CONSTRAINT [DF_PromotionCodeCustom_IsSendWelcomeEmail]  DEFAULT ((1)) FOR [IsSendWelcomeEmail]
ALTER TABLE [dbo].[PromotionCodeInfo] ADD  CONSTRAINT [DF_PromotionCodeCustom_Created]  DEFAULT (getdate()) FOR [Created]