/****** Object:  Procedure [dbo].[GetCaseSummaryMonthlyData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =======================================================
-- Author: Sunil Nokku
-- Create date: 11/14/2019
-- exec GetCaseSummaryMonthlyData 'MyVitalDataLive',null,'20200101','20200930'
-- Modified		Author		Description
-- -----------  ----------  ---------------------------------------------
-- 04/27/2020	Sunil		Change end date to Today() like in SSRS
-- 08/17/2020	Sunil Nokku		Add conditions to avoid Void cases. ( TFS 3317 )
-- 20201007		Jose		Fix CaseActiveRageEnd
-- 11/11/2020	Sunil Nokku		#TFS 3800,3795,3797,3798,3799
-- ========================================================

CREATE PROCEDURE [dbo].[GetCaseSummaryMonthlyData] ( 
	@DBNAME VARCHAR(20), 
	@EffectiveDate DATETIME NULL,
	@p_start_date DATETIME NULL, 
	@p_end_date DATETIME NULL
	)
AS
BEGIN

SET NOCOUNT ON;

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
	SELECT DATENAME(YEAR,date)+DATENAME(MONTH,date), 
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
		MonthName varchar(20),
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
		CM.Name MonthName,
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
		--AND MMF.q2CONsentDate <> '1900-01-01' TFS 3387, 3798
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
		FM.CMOrgRegion,
		MMF.CaseProgram,
		CM.StartDate

	IF OBJECT_ID('tempdb..#FinalSSRSResult') IS NOT NULL DROP TABLE #FinalSSRSResult

	CREATE TABLE #FinalSSRSResult (CmOrgRegiON varchar(100), 
		CaseProgram varchar(150), 
		MonthID varchar(50),
		CMStartDate datetime,
		CasesCreatedInDateRange INT, 
		CasesClosedInDateRange INT, 
		CasesActiveInDateRange INT, 
		CasesActiveInDateRangeEnd INT,
		CaseFlag varchar(10))

	IF OBJECT_ID('tempdb..#FinalSSRSResult2') IS NOT NULL DROP TABLE #FinalSSRSResult2

	CREATE TABLE #FinalSSRSResult2 (CmOrgRegiON varchar(100), 
		CaseProgram varchar(150), 
		MonthID varchar(50),
		CMStartDate datetime,
		CasesCreatedInDateRange INT, 
		CasesClosedInDateRange INT, 
		CasesActiveInDateRange INT, 
		CasesActiveInDateRangeEnd INT,
		CaseFlag varchar(10),
		LastValCasesActiveInRange INT,
		LastValCasesActiveInRangeEnd INT)
	
	--Pending and Auditable Results

	;WITH [Cases] AS (
	SELECT 
		CMOrgRegion,
		CaseProgram,
		MonthName,
		CMStartDate,
		SUM(CasesCreatedInDateRangeFlag)	[CasesCreatedInDateRangeFlag],
		SUM(CasesClosedInDateRangeFlag)		[CasesClosedInDateRangeFlag],
		SUM(CasesActiveInDateRangeFlag)		[CasesActiveInDateRangeFlag],
		SUM(CasesActiveInDateRangeEndFlag)	[CasesActiveInDateRangeEndFlag],
		CASE WHEN Isauditable=1 THEN 'A' 
		WHEN IsPending=1 THEN 'P' END		[CaseFlag]
	FROM
		#MMFCases 
	GROUP BY
		CMOrgRegion,
		CaseProgram,
		MonthName,
		CMStartDate,
		CASE WHEN Isauditable=1 THEN 'A' 
		WHEN IsPending=1 THEN 'P' END
	), 
	MMP AS ( SELECT 
				CMOrgRegion,
				CaseProgram,
				MonthName,
				YEAR(CMStartDate)				[StartDateYear],
				MONTH(CMStartDate)				[StartDateMonth],
				CasesCreatedInDateRangeFlag,
				CasesClosedInDateRangeFlag,
				CasesActiveInDateRangeFlag,
				CasesActiveInDateRangeEndFlag,
				[CaseFlag]
			FROM
				[Cases] 
			)
	INSERT INTO #FinalSSRSResult
	SELECT 
		MMF.CMOrgRegion,
		MMF.CaseProgram,
		MMF.MonthName,
		MMF.CMStartDate,
		MMF.CasesCreatedInDateRangeFlag,
		MMF.CasesClosedInDateRangeFlag,
		MMF.CasesActiveInDateRangeFlag,
		CASE 
			WHEN MMP.MonthName IS NULL THEN
				MMF.CasesActiveInDateRangeEndFlag
			ELSE
				MMP.CasesActiveInDateRangeEndFlag + ( MMF.[CasesCreatedInDateRangeFlag] - MMF.[CasesClosedInDateRangeFlag] )
			END								[CasesActiveInDateRangeEndFlag],
		MMF.[CaseFlag]
	FROM [Cases] MMF
		LEFT JOIN MMP
			ON MMF.CMOrgRegion = MMP.CMOrgRegion AND MMF.CaseProgram = MMP.CaseProgram
				AND YEAR(MMF.CMStartDate) = [StartDateYear] AND (MONTH(MMF.CMStartDate)-1) = [StartDateMonth] 
				AND MMF.[CaseFlag] = MMP.[CaseFlag]

	--Totals Results

	;WITH [Cases] AS (
	SELECT 
		CMOrgRegion,
		CaseProgram,
		MonthName,
		CMStartDate,
		SUM(CasesCreatedInDateRangeFlag)	[CasesCreatedInDateRangeFlag],
		SUM(CasesClosedInDateRangeFlag)		[CasesClosedInDateRangeFlag],
		SUM(CasesActiveInDateRangeFlag)		[CasesActiveInDateRangeFlag],
		SUM(CasesActiveInDateRangeEndFlag)	[CasesActiveInDateRangeEndFlag],
		'T' [CaseFlag]
	FROM
		#MMFCases 
	GROUP BY
		CMOrgRegion,
		CaseProgram,
		MonthName,
		CMStartDate
	), 
	MMP AS ( SELECT 
				CMOrgRegion,
				CaseProgram,
				MonthName,
				YEAR(CMStartDate)				[StartDateYear],
				MONTH(CMStartDate)				[StartDateMonth],
				CasesCreatedInDateRangeFlag,
				CasesClosedInDateRangeFlag,
				CasesActiveInDateRangeFlag,
				CasesActiveInDateRangeEndFlag,
				[CaseFlag]
			FROM
				[Cases] 
			)
	INSERT INTO #FinalSSRSResult
	SELECT 
		MMF.CMOrgRegion,
		MMF.CaseProgram,
		MMF.MonthName,
		MMF.CMStartDate,
		MMF.CasesCreatedInDateRangeFlag,
		MMF.CasesClosedInDateRangeFlag,
		MMF.CasesActiveInDateRangeFlag,
		CASE 
			WHEN MMP.MonthName IS NULL THEN
				MMF.CasesActiveInDateRangeEndFlag
			ELSE
				MMP.CasesActiveInDateRangeEndFlag + ( MMF.[CasesCreatedInDateRangeFlag] - MMF.[CasesClosedInDateRangeFlag] )
			END								[CasesActiveInDateRangeEndFlag],
		MMF.[CaseFlag]
	FROM [Cases] MMF
		LEFT JOIN MMP
			ON MMF.CMOrgRegion = MMP.CMOrgRegion AND MMF.CaseProgram = MMP.CaseProgram
				AND YEAR(MMF.CMStartDate) = [StartDateYear] AND (MONTH(MMF.CMStartDate)-1) = [StartDateMonth] 
				AND MMF.[CaseFlag] = MMP.[CaseFlag]
	
--Resultset to get Summary results
	;WITH cte_final AS
			(		SELECT CmOrgRegion , 
						CaseProgram , 
						MonthID ,
						CMStartDate ,
						CasesCreatedInDateRange , 
						CasesClosedInDateRange , 
						CasesActiveInDateRange , 
						CasesActiveInDateRangeEnd ,
						CaseFlag ,
						FIRST_VALUE(CasesActiveInDateRange)
							OVER 
							(PARTITION BY CaseFlag, CMOrgRegion, CaseProgram ORDER BY CMStartDate DESC) AS LastValCasesActiveInRange,
						FIRST_VALUE(CasesActiveInDateRangeEnd)
							OVER 
							(PARTITION BY CaseFlag, CMOrgRegion, CaseProgram ORDER BY CMStartDate DESC) AS LastValCasesActiveInRangeEnd
					FROM #FinalSSRSResult 
			),
			cte_group AS
			(		SELECT 'Summary' [Group],
						CONCAT(CmOrgRegiON,'-',CaseProgram) CaseProgram1,
						'Jan-Sep' [Month],
						getdate() CMDate,
						SUM(CasesCreatedInDateRange) CasesActiveDuringMonth, 
						SUM(CasesClosedInDateRange) CasesActiveMonthEnd, 
						MAX(LastValCasesActiveInRange) LastValCasesActiveInRange,
						MAX(LastValCasesActiveInRangeEnd) LastValCasesActiveInRangeEnd,
						CaseFlag
					FROM cte_final
					GROUP BY 
						CONCAT(CmOrgRegiON,'-',CaseProgram),
						CaseFlag,
						LastValCasesActiveInRange,
						LastValCasesActiveInRangeEnd
			)

			INSERT INTO #FinalSSRSResult2
			SELECT [Group], 
				CaseProgram1, 
				[Month], 
				CMDate, 
				CasesActiveDuringMonth, 
				CasesActiveMonthEnd, 
				LastValCasesActiveInRange,
				LastValCasesActiveInRangeEnd,
				CaseFlag,
				LastValCasesActiveInRange, 
				LastValCasesActiveInRangeEnd
			FROM cte_group
			ORDER BY
				[Group],
				CaseProgram1

--Resultset to get LastVal 
	INSERT INTO #FinalSSRSResult2
	SELECT CmOrgRegion , 
		CaseProgram , 
		MonthID ,
		CMStartDate,
		CasesCreatedInDateRange , 
		CasesClosedInDateRange , 
		CasesActiveInDateRange , 
		CasesActiveInDateRangeEnd ,
		CaseFlag ,
		FIRST_VALUE(CasesActiveInDateRange)
			OVER 
			(PARTITION BY CaseFlag, CMOrgRegion, CaseProgram ORDER BY CMStartDate DESC) AS LastValCasesActiveInRange,
		FIRST_VALUE(CasesActiveInDateRangeEnd)
			OVER 
			(PARTITION BY CaseFlag, CMOrgRegion, CaseProgram ORDER BY CMStartDate DESC) AS LastValCasesActiveInRangeEnd
	FROM #FinalSSRSResult 
		ORDER BY
		CaseFlag,
		CMOrgRegion,
		CaseProgram,
		CMStartDate

--FinalResult
	SELECT 
		CmOrgRegion , 
		CaseProgram , 
		MonthID ,
		CasesCreatedInDateRange , 
		CasesClosedInDateRange , 
		CasesActiveInDateRange , 
		CasesActiveInDateRangeEnd ,
		CaseFlag ,
		LastValCasesActiveInRange ,
		LastValCasesActiveInRangeEnd
	FROM #FinalSSRSResult2
	--WHERE CmOrgRegion = 'Summary'
	ORDER BY
	CaseFlag,
	CMOrgRegion,
	CaseProgram,
	CMStartDate

END