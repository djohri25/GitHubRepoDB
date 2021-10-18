/****** Object:  Table [dbo].[MainToDoHEDISHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainToDoHEDISHistory](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[MemberID] [varchar](20) NOT NULL,
	[Major] [nvarchar](100) NOT NULL,
	[Minor] [nvarchar](100) NOT NULL,
	[Action] [char](1) NOT NULL,
	[Date] [smalldatetime] NOT NULL,
 CONSTRAINT [PK_MainToDoHEDISHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]