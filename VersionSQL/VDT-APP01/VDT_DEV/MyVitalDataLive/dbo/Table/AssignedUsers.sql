/****** Object:  Table [dbo].[AssignedUsers]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AssignedUsers](
	[AssignedBy] [varchar](100) NULL,
	[UserName] [varchar](100) NULL,
	[FirstName] [varchar](100) NULL,
	[LastName] [varchar](100) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[MVDID] [varchar](30) NULL,
	[CustID] [int] NULL,
	[OwnerType] [varchar](50) NULL,
	[IsDeactivated] [bit] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]