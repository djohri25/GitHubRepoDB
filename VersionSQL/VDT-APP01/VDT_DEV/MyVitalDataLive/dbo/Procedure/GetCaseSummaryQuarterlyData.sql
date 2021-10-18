/****** Object:  Procedure [dbo].[GetCaseSummaryQuarterlyData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[GetCaseSummaryQuarterlyData] ( 
	@DBNAME VARCHAR(20), 
	@EffectiveDate DATETIME = NULL,
	@p_start_date DATETIME= NULL, 
	@p_end_date DATETIME =NULL)
AS

/* =======================================================
 Author: Sunil Nokku
 Create date: 11/14/2019
 exec GetCaseSummaryQuarterlyData 'MyVitalDataUAT','20200428',null,null
 Modified 04/27/2020 - Sunil - Change end date to Today() like in SSRS
 Date			Modified		Description		
 08/17/2020		Sunil Nokku		Add conditions to avoid Void cases. ( TFS 3317 )
 ========================================================*/
BEGIN

DECLARE @v_today datetime 
		,@v_start_date datetime 
		,@v_end_date datetime

IF (@p_start_date IS NOT NULL AND @p_end_date IS NOT NULL)
BEGIN
	SET @v_start_date = @p_start_date
	SET @v_end_date = @p_end_date
END
ELSE
BEGIN
	SELECT @v_today = CASE WHEN @EffectiveDate IS NOT NULL THEN @EffectiveDate ELSE getUTCDate() END;
	SELECT @v_start_date =
	CASE
    WHEN MONTH( @EffectiveDate ) = 1 AND DAY( @EffectiveDate ) < 31 THEN DATEFROMPARTS( YEAR( @v_today ) - 1, 1, 1 )
    ELSE DATEFROMPARTS( YEAR( @v_today ), 1, 1 )
    END;
 
	SELECT @v_end_date =
    CASE
    WHEN @EffectiveDate IS NOT NULL THEN @EffectiveDate --DATEADD( DAY, 1, @EffectiveDate )
    ELSE DATEADD( DAY, 1, DATEADD( DAY, -1, DATEFROMPARTS( YEAR( @v_today ), MONTH( @v_today ), 1 ) ) )
    END;
END

--SELECT @v_start_date, @v_end_date

DROP TABLE IF EXISTS #ListMonth;
CREATE TABLE
#ListMonth
(
	Name nvarchar(255),
	StartDate date,
	EndDate date
);

;WITH MONTHS (date)
AS
(
    SELECT @v_start_date
    UNION ALL
    SELECT DATEADD(MONTH,1,date)
    FROM MONTHS
    WHERE 	
	DATEADD(DAY,1,EOMONTH(DATEADD(MONTH,1,date),-1))
	--DATEADD(MONTH,1,date) 
	<= @v_end_date
)
INSERT INTO #ListMonth
SELECT DATENAME(YEAR,date)+'Q'+DATENAME(QQ,date), 
	CASE WHEN date = @v_start_date 
	THEN @v_start_date 
	ELSE DATEADD(DAY, 1, EOMONTH(date, -1)) 
	END, 
	CASE WHEN EOMONTH(date) > @v_end_date 
	THEN @v_end_date
	ELSE EOMONTH(date) 
	END
	FROM MONTHS

IF OBJECT_ID('tempdb..#MMFCases') IS NOT NULL DROP TABLE #MMFCases

CREATE TABLE #MMFCases (
	QuarterName varchar(20),
	CMStartDate datetime,
	CMEndDate datetime,
	MVDID varchar(60),
	CmOrgRegiON varchar(100), 
	CaseProgram varchar(100), 
	CaseID varchar(20),
	q1CaseCreateDate datetime, 
	q1CaseCloseDate datetime, 
	CarePlanID varchar(20), 
	Activated VARCHAR(2),
	CasesCreatedInDateRangeFlag int, 
	CasesClosedInDateRangeFlag int, 
	CasesActiveInDateRangeFlag int, 
	CasesActiveInDateRangeEndFlag int,
	IsAuditable int,
	IsPending int
)

