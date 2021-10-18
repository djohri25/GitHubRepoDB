/****** Object:  Procedure [dbo].[Report_MembershipInProgramsWithCase]    Committed by VersionSQL https://www.versionsql.com ******/

/*
 Author:		Sunil Nokku
 Create date:	2021-08-12
 Description:	Membership In Programs

Modified		Modified By		Details

EXEC Report_MembershipInProgramsWithCase @StartDate = '20210101', @EndDate = '20210816'

Also schedule the job to populate EligMonth
*/

CREATE PROCEDURE [dbo].[Report_MembershipInProgramsWithCase]
@StartDate			date,
@EndDate			date,
@YTD				bit = 0,
@OnlyAuditable		bit = 0,
@LOB				varchar(MAX) = 'ALL',
@CmOrgRegion		varchar(MAX) = 'ALL',
@CompanyKey			varchar(MAX) = 'ALL',
@CaseProgram		varchar(MAX) = 'ALL',
@CaseManager		varchar(MAX) = 'ALL'
AS
BEGIN
	DECLARE 
		@v_StartDate date = @StartDate,
		@v_EndDate	 date = @EndDate
		--@LOB				varchar(MAX) = 'ALL',
		--@CmOrgRegion		varchar(MAX) = 'ALL',
		--@CompanyKey			varchar(MAX) = 'ALL',
		--@CaseProgram		varchar(MAX) = 'ALL',
		--@CaseManager		varchar(MAX) = 'ALL'
	
	IF (@YTD = 1)
	BEGIN
		SET @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
		SET @enddate = DATEADD(dd,-1,CAST(GETDATE() AS DATE))
	END

	DROP TABLE IF EXISTS #ListMonth;
	CREATE TABLE
	#ListMonth
	(
		MonthID nvarchar(255),
		StartDate date,
		EndDate date
	);

	;WITH MONTHS (date)
	AS
	(
		SELECT @v_StartDate
		UNION ALL
		SELECT DATEADD(MONTH,1,date)
		FROM MONTHS
		WHERE 
		DATEADD(DAY,1,EOMONTH(DATEADD(MONTH,1,date),-1))
		--DATEADD(MONTH,1,date) 
		<= @v_EndDate
	)
	INSERT INTO #ListMonth
	SELECT FORMAT(Date, 'MM-yyyy'),
		--DATENAME(YEAR,date)+DATENAME(MONTH,date), 
		CASE WHEN date = @v_StartDate 
		THEN @v_StartDate 
		ELSE DATEADD(DAY, 1, EOMONTH(date, -1)) 
		END, 
		CASE WHEN EOMONTH(date) > @v_EndDate 
		THEN @v_EndDate
		ELSE EOMONTH(date) 
		END
		FROM MONTHS

	--SELECT * FROM #ListMonth
	
	;WITH CasesList 
	AS
	(
	SELECT CM.MonthID,
		mmf.MVDID,
		Coalesce(mmf.q4caseprogram,mmf.CaseProgram) as CaseProgram,
		ccq.CompanyName,
		ccq.CompanyKey,
		ccq.LOB,
		ccq.CmOrGRegion,
		mmf.q1CaseCreateDate,
		mmf.q1CaseCloseDate,
		CASE
		WHEN MMF.q1CaseCreateDate BETWEEN CM.StartDate AND CM.EndDate THEN 1
		WHEN MMF.q1CaseCloseDate BETWEEN CM.StartDate AND CM.EndDate THEN 1
		WHEN MMF.q1CaseCreateDate <= CM.EndDate AND MMF.q1CaseCloseDate >= CM.EndDate THEN 1
		WHEN MMF.q1CaseCreateDate <= CM.EndDate AND ISNULL( MMF.q1CaseCloseDate, '' ) = '' THEN 1
		ELSE 0
		END AS CaseOpen,
		CASE WHEN ISNULL(mmf.q4CaseProgram,'')='' THEN 0
		ELSE 1
		END AS MemberInCaseProgram
	FROM 
		ComputedCareQueue ccq (readuncommitted) 
		LEFT OUTER JOIN abcbs_membermanagement_form mmf (readuncommitted)
		ON mmf.MVDID = ccq.MVDID
		INNER JOIN #ListMonth CM 
		ON 1=1
	WHERE 
	((MMF.q1CaseCreateDate <= CM.StartDate AND (MMF.q1CaseCloseDate >= CM.EndDate OR ISNULL( MMF.q1CaseCloseDate, '' ) = ''))
	 OR
	 (MMF.q1CaseCreateDate BETWEEN CM.StartDate AND CM.EndDate AND (MMF.q1CaseCloseDate >= CM.EndDate OR ISNULL( MMF.q1CaseCloseDate, '' ) = '')))
		--CASE
		--WHEN MMF.q1CaseCreateDate BETWEEN CM.StartDate AND CM.EndDate THEN 1
		--WHEN MMF.q1CaseCloseDate BETWEEN CM.StartDate AND CM.EndDate THEN 1
		--WHEN MMF.q1CaseCreateDate <= CM.EndDate AND MMF.q1CaseCloseDate >= CM.EndDate THEN 1
		--WHEN MMF.q1CaseCreateDate <= CM.EndDate AND ISNULL( MMF.q1CaseCloseDate, '' ) = '' THEN 1
		--ELSE 0
		--END = 1
		AND ((@LOB = 'ALL') or (CHARINDEX(ccq.[LOB], @LOB) > 0))
		AND ((@CmOrgRegion = 'ALL') or (CHARINDEX(ccq.[CmOrgRegion], @CmOrgRegion) > 0))
		AND ((@CaseProgram = 'ALL') or (CHARINDEX(mmf.[q4CaseProgram], @CaseProgram) > 0))
		AND ((@CompanyKey = 'ALL') 
			OR (CHARINDEX(cast(ccq.[CompanyKey] as varchar(10)), @CompanyKey) > 0 
				OR ccq.[CompanyName] LIKE '%'+@CompanyKey+'%'))

	)

	SELECT MonthID,
		CaseProgram,
		CompanyName,
		CompanyKey,
		LOB,
		CmOrGRegion,
		SUM(CaseOpen) TotalOpenCases,
		SUM(MemberInCaseProgram) TotalInCaseProgram
	INTO #Cases
	FROM CasesList
	GROUP BY 
		MonthID,
		CaseProgram,
		CompanyName,
		CompanyKey,
		LOB,
		CmOrGRegion
		
	SELECT c.*, e.MemCount AS TotalActiveMember 
	FROM #Cases c
	INNER JOIN EligMonth e 
		ON c.MonthID = e.MonthID 
			AND c.LOB = e.LOB
			AND c.CompanyKey = e.CompanyKey
			AND c.CmOrgRegion = e.CmOrgRegion

END