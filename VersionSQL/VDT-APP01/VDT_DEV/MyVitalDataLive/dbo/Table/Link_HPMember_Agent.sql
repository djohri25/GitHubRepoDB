/****** Object:  Table [dbo].[Link_HPMember_Agent]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPMember_Agent](
	[Member_Id] [varchar](50) NOT NULL,
	[Agent_Id] [nvarchar](50) NOT NULL,
	[Cust_Id] [int] NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_Link_HPMember_Agent] PRIMARY KEY CLUSTERED 
(
	[Member_Id] ASC,
	[Agent_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPMember_Agent] ADD  CONSTRAINT [DF_Link_HPMember_Agent_Created]  DEFAULT (getutcdate()) FOR [Created]