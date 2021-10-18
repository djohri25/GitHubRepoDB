/****** Object:  Table [dbo].[MainCCD]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainCCD](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NOT NULL,
	[Data] [varbinary](max) NOT NULL,
	[HVID] [char](36) NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[ModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MainCCD] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[MainCCD]  WITH CHECK ADD  CONSTRAINT [FK_MainCCD_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[MainCCD] CHECK CONSTRAINT [FK_MainCCD_MainPersonalDetails]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TRIGGER [dbo].[Trigger_MainCCD_Delete]
ON [dbo].[MainCCD] 
FOR DELETE
AS
BEGIN
	DELETE FROM MainAllergies
	WHERE     (HVFlag = 1) AND (HVID IN
	                          (SELECT	HVID
	                            FROM	DELETED))
	DELETE FROM MainCondition
	WHERE     (HVFlag = 1) AND (HVID IN
	                          (SELECT	HVID
	                            FROM	DELETED))
	DELETE FROM MainImmunization
	WHERE     (HVFlag = 1) AND (HVID IN
	                          (SELECT	HVID
	                            FROM	DELETED))
	DELETE FROM MainInsurance
	WHERE     (HVFlag = 1) AND (HVID IN
	                          (SELECT	HVID
	                            FROM	DELETED))
	DELETE FROM MainMedication
	WHERE     (HVFlag = 1) AND (HVID IN
	                          (SELECT	HVID
	                            FROM	DELETED))
	DELETE FROM MainSurgeries
	WHERE     (HVFlag = 1) AND (HVID IN
	                          (SELECT	HVID
	                            FROM	DELETED))

END

ALTER TABLE [dbo].[MainCCD] DISABLE TRIGGER [Trigger_MainCCD_Delete]