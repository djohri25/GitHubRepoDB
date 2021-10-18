/****** Object:  Table [dbo].[AccessTickets]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AccessTickets](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](20) NOT NULL,
	[TicketNumber] [uniqueidentifier] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateUsed] [datetime] NULL,
 CONSTRAINT [PK_AccessTickets] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY],
 CONSTRAINT [IX_AccessTickets] UNIQUE NONCLUSTERED 
(
	[TicketNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[AccessTickets] ADD  CONSTRAINT [DF_AccessTickets_GUID]  DEFAULT (newid()) FOR [TicketNumber]
ALTER TABLE [dbo].[AccessTickets] ADD  CONSTRAINT [DF_AccessTickets_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]