/****** Object:  Table [dbo].[LookupAllergies]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupAllergies](
	[AllergenTypeId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AllergenTypeName] [varchar](25) NOT NULL,
	[AllergenTypeNameSpanish] [nvarchar](100) NULL,
 CONSTRAINT [PK_LookupAllergies] PRIMARY KEY CLUSTERED 
(
	[AllergenTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]