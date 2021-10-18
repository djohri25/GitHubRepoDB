/****** Object:  Table [dbo].[MainMedRec]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainMedRec](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustID] [int] NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[ReconDateTime] [datetime] NOT NULL,
	[NDC] [varchar](20) NOT NULL,
	[RxStartDate] [date] NOT NULL,
	[ReconStatus] [smallint] NOT NULL,
	[CreatedBy] [varchar](250) NOT NULL,
	[SessionID] [varchar](40) NOT NULL,
	[Quantity] [varchar](50) NULL,
	[DaysSupply] [varchar](50) NULL,
 CONSTRAINT [PK_MainMedRec] PRIMARY KEY CLUSTERED 
(
	[CustID] ASC,
	[MVDID] ASC,
	[NDC] ASC,
	[RxStartDate] ASC,
	[SessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_MainMedRec_ReconDateTime] ON [dbo].[MainMedRec]
(
	[ReconDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MainMedRec] ADD  CONSTRAINT [DF_MainMedRec_ReconStatus]  DEFAULT ((0)) FOR [ReconStatus]