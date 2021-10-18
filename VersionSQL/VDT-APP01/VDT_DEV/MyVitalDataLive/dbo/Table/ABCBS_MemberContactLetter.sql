/****** Object:  Table [dbo].[ABCBS_MemberContactLetter]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_MemberContactLetter](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[LetterMemberID] [bigint] NULL,
	[ContactFormID] [nvarchar](100) NULL,
	[CreatedDatetime] [datetime] NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ABCBS_MemberContactLetter_MVDID] ON [dbo].[ABCBS_MemberContactLetter]
(
	[LetterMemberID] ASC,
	[ContactFormID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]