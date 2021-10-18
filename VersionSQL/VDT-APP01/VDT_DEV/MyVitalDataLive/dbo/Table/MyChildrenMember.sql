/****** Object:  Table [dbo].[MyChildrenMember]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MyChildrenMember](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NULL,
	[InsMemberID] [varchar](20) NULL,
	[Medicaid] [varchar](20) NULL,
	[CustID] [int] NULL
) ON [PRIMARY]