/****** Object:  Table [dbo].[ChartVoid]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ChartVoid](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](50) NOT NULL,
	[ChartEntityTypeId] [int] NOT NULL,
	[ChartEntityId] [bigint] NOT NULL,
	[RequestedBy] [varchar](250) NOT NULL,
	[VoidReasonId] [int] NOT NULL,
	[CreatedBy] [varchar](250) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ChartVoid] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]