/****** Object:  Table [dbo].[MemberRxEducationReport]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MemberRxEducationReport](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[SessionID] [varchar](40) NOT NULL,
	[EduDT] [datetime] NOT NULL,
	[Report] [varchar](max) NOT NULL,
 CONSTRAINT [PK_MemberRxEducationReport] PRIMARY KEY CLUSTERED 
(
	[SessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]