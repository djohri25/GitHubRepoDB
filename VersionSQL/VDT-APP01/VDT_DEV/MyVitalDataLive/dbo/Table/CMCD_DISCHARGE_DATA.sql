/****** Object:  Table [dbo].[CMCD_DISCHARGE_DATA]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CMCD_DISCHARGE_DATA](
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
	[Type] [varchar](50) NULL
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[ArchiveEntry]
   ON [dbo].[CMCD_DISCHARGE_DATA]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	declare @mrn varchar(50),@csn  varchar(50), @admitdate datetime,
		@medicare varchar(50), @pcp varchar(50)

	select @mrn = mrn,
		@csn = CSN,
		@admitdate = ADMIT_DATE,
		@medicare = MEDICAIDE_NUMBER,
		@pcp = PCP
	from inserted
	
	if not exists(select guid from DISCHARGE_DATA_History
		where MRN = @mrn and csn = @CSN and ADMIT_DATE = @admitdate
			and MEDICAIDE_NUMBER = @medicare and PCP = @pcp)
	begin
		insert into DISCHARGE_DATA_History
			(GUID ,MRN,CSN,PATIENT_NAME,DOB,ADMIT_DATE,CLASS
			,MEDICAIDE_NUMBER,VISIT_REASON,PCP,DISCHARGE_DISPOSITION
			,PATIENTS_HOME_NUMBER, Type)
		select GUID ,MRN,CSN,PATIENT_NAME,DOB,ADMIT_DATE,CLASS
			,MEDICAIDE_NUMBER,VISIT_REASON,PCP,DISCHARGE_DISPOSITION
			,PATIENTS_HOME_NUMBER, Type
		from inserted
	end
END

ALTER TABLE [dbo].[CMCD_DISCHARGE_DATA] ENABLE TRIGGER [ArchiveEntry]