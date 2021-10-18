/****** Object:  Table [dbo].[LookupSecurityQuestion]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupSecurityQuestion](
	[QuestionId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Question] [varchar](100) NOT NULL,
	[QuestionSpanish] [varchar](100) NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_LookupSecurityQuestion] PRIMARY KEY CLUSTERED 
(
	[QuestionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_LookupSecurityQuestion] ON [dbo].[LookupSecurityQuestion]
(
	[Question] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[LookupSecurityQuestion] ADD  CONSTRAINT [DF_LookupSecurityQuestion_Active]  DEFAULT ((1)) FOR [Active]