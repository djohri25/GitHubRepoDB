/****** Object:  Table [dbo].[NPIDeIdentify]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[NPIDeIdentify](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OriginalNPI] [varchar](25) NULL,
	[NewNPI] [varchar](25) NULL,
	[OriginalFirstName] [varchar](25) NULL,
	[OriginalLastName] [varchar](25) NULL,
	[NewFirstName] [varchar](25) NULL,
	[NewLastName] [varchar](25) NULL,
 CONSTRAINT [PK_DeIdentifyKey_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_NCI_NPIDeIdentify_ORGNPI] ON [dbo].[NPIDeIdentify]
(
	[OriginalNPI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]