/****** Object:  Table [dbo].[TempTestDueMember]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TempTestDueMember](
	[MVDID] [varchar](20) NOT NULL,
	[DOB] [datetime] NULL,
	[InsMemberID] [varchar](20) NULL,
	[controllerMedicationUnitCount] [int] NULL,
	[relieverMedicationsUnitCount] [int] NULL,
 CONSTRAINT [PK_TempTestDueMember] PRIMARY KEY CLUSTERED 
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]