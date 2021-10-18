/****** Object:  Table [dbo].[LookupImmunization]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupImmunization](
	[ImmunId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ImmunName] [varchar](50) NULL,
 CONSTRAINT [PK_LookupImmunization] PRIMARY KEY CLUSTERED 
(
	[ImmunId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]