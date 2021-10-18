/****** Object:  Procedure [dbo].[GetERUtilizerReportData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:
-- Create date:
-- Description:
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================

--exec	[dbo].[GetERUtilizerReportData]
--		@DoctorID ='ALL' ,
--		@PatientMVDID ='',
--		@DateRange = 7,
--		@NPI = 'ALL',
--		@Customer = 'Parkland'

CREATE PROCEDURE [dbo].[GetERUtilizerReportData]
	@DoctorID varchar(20), 
	@PatientMVDID varchar(20),
	@DateRange int,
	@NPI varchar(100),
	@Customer varchar(100) 

AS
BEGIN
	SET NOCOUNT ON;

--select @DoctorID = '741662481' ,
--	@PatientMVDID  = '',
--	@DateRange =30,
--	@DoctorID = 'ALL',
--	@Customer = 'Parkland'

	DECLARE @CustID int

	SET @DoctorID = LTRIM(RTRIM(@DoctorID))

	declare @temp table (ID int identity(1,1), Name varchar(200), DOB date, MVDID varchar(20), InsMemberID varchar(50), VisitDate date,
		Facility varchar(100), ChiefComplaint varchar(1000), PCP_NPI varchar(50), NPIName varchar(200), ERVisitCount int, LastERVisitID int, LastERVisitFacilityNPI varchar(50),
		PrimaryDiagnosis varchar(50), SecondaryDiagnosis varchar(50))


	declare @tempRange datetime, @VisitCountDateRange datetime
	select @tempRange = '01/01/1950',
		@VisitCountDateRange = dateadd(mm,-6,getdate())

	if(@DateRange is not null AND @DateRange <> 0)
	begin
		select @tempRange = DATEADD(DD,-@DateRange,GETDATE())
	end

	--SELECT @CustID = Cust_ID FROM dbo.HPCustomer h WHERE h.Name = @Customer
	SELECT @CustID = @Customer

	if(@DoctorID = 'ALL')
	begin
		select  rank() OVER (ORDER BY ID) AS ranking, Name, DOB, MVDID, InsMemberID, VisitDate,
			Facility, ChiefComplaint, PCP_NPI, NPIName, ERVisitCount, LastERVisitFacilityNPI, 
			PrimaryDiagnosis, SecondaryDiagnosis
		from 
			ERUtilizerReportData		
		where CustID = @CustID
			and VisitDate > @tempRange
			AND		
			MVDID =
				(
					Case ISNULL(@PatientMVDID,'')
						when '' then MVDID
						else @PatientMVDID
					end
				)
		order by ERVisitCount desc
	end
	else
	begin
		select  rank() OVER (ORDER BY ID) AS ranking, Name, DOB, MVDID, InsMemberID, VisitDate,
			Facility, ChiefComplaint, PCP_NPI, NPIName, ERVisitCount, LastERVisitFacilityNPI, 
			PrimaryDiagnosis, SecondaryDiagnosis
		from 
			ERUtilizerReportData		
		where CustID = @CustID
			and VisitDate > @tempRange
			AND		
			MVDID =
				(
					Case ISNULL(@PatientMVDID,'')
						when '' then MVDID
						else @PatientMVDID
					end
				)
			AND MVDID in(
				select s.ICENUMBER
				from dbo.MDUser u
					inner join dbo.Link_MDAccountGroup ag on u.ID = ag.MDAccountID
					inner join dbo.MDGroup g on ag.MDGroupID = g.ID
					inner join dbo.Link_MDGroupNPI n on g.ID = n.MDGroupID
					inner join dbo.MainSpecialist s on n.NPI = s.NPI
				where u.Username = @DoctorID
			)
		order by ERVisitCount desc
	end
	
	--SELECT * FROM @temp 

END


/*

SET @DoctorID = LTRIM(RTRIM(@DoctorID))

	declare @temp table (ID int identity(1,1), Name varchar(200), DOB date, MVDID varchar(20), InsMemberID varchar(50), VisitDate date,
		Facility varchar(100), ChiefComplaint varchar(1000), PCP_NPI varchar(50), NPIName varchar(200), ERVisitCount int, LastERVisitID int, LastERVisitFacilityNPI varchar(50),
		PrimaryDiagnosis varchar(50), SecondaryDiagnosis varchar(50))


	declare @tempRange datetime, @VisitCountDateRange datetime
	select @tempRange = '01/01/1950',
		@VisitCountDateRange = dateadd(mm,-6,getdate())

	if(@DateRange is not null AND @DateRange <> 0)
	begin
		select @tempRange = DATEADD(DD,-@DateRange,GETDATE())
	end

	SELECT @CustID = Cust_ID FROM dbo.HPCustomer h WHERE h.Name = @Customer

	-- Note: cannot use MDMemberVisit because it's populate only with visits where Source not like '%claim%'
	-- Populate qualifying members
	

	if(@DoctorID = 'ALL')
	BEGIN
	insert into @temp(Name, DOB, MVDID, InsMemberID, PCP_NPI, NPIName, ERVisitCount)
	select distinct
		isnull(p.firstname,'') + isnull(' ' + p.lastname,'') as Name, 
		p.DOB,
		li.MVDID,
		li.InsMemberID,
		(select top 1 s.NPI from dbo.MainSpecialist  s where s.ICENUMBER = p.ICENUMBER and RoleID =1 order by s.ModifyDate desc) as PCP_NPI,
		(select top 1 isnull(s.FirstName + ' ','') + isnull(s.LastName,'')  from dbo.MainSpecialist  s where s.ICENUMBER = p.ICENUMBER and RoleID =1 order by s.ModifyDate desc) as NPIName,
		(select COUNT(id) from dbo.EDVisitHistory e where e.ICENUMBER = v.ICENUMBER and e.VisitType = 'ER' and e.visitdate > @VisitCountDateRange) as ERVisitCount			
	from 
		dbo.Link_MemberId_MVD_Ins li
		inner join dbo.EDVisitHistory v on li.MVDId = v.ICENUMBER
		inner join dbo.MainPersonalDetails p on v.ICENUMBER = p.ICENUMBER			
	where 
		VisitType = 'ER' 
		and li.Cust_ID = @CustID
		and li.Active = 1	
		and li.IsPrimary = 1
		and v.VisitDate > @tempRange
		AND		
		p.ICENUMBER =
		(
			Case ISNULL(@PatientMVDID,'')
				when '' then p.ICENUMBER
				else @PatientMVDID
			end
		)
		AND MVDID in(
			select s.ICENUMBER
			from dbo.MDUser u
				inner join dbo.Link_MDAccountGroup ag on u.ID = ag.MDAccountID
				inner join dbo.MDGroup g on ag.MDGroupID = g.ID
				inner join dbo.Link_MDGroupNPI n on g.ID = n.MDGroupID
				inner join dbo.MainSpecialist s on n.NPI = s.NPI
			where --u.Username =@DoctorID and
 			 s.RoleID = 1
			)
	order by ERVisitCount desc

	
	END

	ELSE
	if(@DoctorID != 'ALL')
	BEGIN 
	insert into @temp(Name, DOB, MVDID, InsMemberID, PCP_NPI, NPIName, ERVisitCount)
	select distinct
		isnull(p.firstname,'') + isnull(' ' + p.lastname,'') as Name, 
		p.DOB,
		li.MVDID,
		li.InsMemberID,
		(select top 1 s.NPI from dbo.MainSpecialist  s where s.ICENUMBER = p.ICENUMBER and RoleID =1 order by s.ModifyDate desc) as PCP_NPI,
		(select top 1 isnull(s.FirstName + ' ','') + isnull(s.LastName,'')  from dbo.MainSpecialist  s where s.ICENUMBER = p.ICENUMBER and RoleID =1 order by s.ModifyDate desc) as NPIName,
		(select COUNT(id) from dbo.EDVisitHistory e where e.ICENUMBER = v.ICENUMBER and e.VisitType = 'ER' and e.visitdate > @VisitCountDateRange) as ERVisitCount			
	from 
		dbo.Link_MemberId_MVD_Ins li
		inner join dbo.EDVisitHistory v on li.MVDId = v.ICENUMBER
		inner join dbo.MainPersonalDetails p on v.ICENUMBER = p.ICENUMBER			
	where 
		VisitType = 'ER' 
		and li.Cust_ID = @CustID
		and li.Active = 1	
		and li.IsPrimary = 1
		and v.VisitDate > @tempRange
		AND		
		p.ICENUMBER =
		(
			Case ISNULL(@PatientMVDID,'')
				when '' then p.ICENUMBER
				else @PatientMVDID
			end
		)
		AND MVDID in(
			select s.ICENUMBER
			from dbo.MDUser u
				inner join dbo.Link_MDAccountGroup ag on u.ID = ag.MDAccountID
				inner join dbo.MDGroup g on ag.MDGroupID = g.ID
				inner join dbo.Link_MDGroupNPI n on g.ID = n.MDGroupID
				inner join dbo.MainSpecialist s on n.NPI = s.NPI
			where u.Username =@DoctorID and
 			 s.RoleID = 1
			)
	order by ERVisitCount desc


	END

	
	-- Get last ER visit info
	update @temp
	set lastERVisitID = t.visitID
	from @temp r inner join
	(
		select
		(
			select top 1 e.ID
			from dbo.EDVisitHistory e
			where e.VisitType = 'ER' and e.ICENUMBER = s.MVDID
			order by e.VisitDate desc
		) as visitID, *
		from @temp s

	) t on r.mvdid = t.mvdid

	update @temp
	set VisitDate = e.VisitDate, Facility = e.FacilityName, ChiefComplaint = e.ChiefComplaint, LastERVisitFacilityNPI = FacilityNPI
	from @temp s
		inner join dbo.EDVisitHistory e on s.LastERVisitID = e.ID

	-- Get Primary and Secondary Diagnosis
	update @temp
	set PrimaryDiagnosis = t.PrimaryDiagnosis,
		SecondaryDiagnosis = t.SecondaryDiagnosis
	from @temp r inner join
	(
		select s.mvdid,
			(
				select top 1 Code
				from dbo.MainCondition e
				where e.ICENUMBER = s.MVDID
					and e.IsPrincipal = 1
					and e.UpdatedByNPI = s.LastERVisitFacilityNPI
					and convert(date,e.ReportDate) = s.VisitDate
			) as PrimaryDiagnosis, 
			(
				select top 1 Code
				from dbo.MainCondition e
				where e.ICENUMBER = s.MVDID
					and e.IsPrincipal <> 1
					and e.UpdatedByNPI = s.LastERVisitFacilityNPI
					and convert(date,e.ReportDate) = s.VisitDate
			) as SecondaryDiagnosis
		from @temp s
		where isnull(s.LastERVisitFacilityNPI,'') <> ''
	) t on r.mvdid = t.mvdid


	if(@NPI = 0)
	BEGIN
	select ID as 'ranking', Name, DOB, MVDID, InsMemberID, VisitDate,
			Facility, ChiefComplaint, PCP_NPI, NPIName, ERVisitCount, LastERVisitFacilityNPI,  --LastERVisitID, 
			PrimaryDiagnosis, SecondaryDiagnosis
	from @temp t 

	END

	ELSE
	If(@NPI != 0)
	BEGIN
	select ID as 'ranking', Name, DOB, MVDID, InsMemberID, VisitDate,
			Facility, ChiefComplaint, PCP_NPI, NPIName, ERVisitCount, LastERVisitFacilityNPI,  --LastERVisitID, 
			PrimaryDiagnosis, SecondaryDiagnosis
	from @temp t WHERE t.PCP_NPI = @NPI

	END
	
*/

