/****** Object:  Procedure [dbo].[GetBabyActivityReportData]    Committed by VersionSQL https://www.versionsql.com ******/

/*Created : snokku
Date : 28/10*/


CREATE PROCEDURE [dbo].[GetBabyActivityReportData]
@DBNAME varchar(100),
@SDate Datetime =null,
@EDate Datetime =null,
@MaternityProgramType Varchar(50),
@LOB Varchar(20)=null,
@CompanyKey Varchar(50)=null
AS

BEGIN

SET NOCOUNT ON 

DECLARE  @SQL VARCHAR (1000),
@sqlSelect Nvarchar(Max),@sqlfrom Nvarchar(Max),@SqlWhere NVARCHAR(Max) = ''



--,@DBNAME varchar(100)  
--,@LOB varchar(20)
--,@CompanyKey Varchar(50)
--set @DBNAME ='MyVitalDataDemo_BK_From_Live' 
--set @LOB='US'
--SET @CompanyKey='20707'
--Customer =10Insurance P



IF OBJECT_ID('TempDB.dbo.#Temp_BabyData','U') is not null
DROP TABLE #Temp_BabyData
Create Table #Temp_BabyData
(
	MemberFirstName Varchar(50)
,MemberLastName Varchar(50)
,MemberID Varchar(50)
,LOB Varchar(50)
,Company_Name Varchar(50)
,ReferralDate Datetime
,UTCReferralDate Datetime
,ReferralID Varchar(20)
,ReferralSource Varchar(50)
,ReferralReason Varchar(50)
,MostRecentContactDate Datetime
,ASQ3Flag Varchar(30)
,NeonatalPacketFlag Varchar(30)
,Birthto1yrPacketFlag Varchar(30)
,CaseOpenedDate  Datetime
,CaseOwner Varchar(30)
,NonViableReason Varchar(400)
,NonviableReasonDate Datetime
,EligibleCount INT
,InEligibleCount INT
,CaseOpenedCount int
,ASQ3MailingCount int
,NeonatalMailingCount int
,Birthto1yrMailingCount int
)

SET @sqlSelect = ' SELECT DISTINCT FM.MemberFirstName 
	,FM.MemberLastName 
    ,FM.MemberID
	,FM.LOB
	,C.company_name 
	,MMF.ReferralDate
	,dbo.[ConvertUTCtoCT](ReferralDate) as UTCReferralDate
	,MMF.ReferralID
	,MMF.ReferralSource 
	,MMF.ReferralReason
	,CASE WHEN CTC.MVDID IS NOT NULL THEN dbo.[ConvertUTCtoCT](CTC.ContactDate) ELSE NULL END AS MostRecentContactDate
	,CASE WHEN ASQ3.MVDID IS NOT NULL THEN ''Yes'' ELSE NULL END AS ASQ3Flag  	
	,CASE WHEN Neo.MVDID IS NOT NULL THEN ''Yes'' ELSE NULL END AS NeonatalPacketFlag 
	,CASE WHEN Birth.MVDID IS NOT NULL THEN ''Yes'' ELSE NULL END AS Birthto1yrPacketFlag  
	,CASE WHEN MMF.q1CaseCreateDate <> ''19000101'' THEN dbo.[ConvertUTCtoCT](MMF.q1CaseCreateDate) ELSE NULL END  
	,MMF.q1caseowner
	,MMF.qNonViableReason1 AS NonViableReason		
	,CASE WHEN MMF.qNonViableReason1 = '''' THEN NULL ELSE dbo.[ConvertUTCtoCT](MMF.FormDate) END AS NonviableReasonDate	
	,CASE WHEN MMF.qNonViableReason1 IN (''Member/family refused case management'',''Unable to reach member'') OR MMF.qNonViableReason1='''' OR MMF.qNonViableReason1 IS NULL 
		  THEN 1 ELSE 0 END AS EligibleCount	   
	,CASE WHEN MMF.qNonViableReason1 IN ( ''Member expired'', ''Member ineligible for policy benefits/policy termed'')
		  THEN 1 ELSE 0 END AS InEligibleCount	   
	,CASE WHEN MMF.q1CaseCreateDate  <> ''19000101'' THEN 1 ELSE 0 END CaseOpenedCount 
	,CASE WHEN ASQ3.MVDID IS NOT NULL THEN 1 ELSE 0 END AS ASQ3MailingCount
	,CASE WHEN Neo.MVDID IS NOT NULL THEN 1 ELSE 0 END AS NeonatalMailingCount 
	,CASE WHEN Birth.MVDID IS NOT NULL THEN 1 ELSE 0 END AS Birthto1yrMailingCount   '

 SET @sqlfrom ='
	
	FROM ' + @DBNAME + '.dbo.ABCBS_MemberManagement_Form MMF