INSERT INTO #MMFCases
SELECT DISTINCT
	CM.Name QuarterName,
	CM.StartDate,
	CM.EndDate,
	MMF.MVDID,
	FM.CMOrgRegion,
	MMF.CaseProgram,
	MMF.CaseID,
	MMF.q1CaseCreateDate,
	MMF.q1CaseCloseDate,
	MMF.CarePlanID,
	CPI.Activated,
	CASE
	WHEN MMF.q1CaseCreateDate BETWEEN CM.StartDate AND CM.EndDate THEN 1
	ELSE 0
	END CasesCreatedInDateRange,
	CASE
	WHEN MMF.q1CaseCloseDate BETWEEN CM.StartDate AND CM.EndDate THEN 1
	ELSE 0
	END CasesClosedInDateRange,
	CASE
	WHEN MMF.q1CaseCreateDate BETWEEN CM.StartDate AND CM.EndDate THEN 1
	WHEN MMF.q1CaseCloseDate BETWEEN CM.StartDate AND CM.EndDate THEN 1
	WHEN MMF.q1CaseCreateDate <= CM.EndDate AND MMF.q1CaseCloseDate >= CM.EndDate THEN 1
	WHEN MMF.q1CaseCreateDate <= CM.EndDate AND ISNULL( MMF.q1CaseCloseDate, '' ) = '' THEN 1
	ELSE 0
	END CasesActiveInDateRange,
	CASE
	WHEN MMF.q1CaseCreateDate <= CM.EndDate AND MMF.q1CaseCloseDate >= CM.EndDate THEN 1
	WHEN MMF.q1CaseCreateDate <= CM.EndDate AND ISNULL( MMF.q1CaseCloseDate, '' ) = '' THEN 1
	ELSE 0
	END CasesActiveAtDateRangeEnd,
	CASE
	WHEN CPI.Activated = '1' THEN 1
	ELSE 0
	END IsAuditable,
	CASE
	WHEN MMF.CarePlanID IS NULL THEN 1
	WHEN CPI.CaseID IS NULL THEN 1
	ELSE 0
	END IsPending
	--INTO #CasesAuditable
	FROM dbo.ABCBS_MemberManagement_Form MMF
	INNER JOIN FinalMember fm
	ON fm.MVDID = MMF.MVDID
	INNER JOIN #ListMonth CM
	ON 1 = 1
	LEFT OUTER JOIN dbo.MainCarePlanMemberIndex CPI
	ON CPI.CaseID = MMF.CaseID
	LEFT OUTER JOIN dbo.MainCarePlanMemberProblems CPP ON CPP.[CarePlanID] = CPI.[CarePlanID]
	LEFT OUTER JOIN dbo.MainCarePlanMemberGoals CPG ON CPG.[GoalNum] = CPP.[problemNum]
	LEFT OUTER JOIN dbo.MainCarePlanMemberInterventiONs CPN ON CPN.[GoalID] = CPG.[GoalNum]
	LEFT OUTER JOIN dbo.MainCarePlanMemberOutcomes CPO ON CPO.[ProblemID] = CPP.[problemNum]
	WHERE LEN(MMF.CaseID) >= 1
	AND CONVERT(DATE, MMF.[q1CaseCreateDate]) <= @v_end_date
	AND
	CASE
	WHEN MMF.q1CaseCloseDate >= @v_start_date THEN 1
	WHEN ISNULL( MMF.q1CaseCloseDate, '' ) = '' THEN 1
	ELSE 0
	END = 1
	AND MMF.q2CONsentDate <> '1900-01-01'
	AND
	CASE
	WHEN MMF.q1CaseCreateDate BETWEEN CM.StartDate AND CM.EndDate THEN 1
	WHEN MMF.q1CaseCreateDate <= CM.EndDate AND MMF.q1CaseCloseDate >= CM.EndDate THEN 1
	WHEN MMF.q1CaseCreateDate <= CM.EndDate AND ISNULL( MMF.q1CaseCloseDate, '' ) = '' THEN 1
	WHEN MMF.q1CaseCloseDate BETWEEN CM.StartDate AND CM.EndDate THEN 1
	ELSE 0
	END = 1
	AND ISNULL(FM.CmOrgRegion,'') != ''
	AND ISNULL(MMF.CaseProgram,'') != ''
	AND ISNULL(MMF.q2CloseReason,'') <> 'VOID'
	ORDER BY
	CMOrgRegion,
	CaseProgram,
	CM.StartDate
--SELECT * FROM #MMFCases

IF OBJECT_ID('tempdb..#FinalSSRSResult') IS NOT NULL DROP TABLE #FinalSSRSResult

CREATE TABLE #FinalSSRSResult (CmOrgRegiON varchar(100), 
	CaseProgram varchar(100), 
	QuarterID varchar(50),
	CasesCreatedInDateRange varchar(100), 
	CasesClosedInDateRange varchar(100), 
	CasesActiveInDateRange varchar(100), 
	CasesActiveInDateRangeEnd VARCHAR(100),
	CaseFlag varchar(10))

INSERT INTO #FinalSSRSResult
SELECT 
	CMOrgRegion,
	CaseProgram,
	QuarterName,
	SUM(CasesCreatedInDateRangeFlag),
	SUM(CasesClosedInDateRangeFlag),
	SUM(CasesActiveInDateRangeFlag),
	SUM(CasesActiveInDateRangeEndFlag),
	CASE WHEN Isauditable=1 THEN 'A' 
	WHEN IsPending=1 THEN 'P' END
	FROM #MMFCases
	--WHERE q1CaseCreateDate >= @v_start_date
	GROUP BY
	CMOrgRegion,
	CaseProgram,
	QuarterName,
	CASE WHEN Isauditable=1 THEN 'A' 
	WHEN IsPending=1 THEN 'P' END

	UNION ALL

	SELECT 
	CMOrgRegion,
	CaseProgram,
	QuarterName,
	SUM(CasesCreatedInDateRangeFlag),
	SUM(CasesClosedInDateRangeFlag),
	SUM(CasesActiveInDateRangeFlag),
	SUM(CasesActiveInDateRangeEndFlag),
	'T'
	FROM #MMFCases
	--WHERE q1CaseCreateDate >= @v_start_date
	GROUP BY
	CMOrgRegion,
	CaseProgram,
	QuarterName

SELECT CmOrgRegion , 
	CaseProgram , 
	QuarterID ,
	CasesCreatedInDateRange , 
	CasesClosedInDateRange , 
	CasesActiveInDateRange , 
	CasesActiveInDateRangeEnd ,
	CaseFlag 
FROM #FinalSSRSResult 
	ORDER BY
	CMOrgRegion,
	CaseProgram

END