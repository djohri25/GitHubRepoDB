/****** Object:  Table [dbo].[Methodist_Data]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Methodist_Data](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Facility] [varchar](50) NULL,
	[PatientName] [varchar](100) NULL,
	[AccountNumber] [varchar](50) NULL,
	[RegDate] [datetime] NULL,
	[ReasonForVisit] [varchar](50) NULL,
	[Insurance] [varchar](50) NULL,
	[PolicyNumber] [varchar](50) NULL,
 CONSTRAINT [PK_Methodist_Data] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create TRIGGER [dbo].[ArchiveMethodistEntry]
   ON  [dbo].[Methodist_Data]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	declare @facility varchar(50), @reasonForVisit varchar(200), @visitDate datetime,
		@insurance varchar(50), @policyNumber varchar(50),
		@source varchar(50)
		
	set @source = 'Methodist report'

	select 
		@facility = facility, 
		@reasonForVisit = ReasonForVisit, 
		@visitDate = RegDate,
		@insurance = Insurance, 
		@policyNumber = PolicyNumber
	from inserted
	
	if not exists(select id from dbo.DISCHARGE_DATA_History
		where admitPlace = @facility
			and VISIT_REASON = @ReasonForVisit
			and ADMIT_DATE = @visitDate
			and HealthPlan = @Insurance
			and MEDICAIDE_NUMBER = @PolicyNumber
			and source = @source)
	begin
			insert into DISCHARGE_DATA_History
				(Patient_Name,visit_reason,admit_Date,medicaide_number,HealthPlan,AdmitPlace,Source)
			select PatientName,ReasonForVisit,RegDate,PolicyNumber,Insurance,Facility,@source
			from inserted	
	end

END

ALTER TABLE [dbo].[Methodist_Data] ENABLE TRIGGER [ArchiveMethodistEntry]