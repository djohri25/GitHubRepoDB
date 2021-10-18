/****** Object:  Table [dbo].[DI_Driver]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DI_Driver](
	[RecordNumber] [int] NOT NULL,
	[Processed] [int] NOT NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[DI_Driver] ADD  CONSTRAINT [DF_DI_Driver_Processed]  DEFAULT ((0)) FOR [Processed]