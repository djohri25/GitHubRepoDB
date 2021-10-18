/****** Object:  Procedure [dbo].[GetCaseLoadReportData]    Committed by VersionSQL https://www.versionsql.com ******/

/*
CREATEd by : Sunil Nokku
Date: 11/14/2019
Modified : 04/30/2020

Modified: 08/17/2020 - Sunil Nokku - Add conditions to avoid Void cases. ( TFS 3387, 3319 )
07/26/2021 - Bhupinder Singh - #5718 Add new columns PlanType & LOB
08/24/2021 - Bhupinder Singh - #5994 Handle 'ALL' as company name and company key

EXEC GetCaseLoadReportData 'MyVitalDataLive',@CM_ORG_REGION ='ABB,ABCBS,ARSTATEPOLICE,ASEPSE,BARB_EAST,BARB_WEST,BRYCE,EXCHNG,FEP,HA,HAEXCHNG,JBHUNT,MEDICAREADV,SIMMONS_BANK,TYSON,USAA,USAM,WALMART',
--@CompanyKey ='371',
--@CompanyName ='SOUTHERN CAST PRODUCTS                                                                              ',
@CaseProgram ='CASE MANAGEMENT,CHRONIC CONDITION MANAGEMENT,CLINICAL SUPPORT,MATERNITY,SOCIAL WORK',
@Auditable ='ALL',
--@CaseOwner ='CCSTANFIELD', 
@ReportType =1,@p_start_date  ='20210601',
@p_end_date  ='20210726' --12,476

*/

CREATE PROCEDURE [dbo].[GetCaseLoadReportData](
		@DBNAME varchar(100),
		@CM_ORG_REGION varchar(8000)=null,
		@CompanyKey Varchar(100)=null,
		@CompanyName Varchar(max)=null,
		@CaseProgram varchar(max)=null,
		@Auditable varchar(max)=null,
		@CaseOwner varchar(max)=null, 
		@ReportType varchar(50)=null,
		@p_start_date Datetime =null,
		@p_end_date Datetime =null)

as
BEGIN

SET NOCOUNT ON;

DECLARE @v_today datetime ,
		@v_start_date datetime ,
		@v_end_date datetime,
		@SqlSelect nvarchar(max),
		@SqlCmOrgRegion NVARCHAR(Max) ='',
		@SqlCaseProgram NVARCHAR(Max) = '',
		@SqlCaseOwner NVARCHAR(Max) = '',
		@SqlAudiTable NVARCHAR(Max) = '',
		@SqlWhere2 NVARCHAR(Max) = ''

