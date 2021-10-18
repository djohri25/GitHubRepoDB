/****** Object:  Table [dbo].[CMCD_DuplicateMembers]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CMCD_DuplicateMembers](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](50) NULL,
	[Medicaid] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[FirstName] [varchar](50) NULL,
	[DOB] [date] NULL,
	[GenderID] [int] NULL,
	[SSN] [varchar](50) NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[Zip] [varchar](50) NULL,
	[RecordCreated] [datetime] NULL,
	[System_MemID] [varchar](50) NULL,
	[Cust_ID] [int] NULL,
	[EffectiveDate] [datetime] NULL,
	[TerminationDate] [datetime] NULL,
	[IsProcessed] [bit] NULL,
	[IsExcluded] [bit] NULL,
 CONSTRAINT [PK_CMCD_DuplicateMembers] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_CMCD_DuplicateMembers] ON [dbo].[CMCD_DuplicateMembers]
(
	[IsProcessed] ASC,
	[IsExcluded] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[CMCD_DuplicateMembers] ADD  CONSTRAINT [DF_CMCD_DuplicateMembers_IsProcessed]  DEFAULT ((0)) FOR [IsProcessed]
ALTER TABLE [dbo].[CMCD_DuplicateMembers] ADD  CONSTRAINT [DF_CMCD_DuplicateMembers_IsExcluded]  DEFAULT ((0)) FOR [IsExcluded]