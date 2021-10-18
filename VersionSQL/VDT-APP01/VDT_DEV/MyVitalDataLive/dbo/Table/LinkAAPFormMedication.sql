/****** Object:  Table [dbo].[LinkAAPFormMedication]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LinkAAPFormMedication](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FormID] [int] NULL,
	[MedicationID] [int] NULL,
	[HowMuch] [varchar](50) NULL,
	[HowOften] [varchar](50) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_LinkAAPFormMedication] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[LinkAAPFormMedication] ADD  CONSTRAINT [DF_LinkAAPFormMedication_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[LinkAAPFormMedication]  WITH CHECK ADD  CONSTRAINT [FK_LinkAAPFormMedication_LookupAsthmaMedByZone] FOREIGN KEY([MedicationID])
REFERENCES [dbo].[LookupAsthmaMedByZone] ([ID])
ALTER TABLE [dbo].[LinkAAPFormMedication] CHECK CONSTRAINT [FK_LinkAAPFormMedication_LookupAsthmaMedByZone]