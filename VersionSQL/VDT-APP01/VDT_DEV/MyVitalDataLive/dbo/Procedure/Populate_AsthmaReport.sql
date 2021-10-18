/****** Object:  Procedure [dbo].[Populate_AsthmaReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Changes:	04/07/2017	Marc De Luca	Cleaned up proc.  Changed table variables into temp tables
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================
CREATE PROCEDURE [dbo].[Populate_AsthmaReport]
AS
BEGIN
	SET NOCOUNT ON;

	declare @npi varchar(20), @DBNAME varchar(50)	--, @Customer varchar(50)	
	declare @DateRange int
	declare @ERCountLimitDate datetime

	declare @ParentCustomerID int,		-- Health Plan members belong to top level health plan
		@customerId int, @PCPName varchar(200), @customerName varchar(100)

	select @ERCountLimitDate = DATEADD(MM,-12,getdate())
	
	TRUNCATE TABLE dbo.AsthmaReport
	TRUNCATE TABLE dbo.TempAsthmaReport
	
	IF OBJECT_ID('tempdb..#tempNPI') IS NOT NULL DROP TABLE #tempNPI;
	CREATE TABLE #tempNPI (npi varchar(20))

	INSERT INTO #tempNPI(npi)
	SELECT npi 
	FROM dbo.AsthmaReport_NPI

	CREATE INDEX IX_npi ON #tempNPI (npi)
		
	IF OBJECT_ID('tempdb..#tempDateRange') IS NOT NULL DROP TABLE #tempDateRange;
	CREATE TABLE #tempDateRange (range int, isProcessed bit default(0))

	INSERT INTO #tempDateRange(range)
	SELECT range 
	FROM MVD_SQLReports.dbo.AsthmaReport_DateRange
	
	CREATE INDEX IX_isProcessed ON #tempDateRange (isProcessed)

	while exists(select top 1 npi from #tempNPI)
	begin
		select top 1 @npi = npi from #tempNPI		
		
		select @PCPName = dbo.FullName(LEFT([Provider Last Name (Legal Name)],50),[Provider First Name],'') + ' (' + @npi + ')'
		from dbo.LookupNPI
		where npi = @npi

		while exists(select top 1 range from #tempDateRange where isProcessed = 0)
		begin
			select top 1 @DateRange = range from #tempDateRange where isProcessed = 0
			
			insert dbo.TempAsthmaReport (Icenumber,InsMemberId,VisitDate,PhoneNumber,Facility,CustID, CustomerName)
			select distinct a.ICENUMBER, li.InsMemberId, visitdate, '', FacilityName,li.Cust_ID, c.Name 
			from dbo.EDVisitHistory a 
				inner join dbo.MainSpecialist s on a.ICENUMBER = s.ICENUMBER
				inner join dbo.Link_MemberId_MVD_Ins li on a.ICENUMBER = li.MVDId
				inner join dbo.hpCustomer c on li.cust_ID = c.cust_ID
			where VisitDate > dateadd(d,-@DateRange,GETDATE())
				and VisitType in ('ER')
				and s.NPI =  @npi
				and s.RoleID = 1
			order by ICENUMBER	

			insert into dbo.AsthmaReportProgressLog([log])
			select 'Start @Customer: ' + isnull(@customerName,'')
				+ ', @PCP_NPI: ' + isnull(@npi,'') + ', @DateRange: ' + CONVERT(varchar(10), isnull(@daterange,''))

			insert into dbo.AsthmaReportProgressLog([log])
			select 'Start Base count: ' +  CONVERT(varchar(10), COUNT(*))
			from  TempAsthmaReport
			
			IF OBJECT_ID('tempdb..#RemoveDupes') IS NOT NULL DROP TABLE #RemoveDupes;
			CREATE TABLE #RemoveDupes (icenumber varchar(50))

			INSERT INTO #RemoveDupes (icenumber)
			SELECT DISTINCT(icenumber) 
			FROM dbo.TempAsthmaReport

			CREATE INDEX IX_icenumber ON #RemoveDupes (icenumber)

			Declare @IceNumber varchar(50), @VisitDate datetime

			While exists (select top 1 icenumber from #RemoveDupes)
			BEGIN

				  Select TOP 1 @IceNumber = Icenumber from #RemoveDupes

				  Select @VisitDate = visitdate  from TempAsthmaReport where Icenumber = @Icenumber
				  order by visitdate desc
			      
				  DELETE FROM dbo.TempAsthmaReport where Icenumber = @Icenumber and visitdate != @visitdate
			      
				  DELETE FROM #RemoveDupes WHERE Icenumber = @Icenumber
			      
			END
				
			delete TempAsthmaReport 
			where Icenumber not in (
			select distinct(ICENUMBER) 
			from MainCondition 
			where ICENUMBER in (select ICENUMBER from TempAsthmaReport) 
			and Code like '493%')

			IF OBJECT_ID('tempdb..#TEMPReview') IS NOT NULL DROP TABLE #TEMPReview;
			CREATE TABLE #TEMPReview (Icenumber varchar(50))

			INSERT #TEMPReview (Icenumber)
			SELECT icenumber 
			FROM dbo.TempAsthmaReport

			Select @IceNumber = '', @VisitDate = ''

			While exists (Select top 1 Icenumber from #TEMPReview)
			BEGIN

				  Select top 1 @IceNumber = icenumber from #TEMPReview
			      
				  Select @visitdate = visitdate from TempAsthmaReport
				  where Icenumber = @IceNumber
			      
				  if exists (select top 1 ICENUMBER from 
						EDVisitHistory
					  where ICENUMBER = @IceNumber
					  and VisitDate > @visitdate
					  and VisitType = 'Physician' )
					begin
							Delete TempAsthmaReport
							where Icenumber = @IceNumber
		              
					end
			      
				  delete #TEMPReview where Icenumber = @IceNumber

			END
			
			insert into AsthmaReport(InsMemberId,Facility,VisitDate,LastName,FirstName,HomePhone,DOB,StartDate,RefillDate,
			   PrescribedBy,RxDrug,RxPharmacy,PCPName,customerName,DateRange,PCP_NPI,ERVisitCount,CustID)
			select a.InsMemberId, a.Facility,
				CONVERT(VARCHAR(10), a.VisitDate ,101) as VisitDate ,b.LastName, b.FirstName, dbo.FormatPhone(b.HomePhone) as HomePhone, 
				CONVERT(VARCHAR(10), b.DOB ,101) as DOB,
				CONVERT(VARCHAR(10), m.StartDate ,101) as StartDate, 
				CONVERT(VARCHAR(10), m.RefillDate ,101) as RefillDate, m.PrescribedBy, m.RxDrug, m.RxPharmacy, @PCPName as 'PCPName',  
				a.CustomerName, @DateRange as 'DateRange', @npi,
				(select count(ID) from edvisitHistory where icenumber = b.icenumber and VisitType = 'ER' and visitdate > @ERCountLimitDate) as 'ErLast12months',
				a.CustID
			from TempAsthmaReport a 
				inner join MainPersonalDetails b on a.Icenumber = b.ICENUMBER
				left join MainMedication m on a.Icenumber = m.ICENUMBER
			where (m.RefillDate is null OR m.RefillDate  > dateadd(d,-60,GETDATE()))
				 and 
				 ( m.ndc_last8 is null OR m.ndc_last8 in(
					select ndc from dbo.AsthmaReportMedications
					)
				  )
			
			insert into dbo.AsthmaReportProgressLog([log])
			select 'Result count: ' +  CONVERT(varchar(10), COUNT(*))
			from  AsthmaReport
			where PCP_NPI = @npi AND DateRange = @DateRange
			
			TRUNCATE TABLE dbo.TempAsthmaReport
			TRUNCATE TABLE #RemoveDupes
			TRUNCATE TABLE #TEMPReview
	
			update #tempDateRange 
			set isProcessed = 1 
			where range = @DateRange

		end
		
		update #tempDateRange 
		set isProcessed = 0
		delete from #tempNPI where npi = @npi
	end
	
END