--SET @CompanyName = Replace(@CompanyName,'''','')

IF (@p_start_date IS NOT NULL AND @p_end_date IS NOT NULL)
BEGIN
	SET @v_start_date = @p_start_date
	SET @v_end_date = CAST(@p_end_date AS date)
END

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
    WHERE DATEADD(DAY,1,EOMONTH(DATEADD(MONTH,1,date),-1)) <= @v_end_date
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
	CASE_ID varchar(20),
	CASE_PROGRAM varchar(500),
	CASE_CATEGORY varchar(500),
	CASE_TYPE varchar(500),
	CHRONIC_INDICATOR varchar(3),
	MEMBER_ID varchar(100),
	MBR_F_NAME varchar(500),
	MBR_M_NAME varchar(500),
	MBR_L_NAME varchar(500),
	CASE_OWNER varchar(500),
	CASE_CREATE_DATE datetime,
	CASE_CLOSE_DATE datetime,
	CASE_CLOSE_REASON varchar(max),
	CASE_AGE int,
	CASE_STATUS varchar(10),
	REFERRAL_SOURCE varchar(max),--Non-Viable reason is “Case Conversion” should be excluded
	REFERRAL_REASON varchar(max),
	CM_ORG_REGION varchar(100),
	MEMBER_KEY varchar(500),
	COMPANY_KEY varchar(1000),
	COMPANY_NAME varchar(1000),
	MonthName varchar(20),
	CMStartDate datetime,
	CMEndDate datetime,
	MVDID varchar(100),
	CarePlanID varchar(10),
	CPIActivated varchar(2),
	CasesCreatedInDateRange int,
	CasesClosedInDateRange int,
	CasesActiveInDateRange int,
	CasesActiveAtDateRangeEnd int,
	IsAuditable int,
	IsPending int,
	PlanType varchar(255),
	LOB varchar(255)
)

INSERT INTO #MMFCases
SELECT DISTINCT
	MMF.CaseID CASE_ID,
	MMF.CaseProgram CASE_PROGRAM,
	MMF.q5CaseCategory  CASE_CATEGORY,
	MMF.q5CaseType CASE_TYPE,
	CASE WHEN ISNULL(q3CaseManagedBy,'')!=''
	THEN 
		CASE WHEN q3CaseManagedBy = 'Yes' 
		THEN 'Y'
		ELSE 'N'
		END
	ELSE 
		CASE WHEN q5ConsentMemberManaged ='Yes'
		THEN 'Y'
		ELSE 'N'
		END
	END CHRONIC_INDICATOR,
	FM.MemberID MEMBER_ID,
	FM.MemberFirstName MBR_F_NAME,
	FM.MemberMiddleName MBR_M_NAME,
	FM.MemberLastName MBR_L_NAME,
	MMF.q1CaseOwner CASE_OWNER,
	MMF.q1CaseCreateDate CASE_CREATE_DATE,
	CASE WHEN ISNULL(MMF.q1CaseCloseDate,'')='' OR MMF.q1CaseCloseDate = '1900-01-01 00:00:00.000'
	     THEN NULL
		 ELSE MMF.q1CaseCloseDate 
		 END CASE_CLOSE_DATE,
	MMF.q2CloseReason CASE_CLOSE_REASON,
	CASE WHEN ISNULL(MMF.q1CaseCloseDate,'')='' OR MMF.q1CaseCloseDate = '1900-01-01 00:00:00.000'
          THEN DATEDIFF(d,MMF.q1CaseCREATEDate,CONVERT(VARCHAR,GETDATE(),23)) + 1 
          ELSE DATEDIFF(d,MMF.q1CaseCREATEDate,MMF.q1CaseCloseDate) + 1
          END as CASE_AGE,
	CASE WHEN ISNULL(MMF.q1CaseCloseDate,'')='' OR MMF.q1CaseCloseDate = '1900-01-01 00:00:00.000' 
		  THEN 'Active' 
		  ELSE 'Closed' 
		  END  as CASE_STATUS,
	MMF.ReferralSource REFERRAL_SOURCE,
	MMF.ReferralReason REFERRAL_REASON,
	FM.CmOrgRegion CM_ORG_REGION,
	FM.MemberKey MEMBER_KEY,
	FM.CompanyKey COMPANY_KEY,
	Replace(C.company_name,'''','') COMPANY_NAME,
	CM.Name MonthName,
	CM.StartDate,
	CM.EndDate,
	MMF.MVDID,
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
	END IsPending,
	CASE WHEN IH.PlanIdentifier='H9699' AND IH.BenefitGroup IN (004,001,002,003) THEN 'Health Advantage Blue Classic (HMO)'
			WHEN IH.PlanIdentifier='H9699'  AND IH.BenefitGroup IN (006)			  THEN 'Health Advantage Blue Premier (HMO)'
			WHEN IH.PlanIdentifier='H4213'  AND IH.BenefitGroup IN (016,001,003,004) THEN 'BlueMedicare Value (PFFS)'
			WHEN IH.PlanIdentifier='H4213'  AND IH.BenefitGroup IN (017,001,005,006) THEN 'BlueMedicare Preferred (PFFS)'
			WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (001,002)		  THEN 'BlueMedicare Saver Choice (PPO)'
			WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (003,004,005,006) THEN 'BlueMedicare Value Choice (PPO)'
			WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (007,008,009,010) THEN 'BlueMedicare Premier Choice (PPO)'
			WHEN IH.PlanIdentifier='H6158'  AND IH.BenefitGroup IN (001,002)		  THEN 'BlueMedicare Premier (PPO)'
	ELSE NULL 
	END  AS PlanType,
	FM.LOB
	FROM dbo.ABCBS_MemberManagement_Form MMF
	INNER JOIN FinalMember fm
	ON fm.MVDID = MMF.MVDID
	INNER JOIN #ListMonth CM
	ON 1 = 1
	INNER JOIN dbo.LookupCompanyName C on FM.CompanyKey=C.company_key
	LEFT OUTER JOIN dbo.MainCarePlanMemberIndex CPI
	ON CPI.CaseID = MMF.CaseID
	LEFT OUTER JOIN dbo.MainCarePlanMemberProblems CPP ON CPP.[CarePlanID] = CPI.[CarePlanID]
	LEFT OUTER JOIN dbo.MainCarePlanMemberGoals CPG ON CPG.[GoalNum] = CPP.[problemNum]
	LEFT OUTER JOIN dbo.MainCarePlanMemberInterventiONs CPN ON CPN.[GoalID] = CPG.[GoalNum]
	LEFT OUTER JOIN dbo.MainCarePlanMemberOutcomes CPO ON CPO.[ProblemID] = CPP.[problemNum]
	LEFT JOIN [dbo].[FinalEligibility] IH (readuncommitted) 
		ON mmf.MVDID = IH.MVDID 
		AND IsNull(IH.FakeSpanInd,'N') != 'Y' 
		and IsNull(IH.SpanVoidInd,'N') != 'Y'
		And mmf.[q1CaseCreateDate] Between MemberEffectiveDate AND MemberTerminationDate
	WHERE LEN(MMF.CaseID) >= 1
	AND CONVERT(DATE, MMF.[q1CaseCreateDate]) < @v_end_date + 1
	AND
	CASE
	WHEN MMF.q1CaseCloseDate >= @v_start_date THEN 1
	WHEN ISNULL( MMF.q1CaseCloseDate, '' ) = '' THEN 1
	ELSE 0
	END = 1
	--AND MMF.q2CONsentDate <> '1900-01-01'    --TFS 3387
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
	CaseProgram,
	CM.StartDate

IF OBJECT_ID('tempdb..#MMFCasesActive') IS NOT NULL DROP TABLE #MMFCasesActive

CREATE TABLE #MMFCasesActive (
	CASE_ID varchar(20),
	CASE_PROGRAM varchar(500),
	CASE_CATEGORY varchar(500),
	CASE_TYPE varchar(500),
	CHRONIC_INDICATOR varchar(3),
	MEMBER_ID varchar(100),
	MBR_F_NAME varchar(500),
	MBR_M_NAME varchar(500),
	MBR_L_NAME varchar(500),
	CASE_OWNER varchar(500),
	CASE_CREATE_DATE datetime,
	CASE_CLOSE_DATE datetime,
	CASE_CLOSE_REASON varchar(max),
	CASE_AGE int,
	CASE_STATUS varchar(10),
	REFERRAL_SOURCE varchar(max),--Non-Viable reason is “Case Conversion” should be excluded
	REFERRAL_REASON varchar(max),
	CM_ORG_REGION varchar(100),
	MEMBER_KEY varchar(500),
	COMPANY_KEY varchar(1000),
	COMPANY_NAME varchar(1000),
	IsAuditable int,
	IsPending int,
	PlanType Varchar(255),
	LOB varchar(255)
)

