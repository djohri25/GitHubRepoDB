/****** Object:  Table [dbo].[TaskAlert]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TaskAlert](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[CustID] [int] NULL,
	[CodeID] [int] NULL,
	[CodeTypeID] [int] NULL,
	[Label] [varchar](100) NULL,
	[LabelDesc] [varchar](100) NULL,
	[ProductID] [int] NULL,
	[CreatedDT] [datetime] NULL,
	[CreatedBy] [varchar](100) NULL
) ON [PRIMARY]