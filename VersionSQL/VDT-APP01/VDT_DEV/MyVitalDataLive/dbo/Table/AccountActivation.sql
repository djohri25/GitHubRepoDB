/****** Object:  Table [dbo].[AccountActivation]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AccountActivation](
	[PrimaryKey] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[Type] [char](1) NOT NULL,
	[Delta] [smallint] NOT NULL,
	[Years] [smallint] NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[OrderTransactionID] [varchar](50) NULL,
 CONSTRAINT [PK_AccountActivation] PRIMARY KEY CLUSTERED 
(
	[PrimaryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[AccountActivation] ADD  CONSTRAINT [DF_AccountActivation_Years]  DEFAULT ((0)) FOR [Years]