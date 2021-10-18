/****** Object:  Procedure [dbo].[Report_MembershipInPrograms]    Committed by VersionSQL https://www.versionsql.com ******/

/*
 Author:		Sunil Nokku
 Create date:	2021-08-12
 Description:	Membership In Programs

Modified		Modified By		Details
2021-08-17		Sunil Nokku		Add Supervisor from aspnet tables

EXEC Report_MembershipInPrograms @StartDate = '20210101', @EndDate = '20210816'
*/

CREATE PROCEDURE [dbo].[Report_MembershipInPrograms]
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
	--DECLARE
	--	@StartDate			date='20210101',
	--	@EndDate			date='20210801',
	--	@YTD				bit,
	--	@OnlyAuditable		bit = 0,
	--	@LOB				varchar(MAX)='ALL',
	--	@CmOrgRegion		varchar(MAX)='ALL',
	--	@CompanyKey			varchar(MAX)='ALL',
	--	@CaseProgram		varchar(MAX)='ALL',
	--	@CaseManager		varchar(MAX) 

	IF (@YTD = 1)
	BEGIN
		SET @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
		SET @enddate = DATEADD(dd,-1,CAST(GETDATE() AS DATE))
	END
	
	;WITH CPUsers AS (
		SELECT DISTINCT ID, UserName, FirstName, LastName 
			FROM AspNetUsers (readuncommitted)
	), CPUserInfo AS (
		SELECT DISTINCT UserID,Department,Supervisor 
			FROM AspNetUserInfo (readuncommitted)
	), MMF_programs AS
		(
			SELECT ANI.Supervisor,
				mmf.MVDID,
				coalesce(mmf.q4CaseProgram,mmf.CaseProgram) as CaseProgram,
				ccq.CompanyName,
				ccq.LOB,
				ccq.CmOrgRegion
			FROM abcbs_membermanagement_form (readuncommitted) mmf
				INNER JOIN ComputedCareQueue ccq (readuncommitted) ON ccq.MVDID = mmf.MVDID
				INNER JOIN CPusers AN ON AN.UserName = mmf.q1CaseOwner
				INNER JOIN CPuserInfo ANI on AN.ID = ANI.UserID
			WHERE mmf.[q1CaseCreateDate] BETWEEN @startdate and @enddate
				AND ((@LOB = 'ALL') or (CHARINDEX(ccq.[LOB], @LOB) > 0))
				AND ((@CmOrgRegion = 'ALL') or (CHARINDEX(ccq.[CmOrgRegion], @CmOrgRegion) > 0))
				AND ((@CaseProgram = 'ALL') or (CHARINDEX(mmf.[q4CaseProgram], @CaseProgram) > 0))
				AND ((@CompanyKey = 'ALL') 
					OR (CHARINDEX(cast(ccq.[CompanyKey] as varchar(10)), @CompanyKey) > 0 
						OR ccq.[CompanyName] LIKE '%'+@CompanyKey+'%'))
		)
		SELECT 
			Supervisor,
			CaseProgram,
			CompanyName,
			LOB,
			CmOrgRegion,
			COUNT(DISTINCT MVDID) AS MemInProgramsCount
		FROM MMF_programs
		GROUP BY
			Supervisor,
			CaseProgram,
			CompanyName,
			LOB,
			CmOrgRegion
END