/****** Object:  Procedure [dbo].[Populate_ERUtilizerReportData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/11/2015
-- Description:	Prepopulates data for ERUtilizerReport
-- Example:		EXEC dbo.Populate_ERUtilizerReportData
-- Changes:		04/28/2017	Marc De Luca	Added an intermediary temp table
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================
CREATE PROCEDURE [dbo].[Populate_ERUtilizerReportData]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @DateRange int

	select @DateRange = 90

	declare @tempRange datetime, @VisitCountDateRange datetime
	select @tempRange = '01/01/1950',
		@VisitCountDateRange = dateadd(mm,-6,getdate())

	if(@DateRange is not null AND @DateRange <> 0)
	begin
		select @tempRange = DATEADD(DD,-@DateRange,GETDATE())
	end

	-- Note: cannot use MDMemberVisit because it's populate only with visits where Source not like '%claim%'
	-- Populate qualifying members
	
	truncate table dbo.ERUtilizerReportData

	insert into dbo.ERUtilizerReportData(Name, DOB, MVDID, InsMemberID, CustID, PCP_NPI, NPIName, ERVisitCount)
	select distinct
		isnull(p.firstname,'') + isnull(' ' + p.lastname,'') as Name, 
		p.DOB,
		li.MVDID,
		li.InsMemberID,
		li.cust_ID,
		(select top 1 s.NPI from dbo.MainSpecialist  s where s.ICENUMBER = p.ICENUMBER and RoleID =1 order by s.ModifyDate desc) as PCP_NPI,
		(select top 1 isnull(s.FirstName + ' ','') + isnull(s.LastName,'')  from dbo.MainSpecialist  s where s.ICENUMBER = p.ICENUMBER and RoleID =1 order by s.ModifyDate desc) as NPIName,
		(select COUNT(id) from dbo.EDVisitHistory e where e.ICENUMBER = v.ICENUMBER and e.VisitType = 'ER' and e.visitdate > @VisitCountDateRange) as ERVisitCount			
	from 
		dbo.Link_MemberId_MVD_Ins li
		inner join dbo.EDVisitHistory v on li.MVDId = v.ICENUMBER
		inner join dbo.MainPersonalDetails p on v.ICENUMBER = p.ICENUMBER			
	where 
		VisitType = 'ER' 
		and li.Active = 1	
		and li.IsPrimary = 1
		and v.VisitDate > @tempRange
		AND MVDID in(
			select s.ICENUMBER
			from dbo.MDUser u
				inner join dbo.Link_MDAccountGroup ag on u.ID = ag.MDAccountID
				inner join dbo.MDGroup g on ag.MDGroupID = g.ID
				inner join dbo.Link_MDGroupNPI n on g.ID = n.MDGroupID
				inner join dbo.MainSpecialist s on n.NPI = s.NPI
			where s.RoleID = 1
			)
	order by ERVisitCount desc

	-- Get last ER visit info
	update dbo.ERUtilizerReportData
	set lastERVisitID = t.visitID
	from dbo.ERUtilizerReportData r inner join
	(
		select
		(
			select top 1 e.ID
			from dbo.EDVisitHistory e
			where e.VisitType = 'ER' and e.ICENUMBER = s.MVDID
			order by e.VisitDate desc
		) as visitID, *
		from dbo.ERUtilizerReportData s

	) t on r.mvdid = t.mvdid

	update dbo.ERUtilizerReportData
	set VisitDate = e.VisitDate, Facility = e.FacilityName, ChiefComplaint = e.ChiefComplaint, LastERVisitFacilityNPI = FacilityNPI
	from dbo.ERUtilizerReportData s
		inner join dbo.EDVisitHistory e on s.LastERVisitID = e.ID

	-- Get Primary and Secondary Diagnosis
	IF OBJECT_ID('tempdb..#X') IS NOT NULL DROP TABLE #X;
	SELECT ICENUMBER, Code, IsPrincipal, UpdatedByNPI, ReportDate
	INTO #X
	FROM dbo.MainCondition e
	WHERE EXISTS
	(
		SELECT 1
		FROM dbo.ERUtilizerReportData s
		WHERE s.MVDID = e.ICENUMBER
		AND ISNULL(s.LastERVisitFacilityNPI,'') <> ''
	)

	CREATE INDEX IX_ALL ON #X (ICENUMBER, IsPrincipal, UpdatedByNPI, ReportDate)

	update dbo.ERUtilizerReportData
	set PrimaryDiagnosis = t.PrimaryDiagnosis,
		SecondaryDiagnosis = t.SecondaryDiagnosis
	from dbo.ERUtilizerReportData r inner join
	(
		select s.mvdid,
			(
				select top (1) Code
				from #X e
				where e.ICENUMBER = s.MVDID
					and e.IsPrincipal = 1
					and e.UpdatedByNPI = s.LastERVisitFacilityNPI
					and convert(date,e.ReportDate) = s.VisitDate
			) as PrimaryDiagnosis, 
			(
				select top (1) Code
				from #X e
				where e.ICENUMBER = s.MVDID
					and e.IsPrincipal <> 1
					and e.UpdatedByNPI = s.LastERVisitFacilityNPI
					and convert(date,e.ReportDate) = s.VisitDate
			) as SecondaryDiagnosis
		from ERUtilizerReportData s
		where isnull(s.LastERVisitFacilityNPI,'') <> ''
	) t on r.mvdid = t.mvdid

END