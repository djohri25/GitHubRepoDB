/****** Object:  Table [dbo].[Lookup_Generic_Code_Type]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Lookup_Generic_Code_Type](
	[CodeTypeID] [int] NOT NULL,
	[CodeType] [varchar](100) NOT NULL,
 CONSTRAINT [PK__Lookup_G__EA20F0FA2D5100DD] PRIMARY KEY CLUSTERED 
(
	[CodeTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]