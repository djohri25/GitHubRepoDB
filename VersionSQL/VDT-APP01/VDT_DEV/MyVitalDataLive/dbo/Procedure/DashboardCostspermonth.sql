/****** Object:  Procedure [dbo].[DashboardCostspermonth]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Changes:	Changed proc to use a rolling 12 month timeframe based on year and current month
-- Date			Name				Comments
-- 01/02/2018	Marc				Added logic for rolloing 12 months
-- 01/02/2018	PPetluri			Changed code to get minmaonthID and maxMonthID to fix slow running proc issues.
-- 05/16/2018	PPetluri			Added @CustID 
-- =============================================

CREATE PROCEDURE [dbo].[DashboardCostspermonth]
(
	@CustID	int,
	@Year int,
	@CostType varchar(30)	
)
AS
BEGIN

	SET @Year = 2018

	SET NOCOUNT ON;

	DECLARE @Month int = MONTH(GETDATE())

	DECLARE @Dates TABLE (ID INT IDENTITY(1,1), MonthID CHAR(6))

	DECLARE @LastMonth DATE = DATEFROMPARTS(@Year, @Month,'01'), @CurrentMonth DATE, @MinMonth varchar(6), @MaxMonth varchar(6)

	SET @CurrentMonth = DATEADD(MM, -11, @LastMonth)

	WHILE @LastMonth >= @CurrentMonth
	BEGIN

		INSERT INTO @Dates (MonthID)
		SELECT CAST(YEAR(@CurrentMonth) AS CHAR(4))+CASE WHEN LEN(MONTH(@CurrentMonth)) = 1 THEN '0'+CAST(MONTH(@CurrentMonth) AS CHAR(1)) ELSE CAST(MONTH(@CurrentMonth) AS CHAR(2)) END

		SET @CurrentMonth = DATEADD(MM, 1, @CurrentMonth)

	END
	Select @MinMonth = MIN(MonthID), @MaxMonth = MAX(MonthID) from @Dates
	--SELECT * FROM @Dates

	IF @CostType = 'RX'
	BEGIN
	SELECT MonthID, SUM([RX$]) as TotalRX$, COUNT(C.MVDID) as MemberCount, SUM([RX$]) / COUNT(C.MVDID) as AvgRx$PerMonth
	FROM Claim_Diag_Costs C JOIN Link_MemberId_MVD_Ins L ON L.MVDID = C.MVDID
	--JOIN MainPersonalDetails P ON P.ICENUMBER = REVERSE(SUBSTRING(REVERSE(ClaimNumber),9, LEN(ClaimNumber)))
	where L.Cust_ID = @CustID
	and C.MonthID  between @MinMonth and @MaxMonth--between CAST(@Year as varchar(6))+'01' and CAST(@Year as varchar(6))+'12'
	Group BY MonthID
	ORDER BY MonthID
	END

	IF @CostType = 'ER'
	BEGIN
	SELECT MonthID, SUM([Emergency$]) as TotalER$, COUNT(C.MVDID) as MemberCount, SUM([Emergency$]) / COUNT(C.MVDID) as AvgER$PerMonth
	FROM Claim_Diag_Costs C JOIN Link_MemberId_MVD_Ins L ON L.MVDID = C.MVDID
	where L.Cust_ID = @CustID
	and C.MonthID between @MinMonth and @MaxMonth --between CAST(@Year as varchar(6))+'01' and CAST(@Year as varchar(6))+'12'
	Group BY MonthID
	ORDER BY MonthID
	END

	IF @CostType = 'Disease'
	BEGIN
	Drop table if exists #TempResult
	Create table #TempResult
	(
		MonthID varchar(6),
		ParentLongDesc	varchar(1000),
		Total$	decimal(18,2),
		MemberCount int, 
		Avg$PerMonth	decimal(18,2)
	)

	Drop table If exists #Temp_Disease_Costs
	Create table #Temp_Disease_Costs
	(
		MVDID varchar(30),
		MonthID varchar(6),
		ParentCode varchar(30),
		Total$	decimal(18,2)
	)
	Insert into #Temp_Disease_Costs
	SELECT C.MVDID, C.MonthID, SUBSTRING(C.ParentCode, 1, CHARINDEX('-',C.ParentCode+'-', 1)-1), 
	SUM(ISNULL(Outpatient$,'0.00') + ISNULL(InPatient$, '0.00') + ISNULL(Emergency$, '0.00') + ISNULL(RX$, '0.00') + ISNULL(LAB$,'0.00') + ISNULL(Other$,'0.00')) as Total$
	FROM Claim_Diag_Costs C JOIN Link_MemberId_MVD_Ins L ON L.MVDID = C.MVDID
	where L.Cust_ID = @CustID
	and C.MonthID between @MinMonth and @MaxMonth --between CAST(@Year as varchar(6))+'01' and CAST(@Year as varchar(6))+'12' 
	Group BY C.MVDID, C.MonthID,C.ParentCode

	CREATE NONCLUSTERED INDEX [IX_NCI_Temp_Disease_Costs] ON #Temp_Disease_Costs
		([MonthID])
	INCLUDE ([MVDID],[ParentCode],[Total$])

	-- Total Cost per disease per month, Average cost per month
	INSERT INTO #TempResult
	SELECT C.MonthID, ICDH.ParentLongDesc, SUM(Total$) as Total$, COUNT(C.MVDID) as MemberCount, SUM(Total$) / COUNT(C.MVDID) as Avg$PerMonth
	FROM #Temp_Disease_Costs C 
	JOIN Lookup_ICD_TopHierarchy ICDH ON C.ParentCode = ICDH.ChildCode
	where C.MonthID  between @MinMonth and @MaxMonth --between CAST(@Year as varchar(6))+'01' and CAST(@Year as varchar(6))+'12'
	Group BY C.MonthID,ICDH.ParentLongDesc 
	ORDER BY C.MonthID,ICDH.ParentLongDesc 

	SELECT * FROM #TempResult ORDER BY MonthID

	Drop table #TempResult
	Drop table #Temp_Disease_Costs
	END

	If @CostType = 'Length of stay'
	BEGIN

	Drop table If Exists #Temp_AdmitDays
	Create table #Temp_AdmitDays
	(
		MVDID varchar(50),	
		MonthID varchar(6),
		AdmitDays int
	)

	INSERT INTO #Temp_AdmitDays
	Select distinct ICENUMBER, LEFT(REPLACE(CAST(ReportDate as date),'-',''),6) as MonthID, DateDIFF(Day,CASE WHEN AdmissionDate is null THEN DATEADD(Day, -1,DischargeDate) WHEN CONVERT(Date, AdmissionDate, 120) = CONVERT(Date, DischargeDate, 120) THEN DATEADD(Day, -1,DischargeDate)  ELSE AdmissionDate END,DischargeDate) as AdmitDays
	from MainCondition C JOIN Link_MemberId_MVD_Ins L ON L.MVDID = C.ICENUMBER
	Where --1=1-- COnvert(Date, ReportDate, 120) between @StartDate and @EndDate and
	  L.Cust_ID = @CustID
	and(POS in (21) OR CASE WHEN LEN(Billtype) = 3 and SUBSTRING('0'+BillType, 3,1) = 1 then 1  WHEN LEN(Billtype) > 3 and SUBSTRING(BillType, 3,1) = 1 then 1 ELSE 0 END  = 1)
	and DischargeDate is not null
	and LEFT(REPLACE(CAST(ReportDate as date),'-',''),6)  between @MinMonth and @MaxMonth 
	--and ICENUMBER = 'AA004484'--'AA035051'--'AM221275' --and CONVERT(Date, ReportDate, 120) = '2016-06-08' and recordNumber = 72734968
	ORDER BY 1,2

	SELECT T.MonthID, COUNT(T.MVDID) as MemberCount, SUM(AdmitDays) as TotalAdmitDays, SUM(AdmitDays)/ COUNT(T.MVDID) as AverageAdmitDays 
	,SUM(ISNULL(Outpatient$,'0.00') + ISNULL(InPatient$, '0.00') + ISNULL(Emergency$, '0.00') + ISNULL(RX$, '0.00') + ISNULL(LAB$,'0.00') + ISNULL(Other$,'0.00')) /COUNT(C.MVDID) as AvgCostStay$
	FROM #Temp_AdmitDays T JOIN Claim_Diag_Costs C ON C.MVDID = T.MVDID and C.MonthID = T.MonthID
	Group BY T.MONTHID
	ORDER BY T.MonthID

	Drop table If Exists #Temp_AdmitDays
	END

	IF @CostType = 'Cost of care'
	BEGIN
	SELECT C.MonthID, COUNT(C.MVDID) as MemberCount, 
	SUM(ISNULL(Outpatient$,'0.00') + ISNULL(InPatient$, '0.00') + ISNULL(Emergency$, '0.00') + ISNULL(RX$, '0.00') + ISNULL(LAB$,'0.00') + ISNULL(Other$,'0.00')) as Total$,
	SUM(ISNULL(Outpatient$,'0.00') + ISNULL(InPatient$, '0.00') + ISNULL(Emergency$, '0.00') + ISNULL(RX$, '0.00') + ISNULL(LAB$,'0.00') + ISNULL(Other$,'0.00')) /COUNT(C.MVDID) as AvgCostStay$
	FROM Claim_Diag_Costs C   JOIN Link_MemberId_MVD_Ins L ON L.MVDID = C.MVDID
	Where L.Cust_ID = @CustID
	and C.MonthID  between @MinMonth and @MaxMonth --between CAST(@Year as varchar(6))+'01' and CAST(@Year as varchar(6))+'12'
	Group BY C.MONTHID
	ORDER BY C.MonthID
	END

	IF @CostType = 'Cost per measure'
	BEGIN
	Select C.MonthID, HS.Abbreviation,
	SUM(ISNULL(Outpatient$,'0.00') + ISNULL(InPatient$, '0.00') + ISNULL(Emergency$, '0.00') + ISNULL(RX$, '0.00') + ISNULL(LAB$,'0.00') + ISNULL(Other$,'0.00')) as Total$,
	COUNT(C.MVDID) as MemberCount,
	SUM(ISNULL(Outpatient$,'0.00') + ISNULL(InPatient$, '0.00') + ISNULL(Emergency$, '0.00') + ISNULL(RX$, '0.00') + ISNULL(LAB$,'0.00') + ISNULL(Other$,'0.00')) / COUNT(C.MVDID) as Avg$PerMonth
	from Claim_Diag_Costs C  JOIN Final_HEDIS_Member_Full F ON C.MVDID = F.MVDID and C.MonthID = F.MonthID
	JOIN HedisSubmeasures HS ON HS.ID = F.TestID
	Where F.CustID = @CustID
	and C.MonthID  between @MinMonth and @MaxMonth -- between  CAST(@Year as varchar(6))+'01' and CAST(@Year as varchar(6))+'12'
	GROUP BY C.MonthID, HS.Abbreviation
	ORDER BY C.MonthID
	END

	IF @CostType = 'POS'
	BEGIN
	Select C.MonthID, POS.[Name] as PlaceOfService,
		SUM(ISNULL(Outpatient$,'0.00') + ISNULL(InPatient$, '0.00') + ISNULL(Emergency$, '0.00') + ISNULL(RX$, '0.00') + ISNULL(LAB$,'0.00') + ISNULL(Other$,'0.00')) as Total$,
		COUNT(C.MVDID) as MemberCount,
		CAST(SUM(ISNULL(Outpatient$,'0.00') + ISNULL(InPatient$, '0.00') + ISNULL(Emergency$, '0.00') + ISNULL(RX$, '0.00') + ISNULL(LAB$,'0.00') + ISNULL(Other$,'0.00')) / COUNT(C.MVDID) as decimal(18,2)) as Avg$PerMonth
	from Claim_Diag_Costs C   JOIN Link_MemberId_MVD_Ins L ON L.MVDID = C.MVDID
	JOIN MainCondition F ON C.MVDID = F.ICENUMBER  and C.ServiceDate = F.REPORTDATE
	JOIN LookupPOS POS ON CAST(POS.ID as Varchar(10)) = CAST(F.POS as varchar(10))
	Where L.Cust_ID = @CustID
	and C.MonthID  between @MinMonth and @MaxMonth-- between  CAST(@Year as varchar(6))+'01' and CAST(@Year as varchar(6))+'12'
	GROUP BY C.MonthID, POS.[Name]
	ORDER BY C.MonthID
	END

END