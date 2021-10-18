/****** Object:  Table [dbo].[MyChildrenFacility]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MyChildrenFacility](
	[Prov Code] [nvarchar](255) NULL,
	[Spec] [nvarchar](255) NULL,
	[Sex] [nvarchar](255) NULL,
	[DOB] [nvarchar](255) NULL,
	[Last Nm] [nvarchar](255) NULL,
	[First Nm] [nvarchar](255) NULL,
	[Prof Desig] [nvarchar](255) NULL,
	[NPI ID] [nvarchar](255) NOT NULL,
	[CMC ID] [nvarchar](255) NULL,
	[Prac] [nvarchar](255) NULL,
	[Hosp?] [nvarchar](255) NULL,
	[Spec Nm] [nvarchar](255) NULL,
	[Prf Des Nm] [nvarchar](255) NULL,
	[Account Name] [varchar](50) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_MyChildrenFacility_1] PRIMARY KEY CLUSTERED 
(
	[NPI ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MyChildrenFacility] ADD  CONSTRAINT [DF_MyChildrenFacility_Created]  DEFAULT (getutcdate()) FOR [Created]