/****** Object:  Table [dbo].[MessageNote]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MessageNote](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[NoteTypeId] [int] NOT NULL,
	[LinkedNoteType] [varchar](50) NOT NULL,
	[LinkedNoteId] [bigint] NOT NULL,
	[Note] [varchar](max) NOT NULL,
	[CreatedBy] [varchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [varchar](50) NULL,
	[UpdatedDate] [datetime] NULL,
	[IsDeleted] [bit] NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]