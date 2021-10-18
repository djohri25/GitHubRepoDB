/****** Object:  Table [dbo].[Role]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Role](
	[RoleID] [uniqueidentifier] NOT NULL,
	[InternalID] [int] IDENTITY(1,1) NOT NULL,
	[CustID] [int] NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[Created] [datetime] NOT NULL,
	[CreatedBy] [varchar](50) NULL,
	[Updated] [datetime] NOT NULL,
	[UpdatedBy] [varchar](50) NULL,
	[IsActive] [bit] NOT NULL,
	[CarePlanType] [nvarchar](50) NULL
) ON [PRIMARY]