/****** Object:  Procedure [dbo].[uspPopulateMonthlyEligibilityCount]    Committed by VersionSQL https://www.versionsql.com ******/

/*
 Author:		Sunil Nokku
 Create date:	2021-10-15
 Description:	Calculate Eligibility Per Month for Past 15 Months.

Exec uspPopulateMonthlyEligibilityCount

Select Top 100 * From EligMonth

Modified		Modified By		Details

*/

CREATE Procedure [dbo].[uspPopulateMonthlyEligibilityCount]
As
Begin

	DECLARE 
	@v_StartDate date,
	@v_EndDate	 date
	
	Select @v_StartDate = DATEADD(mm,-15,getdate())
	Select @v_EndDate = getdate()

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

	Truncate Table EligMonth

	;WITH Elig AS
	(
	SELECT 
		MVDID,
		LOB,
		CompanyKey,
		CmOrgRegion,
		MemberEffectiveDate,
		MemberTerminationDate
	FROM finaleligibility fe (readuncommitted)
	),
	EligPerMonth AS
	(
	SELECT 
		lm.monthid as MonthID,
		fe.MVDID as MVDID,
		fe.LOB as LOB,
		fe.CompanyKey as CompanyKey,
		fe.CmOrgRegion as CmOrgRegion,
		CASE
		WHEN fe.MemberEffectiveDate BETWEEN lm.StartDate AND lm.EndDate THEN 1
		WHEN fe.MemberTerminationDate BETWEEN lm.StartDate AND lm.EndDate THEN 1
		WHEN fe.MemberEffectiveDate <= lm.StartDate AND ISNULL( fe.MemberTerminationDate, '' ) = '' THEN 1
		WHEN fe.MemberEffectiveDate <= lm.StartDate AND fe.MemberTerminationDate >= lm.EndDate THEN 1
		ELSE 0
		END AS Active
	FROM Elig fe (readuncommitted)
		INNER JOIN #ListMonth lm on 1=1
	) 
	Insert Into EligMonth
	SELECT monthid,
		LOB,
		CompanyKey,
		CmOrgRegion,
		Count( MVDID) AS MemCount
	FROM EligPerMonth 
	WHERE Active=1
	GROUP BY 
		MonthID,
		LOB,
		CompanyKey,
		CmOrgRegion

End;