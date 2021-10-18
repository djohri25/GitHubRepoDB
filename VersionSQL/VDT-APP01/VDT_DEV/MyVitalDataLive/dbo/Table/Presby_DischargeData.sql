/****** Object:  Table [dbo].[Presby_DischargeData]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Presby_DischargeData](
	[RecordID] [int] IDENTITY(1,1) NOT NULL,
	[VisitID] [varchar](50) NULL,
	[PatientName] [varchar](50) NULL,
	[PatientPhone] [varchar](50) NULL,
	[DOB] [varchar](50) NULL,
	[Gender] [varchar](50) NULL,
	[ChiefComplaint] [varchar](100) NULL,
	[Disposition] [varchar](50) NULL,
	[VisitDate] [varchar](50) NULL,
	[MemberID] [varchar](50) NULL,
	[HealthPlan] [varchar](50) NULL,
	[AdmitPlace] [varchar](50) NULL,
	[PCP] [varchar](50) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_Presby_DischargeData] PRIMARY KEY CLUSTERED 
(
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Presby_DischargeData] ADD  CONSTRAINT [DF_Presby_DischargeData_Created]  DEFAULT (getutcdate()) FOR [Created]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[ArchivePresbyEntry]
   ON [dbo].[Presby_DischargeData]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	declare @memberID varchar(50),@chiefComplaint  varchar(200), @disposition varchar(100), @visitDate datetime,
		@healthPlan varchar(50), @admitPlace varchar(50), @pcp varchar(100),
		@source varchar(50)
		
	set @source = 'Presbyterian Hospital'

	select 
		@memberID = memberID,
		@chiefComplaint = chiefComplaint,
		@disposition = disposition,
		@visitDate = visitDate,
		@admitPlace = admitPlace,
		@pcp = PCP
	from inserted
	
	if not exists(select id from dbo.DISCHARGE_DATA_History
		where medicaide_number = @memberID and visit_reason = @chiefComplaint 
			and discharge_disposition = @disposition 
			and admit_Date = @visitDate
			and PCP = @pcp)
	begin
			insert into DISCHARGE_DATA_History
				(guid,Patient_Name,PatientPhone,DOB,Gender,visit_reason,discharge_disposition
				,admit_Date,medicaide_number,HealthPlan,AdmitPlace,PCP,Source)
			select VisitID,PatientName,PatientPhone,DOB,Gender,ChiefComplaint,Disposition
				,VisitDate,MemberID,HealthPlan,AdmitPlace,PCP,@source
			from inserted	
	end
END



ALTER TABLE [dbo].[Presby_DischargeData] ENABLE TRIGGER [ArchivePresbyEntry]