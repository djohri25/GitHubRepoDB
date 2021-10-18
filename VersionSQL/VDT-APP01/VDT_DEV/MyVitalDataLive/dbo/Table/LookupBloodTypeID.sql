/****** Object:  Table [dbo].[LookupBloodTypeID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupBloodTypeID](
	[BloodTypeID] [int] IDENTITY(0,1) NOT FOR REPLICATION NOT NULL,
	[BloodTypeName] [varchar](15) NULL,
	[BloodTypeNameSpanish] [nvarchar](100) NULL,
 CONSTRAINT [PK_BloodType] PRIMARY KEY CLUSTERED 
(
	[BloodTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]