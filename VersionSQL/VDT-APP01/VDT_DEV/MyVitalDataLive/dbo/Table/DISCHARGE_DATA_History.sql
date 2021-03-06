/****** Object:  Table [dbo].[DISCHARGE_DATA_History]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DISCHARGE_DATA_History](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[GUID] [varchar](50) NULL,
	[MRN] [varchar](50) NULL,
	[CSN] [varchar](50) NULL,
	[PATIENT_NAME] [varchar](50) NULL,
	[DOB] [date] NULL,
	[ADMIT_DATE] [datetime] NULL,
	[CLASS] [varchar](50) NULL,
	[MEDICAIDE_NUMBER] [varchar](50) NULL,
	[VISIT_REASON] [varchar](100) NULL,
	[PCP] [varchar](50) NULL,
	[DISCHARGE_DISPOSITION] [varchar](100) NULL,
	[PATIENTS_HOME_NUMBER] [varchar](50) NULL,
	[Created] [datetime] NULL,
	[IsProcessed] [bit] NULL,
	[ProcessDate] [datetime] NULL,
	[ProcessNote] [varchar](50) NULL,
	[ProcessAttemptCount] [int] NULL,
	[Type] [varchar](50) NULL,
	[PatientPhone] [varchar](50) NULL,
	[Gender] [varchar](50) NULL,
	[Disposition] [varchar](100) NULL,
	[AdmitPlace] [varchar](100) NULL,
	[HealthPlan] [varchar](50) NULL,
	[Source] [varchar](50) NULL,
 CONSTRAINT [PK_DISCHARGE_DATA_History] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_DISCHARGE_DATA_History] ON [dbo].[DISCHARGE_DATA_History]
(
	[MEDICAIDE_NUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_DISCHARGE_DATA_History_IsProcessed] ON [dbo].[DISCHARGE_DATA_History]
(
	[IsProcessed] ASC
)
INCLUDE([ID],[ADMIT_DATE],[MEDICAIDE_NUMBER]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[DISCHARGE_DATA_History] ADD  CONSTRAINT [DF_DISCHARGE_DATA_History_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[DISCHARGE_DATA_History] ADD  CONSTRAINT [DF__DISCHARGE__IsPro__3632CAAD]  DEFAULT ((0)) FOR [IsProcessed]
ALTER TABLE [dbo].[DISCHARGE_DATA_History] ADD  CONSTRAINT [DF__DISCHARGE__Proce__3BEBA403]  DEFAULT ((0)) FOR [ProcessAttemptCount]