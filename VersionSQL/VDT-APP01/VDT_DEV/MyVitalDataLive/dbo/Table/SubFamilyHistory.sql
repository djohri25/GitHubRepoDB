/****** Object:  Table [dbo].[SubFamilyHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SubFamilyHistory](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
	[FatherAge] [int] NULL,
	[MotherAge] [int] NULL,
	[Anesthesia] [bit] NULL,
	[Note] [varchar](250) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[FatherAlive] [bit] NULL,
	[MotherAlive] [bit] NULL,
	[MonthFather] [varchar](3) NULL,
	[MonthMother] [varchar](3) NULL,
	[YearFatherDeceased] [int] NULL,
	[YearMotherDeceased] [int] NULL,
	[MonthFatherDeceased] [varchar](3) NULL,
	[MonthMotherDeceased] [varchar](3) NULL,
 CONSTRAINT [PK_SubFamilyHistory] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[SubFamilyHistory]  WITH CHECK ADD  CONSTRAINT [SubFamilyHistory_PersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[SubFamilyHistory] CHECK CONSTRAINT [SubFamilyHistory_PersonalDetails]