LEFT OUTER JOIN ' + @DBNAME + '.dbo.FinalMember FM ON FM.MVDID = MMF.MVDID
LEFT OUTER JOIN (SELECT DISTINCT MVDID, MAX(q1ContactDate) AS ContactDate FROM ' + @DBNAME + '.dbo.ARBCBS_Contact_Form GROUP BY MVDID) CTC ON CTC.MVDID = FM.MVDID
LEFT OUTER JOIN (SELECT DISTINCT MVDID FROM ' + @DBNAME + '.dbo.[ARBCBS_Contact_Form] WHERE q2program=''Maternity'' AND qMaternityMember=''Baby'' AND qMemMailing LIKE ''%ASQ3%'') ASQ3 ON ASQ3.MVDID = FM.MVDID
LEFT OUTER JOIN (SELECT DISTINCT MVDID FROM ' + @DBNAME + '.dbo.[ARBCBS_Contact_Form] WHERE q2program=''Maternity'' AND qMaternityMember=''Baby'' AND qMemMailing LIKE ''%Neonatal%'') Neo ON Neo.MVDID = FM.MVDID
LEFT OUTER JOIN (SELECT DISTINCT MVDID FROM ' + @DBNAME + '.dbo.[ARBCBS_Contact_Form] WHERE q2program=''Maternity'' AND qMaternityMember=''Baby'' AND qMemMailing LIKE ''%Birth%'') Birth ON Birth.MVDID = FM.MVDID
LEFT OUTER JOIN ' + @DBNAME + '.dbo.[LookupCompanyName] C on FM.CompanyKey=C.company_key

'

IF @MaternityProgramType =1
SET @SqlWhere = @SqlWhere + 'MMF.ReferralReason=''Maternity - Baby'' AND FM.CmOrgRegion  in (''WALMART'')
and dbo.[ConvertUTCtoCT](ReferralDate) BETWEEN ''' + CONVERT(VARCHAR, @SDATE) + ''' AND ''' + CONVERT(VARCHAR, @EDATE) + '''
 '
IF @MaternityProgramType =2
SET @SqlWhere = @SqlWhere + 'MMF.ReferralReason=''Maternity - Baby'' AND FM.CmOrgRegion  in (''Tyson'') 
and dbo.[ConvertUTCtoCT](ReferralDate) BETWEEN ''' + CONVERT(VARCHAR, @SDATE) + ''' AND ''' + CONVERT(VARCHAR, @EDATE) + '''
 '

IF @MaternityProgramType =3
SET @SqlWhere = @SqlWhere + 'MMF.ReferralReason=''Maternity - Baby''
AND FM.LOB= ''' +@LOB+'''
AND C.company_key= ''' +@CompanyKey+'''
AND FM.CmOrgRegion not in (''Tyson'',''WALMART'')
and dbo.[ConvertUTCtoCT](ReferralDate) BETWEEN ''' + CONVERT(VARCHAR, @SDATE) + ''' AND ''' + CONVERT(VARCHAR, @EDATE) + '''
'
INSERT INTO #Temp_BabyData
exec(@sqlSelect+@sqlfrom+' Where '+@SqlWhere)

--print (@sqlSelect+@sqlfrom+' Where '+@SqlWhere)

SELECT * FROM #Temp_BabyData ORDER BY MemberLastName, MemberFirstName asc
END