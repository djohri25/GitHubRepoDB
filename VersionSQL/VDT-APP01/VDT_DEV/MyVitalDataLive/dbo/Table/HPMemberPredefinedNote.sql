/****** Object:  Table [dbo].[HPMemberPredefinedNote]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPMemberPredefinedNote](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustID] [int] NULL,
	[ShortName] [varchar](50) NULL,
	[Note] [varchar](500) NULL,
	[StatusID] [int] NULL,
	[Created] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
	[ModifiedBy] [varchar](50) NULL,
 CONSTRAINT [PK_HPMemberPredefinedNote] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[HPMemberPredefinedNote] ADD  CONSTRAINT [DF_HPMemberPredefinedNote_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[HPMemberPredefinedNote] ADD  CONSTRAINT [DF_HPMemberPredefinedNote_ModifiedDate]  DEFAULT (getutcdate()) FOR [ModifiedDate]