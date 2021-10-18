/****** Object:  Table [dbo].[MainLicenseCoupon]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainLicenseCoupon](
	[CouponId] [varchar](15) NOT NULL,
	[OrderNum] [int] NULL,
	[LicenseType] [varchar](3) NULL,
	[VariantId] [int] NULL,
	[ProductId] [int] NULL,
	[LicenseTotal] [int] NULL,
	[IsUsed] [int] NULL,
	[Email] [varchar](50) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_MainLicenseCoupon] PRIMARY KEY CLUSTERED 
(
	[CouponId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainLicenseCoupon] ON [dbo].[MainLicenseCoupon]
(
	[LicenseType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
ALTER TABLE [dbo].[MainLicenseCoupon] ADD  CONSTRAINT [DF_MainLicenseCoupon_LicenseTotal]  DEFAULT ((1)) FOR [LicenseTotal]
ALTER TABLE [dbo].[MainLicenseCoupon] ADD  CONSTRAINT [DF_MainLicenseCoupon_IsUsed]  DEFAULT ((0)) FOR [IsUsed]