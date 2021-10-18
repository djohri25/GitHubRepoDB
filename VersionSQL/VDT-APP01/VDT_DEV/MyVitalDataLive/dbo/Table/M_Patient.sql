/****** Object:  Table [dbo].[M_Patient]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[M_Patient](
	[PatientID] [int] NOT NULL,
	[FullName] [nvarchar](50) NOT NULL,
	[FirstName] [nvarchar](25) NOT NULL,
	[LastName] [nvarchar](25) NOT NULL,
	[Gender] [nchar](1) NOT NULL,
	[BloodType] [nchar](3) NOT NULL,
	[DOB] [datetime] NOT NULL,
	[OrganDonor] [bit] NOT NULL,
	[HeightInches] [tinyint] NOT NULL,
	[WeightLbs] [smallint] NOT NULL,
	[SSN] [nchar](9) NOT NULL,
	[MaritalStatusID] [int] NOT NULL,
	[Occupation] [nvarchar](50) NOT NULL,
	[OccupationalStatusID] [int] NOT NULL,
 CONSTRAINT [PK_Patient] PRIMARY KEY CLUSTERED 
(
	[PatientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]