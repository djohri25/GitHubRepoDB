/****** Object:  Table [dbo].[MVDApplication]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MVDApplication](
	[AppID] [nvarchar](50) NOT NULL,
	[AppPWD] [nvarchar](50) NOT NULL,
	[RegistratorFN] [nvarchar](50) NULL,
	[RegistratorLN] [nvarchar](50) NULL,
	[RegistratorMAC] [nvarchar](30) NULL,
	[CompanyName] [nvarchar](50) NULL,
	[RegistrationDate] [datetime] NULL,
	[Comments] [varchar](200) NULL,
 CONSTRAINT [PK_MVDApplication] PRIMARY KEY CLUSTERED 
(
	[AppID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MVDApplication] ADD  CONSTRAINT [DF_MVDApplication_RegistrationDate]  DEFAULT (getutcdate()) FOR [RegistrationDate]