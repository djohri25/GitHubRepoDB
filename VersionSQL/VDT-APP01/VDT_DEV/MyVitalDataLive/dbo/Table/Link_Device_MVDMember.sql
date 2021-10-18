/****** Object:  Table [dbo].[Link_Device_MVDMember]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_Device_MVDMember](
	[ID] [int] NOT NULL,
	[DeviceID] [varchar](50) NULL,
	[MVDID] [varchar](20) NULL,
	[Created] [datetime] NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[HPMemberID] [varchar](20) NULL,
	[SecureQu2] [varchar](50) NULL,
	[SecureAn2] [varchar](50) NULL
) ON [PRIMARY]