/* BK old
	select   --rank() OVER (ORDER BY v.ID) AS ranking, 
		isnull(p.firstname,'') + isnull(' ' + p.lastname,'') as Name,convert(date,DOB) as DOB
			,v.InsMemberID	as InsMemberID	
			,CONVERT(VARCHAR(10),v.AlertDate ,101) as Date
			,v.Facility
			,upper(substring(v.ChiefComplaint,1,1))+lower(substring(v.ChiefComplaint,2,len(v.ChiefComplaint))) as ChiefComplaint
						
			
			,(select top 1 s.NPI from dbo.MainSpecialist  s where s.ICENUMBER = p.ICENUMBER and RoleID =1 order by s.ModifyDate desc) as PCP_NPI,
			(SELECT ( [Provider First Name] +' ' +[Provider Middle Name] + ' ' + [Provider Last Name (Legal Name)])  FROM dbo.lookupnpi WHERE npi = (select top 1 s.NPI from dbo.MainSpecialist s where s.ICENUMBER = p.ICENUMBER and Ro

leID =1 order by s.ModifyDate desc)) AS NPIName,
			
			(select COUNT(id) from dbo.EDVisitHistory e where e.ICENUMBER = v.mvdid and e.VisitType = 'ER' and e.visitdate > @VisitCountDateRange) as ERVisitCount
			
	from dbo.MDMemberVisit v
		inner join dbo.MainPersonalDetails p on v.MVDID = p.ICENUMBER		
		--LEFT OUTER JOIN EDVisitHistory eh ON v.MVDID = eh.ICENUMBER and eh.VisitType = 'ER'
		--LEFT OUTER JOIN LookupNPI ln ON  = ln.NPI 
		
	where 
		v.AlertDate > @tempRange
		AND		
		p.ICENUMBER =
		(
			Case ISNULL(@PatientMVDID,'')
				when '' then p.ICENUMBER
				else @PatientMVDID
			end
		)
		AND MVDID in(
			select s.ICENUMBER
			from dbo.MDUser u
				inner join dbo.Link_MDAccountGroup ag on u.ID = ag.MDAccountID
				inner join dbo.MDGroup g on ag.MDGroupID = g.ID
				inner join dbo.Link_MDGroupNPI n on g.ID = n.MDGroupID
				inner join dbo.MainSpecialist s on n.NPI = s.NPI
			where u.Username =@DoctorID
				and s.RoleID = 1
			)
	--	and s.npi = '1366490799'
	order by ERVisitCount desc

*/