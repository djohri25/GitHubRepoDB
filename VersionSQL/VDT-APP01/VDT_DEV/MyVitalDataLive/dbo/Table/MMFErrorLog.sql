/****** Object:  Table [dbo].[MMFErrorLog]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MMFErrorLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[FormID] [bigint] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[FieldChanged] [varchar](30) NULL,
	[CopyofFormData] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]