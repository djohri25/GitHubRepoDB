/****** Object:  Procedure [dbo].[Rpt_MemberPhysicianVisitHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Rpt_MemberPhysicianVisitHistory]
	@ICENUMBER VARCHAR (15), @StartID INT=null
AS
SET NOCOUNT ON

create table #tempPhysician ( ID int IDENTITY(1,1) NOT NULL, 
	fName varchar(50), lname varchar(50), phone varchar(20), lastvisitdate datetime, 
	hospAdmit bit, visitCount int, isProcessed bit default(0),
	chiefComplaint varchar(100), emsnote varchar(1000),
	Specialty varchar(50), POS varchar(50))

declare @tempFname varchar(50),@tempLname varchar(50),@tempPhone varchar(50), @tempLastVisit datetime, @tempHospAdmit bit, 
	@chiefComplaint varchar(100), @emsnote varchar(1000),
	@tempSource varchar(50), @tempSourceID int,
	@tempSpecialty varchar(50), @tempPOS varchar(50), @tempPOSText varchar(50)

if( @StartID is not null and @startID > 0)
begin
	SET IDENTITY_INSERT #tempPhysician ON
	INSERT INTO #tempPhysician (ID) -- This is your primary key field
	VALUES (@StartID - 1)
	SET IDENTITY_INSERT #tempPhysician OFF
	DELETE FROM #tempPhysician
end

insert into #tempPhysician (fName, lName, phone, Specialty, visitCount)
SELECT  isnull(physicianFirstName,''), isnull(physicianLastName,''), isnull(physicianPhone,''), c.Specialty, count(v.id)
FROM EdVisitHistory v
	left join lookupnpi_custom c on v.facilityNPI = c.NPI
WHERE ICENUMBER = @ICENUMBER 
	and len(isnull(v.facilityname,'')) = 0
	and visitdate > dateadd(mm,-6,getdate())		-- Last 6 months
group by physicianFirstName, physicianLastName, physicianPhone, c.Specialty

while exists(select fname from #tempPhysician where isProcessed = 0)
begin
	select top 1 @tempFName = fname,
		@tempLName = lname,
		@tempPhone = phone 
	from #tempPhysician 
	where isProcessed = 0

	select @tempLastVisit = null, 
		@tempHospAdmit = null,
		@chiefcomplaint = null, 
		@emsnote = null,
		@tempPOS = null,
		@tempPOSText = null

	-- Retrieve the most recent visit date with current physician
	SELECT  top 1 @tempLastVisit = 
			case when source = 'EMS - Lookup' then dbo.ConvertUTCtoEST(v.visitdate)
			else visitdate end, 
		@tempHospAdmit = isHospitalAdmit,
		@tempSource = source,
		@tempSourceID = sourceRecordId,
		@tempPOS = POS
	FROM EdVisitHistory v
	WHERE ICENUMBER = @ICENUMBER 
		and physicianFirstName = @tempfname
		and physicianlastName = @templName
		and physicianPhone = @tempPhone
		and len(isnull(v.facilityname,'')) = 0
		and visitdate > dateadd(mm,-6,getdate())		-- Last 6 months
	order by v.visitdate desc	

	select @tempPOSText = Name
	from LookupPOS
	where ID = @tempPOS

	update #tempPhysician set lastVisitDate = @tempLastVisit,
		hospAdmit = @tempHospAdmit,
		chiefComplaint = @chiefComplaint,
		emsnote = @emsnote,
		POS = @tempPOSText,
		isProcessed = 1 
	where fName = @tempFName
		and lName = @templName
		and Phone = @tempPhone
end

select ID, dbo.InitCap( isnull(fName + ' ','') + isnull(lname,'')) as Name,
	Specialty, POS,
	dbo.FormatPhone(phone) as phone, lastvisitdate as VisitDate, 
	CASE hospAdmit
	 when '0' then 'N'
	 when '1' then 'Y'
	END as IsHospAdmit, visitCount as [Count]	
from #tempPhysician
order by lastVisitDate desc

drop table #tempPhysician