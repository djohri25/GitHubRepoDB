/****** Object:  Procedure [dbo].[Rpt_MemberERVisits]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Rpt_MemberERVisits]
	@ICENUMBER varchar(15)
AS
BEGIN
--set @ICENUMBER = 'GQ250569'
SET NOCOUNT ON

--set @ICENUMBER = 'MB058863'
Declare @TimeZone	VARCHAR(4)
Declare @ICEGroup varchar(50)
Select @ICEGroup = IceGroup from [dbo].[MainICENUMBERGroups]
where IceNumber = @ICENUMBER


Create Table #IceNumbers (IceNumber varchar(50))
Insert #IceNumbers
Select IceNumber from [dbo].[MainICENUMBERGroups]
where IceGroup = @ICEGroup

	declare @VisitCountDateRange datetime, @ERVisitCount int, @LastVisitDate datetime, @FacilityName varchar(100)

	select @VisitCountDateRange = dateadd(mm,-6,getdate())
	
	--Get ER Count	
	select @ERVisitCount = COUNT(id) 
	from EDVisitHistory e 
	where --e.ICENUMBER = @ICENUMBER 
	e.ICENUMBER in (Select IceNUmber From #IceNumbers) 
	and e.VisitType = 'ER' and e.visitdate > @VisitCountDateRange

	--Get Latest Facility Name
	Select Top 1
	@FacilityName = FacilityName
	from EDVisitHistory e 
	where --e.ICENUMBER = @ICENUMBER 
	e.ICENUMBER in (Select IceNUmber From #IceNumbers) 	
	and e.VisitType = 'ER' and e.visitdate > @VisitCountDateRange
	order by VisitDate desc

	-- Get TimeZone
	Select top 1 @TimeZone = CASE WHEN h.[STATE] in ('CT','DE','GA','ME','MD','MA','NH','NJ','NY','NC','SC','OH','PA','RI','VT','VA','WV','FL','MI','AL', 'DC','IN','KY') THEN 'EST'
								  WHEN h.[STATE] in ('ND','SD','AR','IL','IA','LA','MN','MS','MO','OK','WI','KS','MI','NE','TN','TX', 'AL') THEN 'CST'
								  WHEN h.[STATE] in ('NM','WY','UT','CO','ID','AZ','MT') THEN 'MST'
								  WHEN h.[STATE] in ('WA','OR','CA','NV') THEN 'PST' END 
	FROM EDVisitHistory e  JOIN MainEMSHospital h on e.facilityname = h.Name
	Where e.ICENUMBER in (Select IceNUmber From #IceNumbers) 	
	and e.VisitType = 'ER' and e.visitdate > @VisitCountDateRange and e.FacilityName = @FacilityName

	-- Get Latest Visit Date
	select top 1 
	@LastVisitDate = CASE WHEN @TimeZone = 'EST' THEN  dbo.ConvertUTCtoEST(VisitDate)
									   WHEN @TimeZone = 'CST' THEN  dbo.ConvertUTCtoCT(VisitDate)
									   WHEN @TimeZone = 'MST' THEN  dbo.ConvertUTCtoMT(VisitDate)
									   WHEN @TimeZone = 'PST' THEN  dbo.ConvertUTCtoPT(VisitDate)
									   ELSE VisitDate END
	from EDVisitHistory e 
	where --e.ICENUMBER = @ICENUMBER 
	e.ICENUMBER in (Select IceNUmber From #IceNumbers) 	
	and e.VisitType = 'ER' and e.visitdate > @VisitCountDateRange
	order by VisitDate desc

-- Output result
select @ERVisitCount as ERVisitCount, CONVERT(varchar,@LastVisitDate,101) as LastVisitDate, @FacilityName as FacilityName	

drop table #IceNumbers
END