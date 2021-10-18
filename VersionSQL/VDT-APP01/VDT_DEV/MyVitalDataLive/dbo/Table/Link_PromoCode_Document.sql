/****** Object:  Table [dbo].[Link_PromoCode_Document]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_PromoCode_Document](
	[PromoCode] [nvarchar](50) NOT NULL,
	[PrintDocumentId] [int] NOT NULL,
 CONSTRAINT [PK_Link_PromoCode_Document] PRIMARY KEY CLUSTERED 
(
	[PromoCode] ASC,
	[PrintDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_PromoCode_Document]  WITH CHECK ADD  CONSTRAINT [FK_Link_PromoCode_Document_LookupPrintDocument] FOREIGN KEY([PrintDocumentId])
REFERENCES [dbo].[LookupPrintDocument] ([ID])
ALTER TABLE [dbo].[Link_PromoCode_Document] CHECK CONSTRAINT [FK_Link_PromoCode_Document_LookupPrintDocument]