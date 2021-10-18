/****** Object:  Table [dbo].[MD_Alert]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MD_Alert](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[MVDID] [varchar](50) NULL,
	[DoctorID] [varchar](20) NULL,
	[AlertDate] [datetime] NULL,
	[Facility] [nvarchar](50) NULL,
	[Text] [nvarchar](1000) NULL,
	[StatusID] [int] NULL,
	[RecordAccessID] [int] NULL,
	[ChiefComplaint] [varchar](100) NULL,
	[EMSNote] [varchar](1000) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_MD_Alert] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MD_Alert] ADD  CONSTRAINT [DF_MD_Alert_Created]  DEFAULT (getutcdate()) FOR [Created]