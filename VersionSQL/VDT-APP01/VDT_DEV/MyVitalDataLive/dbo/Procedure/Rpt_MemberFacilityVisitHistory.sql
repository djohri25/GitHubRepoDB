/****** Object:  Procedure [dbo].[Rpt_MemberFacilityVisitHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Rpt_MemberFacilityVisitHistory]
	@ICENUMBER VARCHAR (15), @StartID INT=null
AS
SET NOCOUNT ON

create table #tempFacility (ID int IDENTITY(1,1) NOT NULL, 
	facName varchar(50), lastvisitdate datetime, 
	hospAdmit bit, visitCount int, isProcessed bit default(0),
	chiefComplaint varchar(100), emsnote varchar(1000), POS varchar(50))

declare @tempFac varchar(50), @tempLastVisit datetime, @tempHospAdmit bit, 
	@chiefComplaint varchar(100), @emsnote varchar(1000),
	@tempSource varchar(50), @tempSourceID int, @tempPOS varchar(50), @tempPOSText varchar(50)

if( @StartID is not null and @startID > 0)
begin
	SET IDENTITY_INSERT #tempFacility ON
	INSERT INTO #tempFacility (ID) -- This is your primary key field
	VALUES (@StartID - 1)
	SET IDENTITY_INSERT #tempFacility OFF
	DELETE FROM #tempFacility
end

insert into #tempFacility (facName, visitCount)
SELECT  facilityname, count(v.id)
FROM EdVisitHistory v
WHERE ICENUMBER = @ICENUMBER 
	and len(isnull(v.facilityname,'')) > 0
	and visitdate > dateadd(mm,-6,getdate())		-- Last 6 months
group by v.facilityname

while exists(select facname from #tempFacility where isProcessed = 0)
begin
	select top 1 @tempFac = facname from #tempFacility where isProcessed = 0

	select @tempLastVisit = null, 
		@tempHospAdmit = null,
		@chiefcomplaint = null, 
		@emsnote = null,
		@tempPOS = null,
		@tempPOSText = null

	-- Retrieve the most recent visit date in that facility
	SELECT  top 1 @tempLastVisit = 
			case when source = 'EMS - Lookup' then dbo.ConvertUTCtoEST(v.visitdate)
			else visitdate end, 
		@tempHospAdmit = isHospitalAdmit,
		@tempSource = source,
		@tempSourceID = sourceRecordId,
		@tempPOS = POS
	FROM EdVisitHistory v
	WHERE ICENUMBER = @ICENUMBER 
		and v.facilityname = @tempFac
		and len(isnull(v.facilityname,'')) > 0
		and visitdate > dateadd(mm,-6,getdate())		-- Last 6 months
	order by v.visitdate desc	

	-- If visit record created as a result of lookup, retrieve chief complaint and ems notes
	if(@tempSource = 'EMS - Lookup')
	begin
		select 
			@chiefComplaint = chiefcomplaint,
			@emsnote = emsnote
		from  MVD_AppRecord
		where RecordID = @tempSourceID
	end
	
	if(isnull(@tempPOS,'') <> '')
	begin
		select @tempPOSText = Name
		from LookupPOS
		where ID = @tempPOS
	end

	update #tempFacility set lastVisitDate = @tempLastVisit,
		hospAdmit = @tempHospAdmit,
		chiefComplaint = @chiefComplaint,
		emsnote = @emsnote,
		POS = @tempPOSText,
		isProcessed = 1 
	where facName = @tempFac
end

select ID, facName as FacilityName, lastvisitdate as VisitDate, 
	CASE hospAdmit
	 when '0' then 'N'
	 when '1' then 'Y'
	END as IsHospAdmit, visitCount as [Count],
	chiefComplaint, emsnote as Notes , POS
from #tempFacility
order by lastVisitDate desc

drop table #tempFacility