INSERT INTO #MMFCasesActive
SELECT DISTINCT
	MMF.CaseID CASE_ID,
	MMF.CaseProgram CASE_PROGRAM,
	MMF.q5CaseCategory  CASE_CATEGORY,
	MMF.q5CaseType CASE_TYPE,
	CASE WHEN ISNULL(q3CaseManagedBy,'')!=''
	THEN 
		CASE WHEN q3CaseManagedBy = 'Yes' 
		THEN 'Y'
		ELSE 'N'
		END
	ELSE 
		CASE WHEN q5ConsentMemberManaged ='Yes'
		THEN 'Y'
		ELSE 'N'
		END
	END CHRONIC_INDICATOR,
	FM.MemberID MEMBER_ID,
	FM.MemberFirstName MBR_F_NAME,
	FM.MemberMiddleName MBR_M_NAME,
	FM.MemberLastName MBR_L_NAME,
	MMF.q1CaseOwner CASE_OWNER,
	MMF.q1CaseCreateDate CASE_CREATE_DATE,
	CASE WHEN ISNULL(MMF.q1CaseCloseDate,'')='' OR MMF.q1CaseCloseDate = '1900-01-01 00:00:00.000'
	     THEN NULL
		 ELSE MMF.q1CaseCloseDate 
		 END CASE_CLOSE_DATE,
	MMF.q2CloseReason CASE_CLOSE_REASON,
	CASE WHEN ISNULL(MMF.q1CaseCloseDate,'')='' OR MMF.q1CaseCloseDate = '1900-01-01 00:00:00.000'
          THEN DATEDIFF(d,MMF.q1CaseCREATEDate,CONVERT(VARCHAR,GETDATE(),23)) + 1 
          ELSE DATEDIFF(d,MMF.q1CaseCREATEDate,MMF.q1CaseCloseDate) + 1
          END as CASE_AGE,
	CASE WHEN ISNULL(MMF.q1CaseCloseDate,'')='' OR MMF.q1CaseCloseDate = '1900-01-01 00:00:00.000' 
		  THEN 'Active' 
		  ELSE 'Closed' 
		  END  as CASE_STATUS,
	MMF.ReferralSource REFERRAL_SOURCE,
	MMF.ReferralReason REFERRAL_REASON,
	FM.CmOrgRegion CM_ORG_REGION,
	FM.MemberKey MEMBER_KEY,
	FM.CompanyKey COMPANY_KEY,
	Replace(C.company_name,'''','') COMPANY_NAME,
	CASE
	WHEN CPI.Activated = '1' THEN 1
	ELSE 0
	END IsAuditable,
	CASE
	WHEN MMF.CarePlanID IS NULL THEN 1
	WHEN CPI.CaseID IS NULL THEN 1
	ELSE 0
	END IsPending,
	CASE WHEN IH.PlanIdentifier='H9699' AND IH.BenefitGroup IN (004,001,002,003) THEN 'Health Advantage Blue Classic (HMO)'
			WHEN IH.PlanIdentifier='H9699'  AND IH.BenefitGroup IN (006)			  THEN 'Health Advantage Blue Premier (HMO)'
			WHEN IH.PlanIdentifier='H4213'  AND IH.BenefitGroup IN (016,001,003,004) THEN 'BlueMedicare Value (PFFS)'
			WHEN IH.PlanIdentifier='H4213'  AND IH.BenefitGroup IN (017,001,005,006) THEN 'BlueMedicare Preferred (PFFS)'
			WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (001,002)		  THEN 'BlueMedicare Saver Choice (PPO)'
			WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (003,004,005,006) THEN 'BlueMedicare Value Choice (PPO)'
			WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (007,008,009,010) THEN 'BlueMedicare Premier Choice (PPO)'
			WHEN IH.PlanIdentifier='H6158'  AND IH.BenefitGroup IN (001,002)		  THEN 'BlueMedicare Premier (PPO)'
	ELSE NULL 
	END  AS PlanType,
	FM.LOB
	FROM dbo.ABCBS_MemberManagement_Form MMF
	INNER JOIN FinalMember fm
	ON fm.MVDID = MMF.MVDID
	INNER JOIN dbo.LookupCompanyName C on FM.CompanyKey=C.company_key
	LEFT OUTER JOIN dbo.MainCarePlanMemberIndex CPI
	ON CPI.CaseID = MMF.CaseID
	LEFT OUTER JOIN dbo.MainCarePlanMemberProblems CPP ON CPP.[CarePlanID] = CPI.[CarePlanID]
	LEFT OUTER JOIN dbo.MainCarePlanMemberGoals CPG ON CPG.[GoalNum] = CPP.[problemNum]
	LEFT OUTER JOIN dbo.MainCarePlanMemberInterventiONs CPN ON CPN.[GoalID] = CPG.[GoalNum]
	LEFT OUTER JOIN dbo.MainCarePlanMemberOutcomes CPO ON CPO.[ProblemID] = CPP.[problemNum]
	LEFT JOIN [dbo].[FinalEligibility] IH (readuncommitted) 
		ON mmf.MVDID = IH.MVDID 
		AND IsNull(IH.FakeSpanInd,'N') != 'Y' 
		and IsNull(IH.SpanVoidInd,'N') != 'Y'
		And mmf.[q1CaseCreateDate] Between MemberEffectiveDate AND MemberTerminationDate
	WHERE LEN(MMF.CaseID) >= 1
	AND MMF.q2CONsentDate <> '1900-01-01'
	AND (ISNULL(mmf.q1CaseCloseDate,'')='' OR mmf.q1CaseCloseDate = '1900-01-01 00:00:00.000')

IF( @ReportType = 1 OR @ReportType =2 OR @ReportType = 3)
BEGIN
	SET @SqlSelect = 'SELECT DISTINCT CASE_ID,
					 CASE_PROGRAM,
					 ISNULL(CASE_CATEGORY,''NULL'') AS CASE_CATEGORY,
					 ISNULL(CASE_TYPE,''NULL'') AS CASE_TYPE,
					 CASE WHEN IsAuditable =1 THEN ''Y'' WHEN IsPending = 1 THEN ''N'' END AS AUDITABLE,
					 CHRONIC_INDICATOR,
					 MEMBER_ID,
					 MBR_F_NAME,
					 MBR_M_NAME,
					 MBR_L_NAME,
					 CASE_OWNER,
					 CASE_CREATE_DATE,
					 CASE_CLOSE_DATE,
					 ISNULL(CASE_CLOSE_REASON,''NULL'') AS CASE_CLOSE_REASON,
					 CASE_AGE,
					 CASE_STATUS,
					 REFERRAL_SOURCE,
					 REFERRAL_REASON,
					 CM_ORG_REGION,
					 MEMBER_KEY,
					 COMPANY_KEY,
					 COMPANY_NAME,
					 PlanType,
					 LOB
				 FROM #MMFCases 
				 WHERE'
END
ELSE 
BEGIN
	SET @SqlSelect = 'SELECT DISTINCT CASE_ID,
					 CASE_PROGRAM,
					 ISNULL(CASE_CATEGORY,''NULL'') AS CASE_CATEGORY,
					 ISNULL(CASE_TYPE,''NULL'') AS CASE_TYPE,
					 CASE WHEN IsAuditable =1 THEN ''Y'' WHEN IsPending = 1 THEN ''N'' END AS AUDITABLE,
					 CHRONIC_INDICATOR,
					 MEMBER_ID,
					 MBR_F_NAME,
					 MBR_M_NAME,
					 MBR_L_NAME,
					 CASE_OWNER,
					 CASE_CREATE_DATE,
					 CASE_CLOSE_DATE,
					 ISNULL(CASE_CLOSE_REASON,''NULL'') AS CASE_CLOSE_REASON,
					 CASE_AGE,
					 CASE_STATUS,
					 REFERRAL_SOURCE,
					 REFERRAL_REASON,
					 CM_ORG_REGION,
					 MEMBER_KEY,
					 COMPANY_KEY,
					 COMPANY_NAME,
					 PlanType,
					 LOB
					 FROM #MMFCasesActive WHERE'
END
	
IF(@CM_ORG_REGION IS NOT NULL)
SET @SqlSelect = @SqlSelect + ' 
								CM_ORG_REGION  in (select VALUE from dbo.SplitStringVal('''+@CM_ORG_REGION+''','','')) AND'
IF(@CompanyKey IS NOT NULL AND @CompanyKey != 'ALL')
SET @SqlSelect = @SqlSelect + '
								COMPANY_KEY= ''' +@CompanyKey+''' AND'
IF(@CompanyName IS NOT NULL AND @CompanyName != 'ALL')
SET @SqlSelect = @SqlSelect + '
								COMPANY_NAME = ''' +@CompanyName+''' AND'
IF(@CaseProgram IS NOT NULL)
SET @SqlSelect = @SqlSelect + ' 
								CASE_PROGRAM in (select VALUE from dbo.SplitStringVal('''+@CaseProgram+''','','')) AND'
IF(select VALUE from dbo.SplitStringVal(@AudiTABLE,',')) = 'Y'
SET @SqlSelect = @SqlSelect + ' 
								IsAuditable = 1 AND'
IF(select VALUE from dbo.SplitStringVal(@AudiTABLE,',')) = 'N'
SET @SqlSelect = @SqlSelect + ' 
								IsPending = 1 AND'
IF(select VALUE from dbo.SplitStringVal(@AudiTABLE,',')) = 'B'
SET @SqlSelect = @SqlSelect + ''

IF(@CaseOwner IS NOT NULL)
SET @SqlSelect = @SqlSelect + ' 
								CASE_OWNER in (select VALUE from dbo.SplitStringVal('''+@CaseOwner+''','','')) AND'

--Cases Active In Date Range
IF @ReportType =1
SET @SqlSelect = @SqlSelect + ' 
								CasesActiveInDateRange = 1'

--Cases Created in Date Range 
IF @ReportType =2
SET @SqlSelect = @SqlSelect + ' 
								CasesCreatedInDateRange = 1'

--Cases Closed in Date Range
IF @ReportType =3
SET @SqlSelect = @SqlSelect + ' 
								CasesClosedInDateRange = 1'

--Active Cases
IF @ReportType =4
SET @SqlSelect = @SqlSelect + ' 1=1 '

print @sqlSelect
EXEC(@sqlSelect)

END