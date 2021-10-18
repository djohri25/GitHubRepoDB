/****** Object:  Table [dbo].[MainSocialHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainSocialHistory](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NOT NULL,
	[Smoking] [varchar](5) NULL,
	[SmokingNow] [bit] NULL,
	[SmokingQuit] [bit] NULL,
	[SmokingWhen] [varchar](50) NULL,
	[SmokingYear] [float] NULL,
	[SmokingHowMuch] [float] NULL,
	[SmokingOtherForm] [bit] NULL,
	[SmokingNote] [varchar](50) NULL,
	[Alcohol] [varchar](5) NULL,
	[AlcoholHowMuch] [varchar](50) NULL,
	[AlcoholHowOften] [varchar](50) NULL,
	[Drug] [varchar](5) NULL,
	[DrugWhat] [varchar](50) NULL,
	[SunExposure] [varchar](5) NULL,
	[Exercise] [varchar](5) NULL,
	[ExerciseType] [varchar](50) NULL,
	[ExerciseOften] [varchar](50) NULL,
	[Restriction] [varchar](5) NULL,
	[RestrictionHow] [varchar](50) NULL,
	[Emotional] [varchar](5) NULL,
	[EmotionalHow] [varchar](50) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_MainSocialHistory] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainSocialHistory] ON [dbo].[MainSocialHistory]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MainSocialHistory]  WITH CHECK ADD  CONSTRAINT [FK_MainSocialHistory_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[MainSocialHistory] CHECK CONSTRAINT [FK_MainSocialHistory_MainPersonalDetails]