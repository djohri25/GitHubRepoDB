/****** Object:  Procedure [dbo].[uspMemberSearch_20211026]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Example: EXEC dbo.uspMemberSearch @Cust_ID= 16,@Spl_MemberID = NULL,@Spl_FirstName= N'Thomas',@Spl_LastName = NULL,@MVDIDCount=0
-- Example2: Exec dbo.uspMemberSearch @Cust_ID = 16, @Spl_MemberID = 'Y0017314002', @MVDIDCount = 0

-- Date				Name			Comments		
-- added @Product int = NULL		
-- 0721 luna apply same change on dev. change ethnicity varchar(2) to (20) insmemberid from 15 to 30
-- 0729 JPG enhanced criteria for HealthPlanEmployeeFlag which is tied by the username.
-- 0807 DJ optimized sproc for like search by fname, lname 
-- 0812 JPG optimized sp search order by removing union. Then bracketed criterias from highest to lowest. Removed Indexes. Avg' qry time reduced from 17 to 7 seconds. 
-- 0812 JPG Added Gender Search Criteria
-- 0813 Enabled partial MemberID search
-- 20210525 Jose Optimized SP
-- 20210915 Ed Added @IncludeTemporaryMembers parameter
-- =============================================
CREATE PROCEDURE [dbo].[uspMemberSearch_20211026]
@Cust_ID	INT
,@UserName	VARCHAR(60) = NULL
,@FirstName	VARCHAR(100) = NULL
,@LastName	VARCHAR(100) = NULL
,@DOB DATE = NULL
,@City VARCHAR(50) = NULL
,@Gender VARCHAR(2) = NULL
,@Zipcode VARCHAR(10) = NULL
,@State VARCHAR(2) = NULL
,@Phone	VARCHAR(10) = NULL
,@Spl_MemberID VARCHAR(30) = NULL
,@Spl_FirstName	VARCHAR(100) = NULL
,@Spl_LastName	VARCHAR(100) = NULL
,@MVDIDCount INT OUTPUT
,@Product int = NULL
,@IncludeTemporaryMembers bit = 1
AS
BEGIN

SET NOCOUNT ON;

/*

declare @p6 int
set @p6=221
exec uspMemberSearch 
	@Cust_ID=16,
	@UserName=N'KSRANNEY',
	@Product=2,
	@Spl_FirstName=N'C',
	@Spl_LastName=N'Carpenter',
	@MVDIDCount=@p6 output
select @p6

*/

----For testing purposes
--Declare
--	@Cust_ID	INT = 16
--	,@UserName	VARCHAR(60) = 'KSRANNEY'
--	,@FirstName	VARCHAR(100) = NULL
--	,@LastName	VARCHAR(100) = NULL
--	,@DOB DATE = NULL
--	,@City VARCHAR(50) = NULL
--	,@Gender VARCHAR(2) = NULL
--	,@Zipcode VARCHAR(10) = NULL
--	,@State VARCHAR(2) = NULL
--	,@Phone	VARCHAR(10) = NULL
--	,@Spl_MemberID VARCHAR(30) = NULL
--	,@Spl_FirstName	VARCHAR(100) = 'C'
--	,@Spl_LastName	VARCHAR(100) = 'Carpenter'
--	,@MVDIDCount INT 
--	,@Product int = 2



Declare @CanSeeAllMembers bit = 0

Set @CanSeeAllMembers = dbo.[fnABCBSUserMemberCheck](@UserName)

DROP TABLE IF EXISTS #FinalResult

CREATE TABLE #FinalResult (
	ICENUMBER	varchar(30), InsMemberId	varchar(30), FirstName	varchar(100), LastName	varchar(100), DOB Date, Gender	varchar(1), 
	Address1 varchar(100), Address2	varchar(100), City varchar(100), State	varchar(30), PostalCode	varchar(10), HomePhone varchar(20),
	WorkPhone	varchar(20), CellPhone	varchar(20), FaxPhone	varchar(20),Email	varchar(100)
	)



--IF @Spl_MemberID is NULL and (@Spl_FirstName IS NULL OR @Spl_LastName IS NULL)
--BEGIN
--	DROP TABLE IF EXISTS #MPD;

--	CREATE TABLE #MPD (
--		ICENUMBER VARCHAR (30), FirstName	VARCHAR (50), LastName	VARCHAR (50), DOB	DATE, GenderID	varchar(1) ,Address1	VARCHAR (100), Address2	VARCHAR (50)
--		,City	VARCHAR (50), [State]	VARCHAR (2), PostalCode	VARCHAR (9), HomePhone	VARCHAR (10), WorkPhone	VARCHAR (14), CellPhone	VARCHAR (10), FaxPhone	VARCHAR (10)
--		,Email	VARCHAR (100), Ethnicity	VARCHAR (20), [Language]	VARCHAR (50), InCaseManagement	BIT, InsMemberId	VARCHAR (30), BreakGlass BIT DEFAULT (0)
--		)

--	INSERT INTO #MPD (ICENUMBER,FirstName,LastName,DOB,GenderID,Address1,Address2,City,State,PostalCode,
--		HomePhone,WorkPhone,CellPhone,FaxPhone,Email,Ethnicity,Language,InCaseManagement,InsMemberId)
--	SELECT
--		D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, D.Address1, D.Address2, D.City, D.[State], D.Zipcode, 
--		D.HomePhone, D.WorkPhone,NULL, D.Fax, D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId 

	IF ( @IncludeTemporaryMembers = 1 )
	BEGIN
		INSERT INTO #FinalResult (
			ICENUMBER
			,FirstName
			,LastName
			,DOB
			,Gender
			,Address1
			,Address2
			,City
			,[State]
			,PostalCode
			,HomePhone
			,WorkPhone
			,CellPhone
			,FaxPhone
			,Email
			,InsMemberId
			)
		SELECT
			MVDID
			,dbo.fnInitCap(MemberFirstName) 
			,dbo.fnInitCap(MemberLastName) 
			,CAST(DateOfBirth AS DATE) AS DOB
			,Gender
			,dbo.fnInitCap(Address1) 
			,dbo.fnInitCap(Address2) 
			,dbo.fnInitCap(City) 
			,[State]		
			,Zipcode
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(HomePhone,' ','')))) AS HomePhone
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(WorkPhone,' ','')))) AS WorkPhone
			,NULL
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(Fax,' ','')))) AS FaxPhone
			,Email
			,MemberId 
		FROM 
			dbo.FinalMember (readuncommitted)
		Where 
			CustID = @Cust_ID
			AND (
				(@CanSeeAllMembers = 1 and HealthPlanEmployeeFlag in ( '1', '0'))
				OR (@CanSeeAllMembers = 0 and HealthPlanEmployeeFlag = '0')
			)
			AND (
				COALESCE(@Spl_MemberID, '' ) = ''
				OR (COALESCE(@Spl_MemberID, '' ) <> '' and MemberID like '%'+@Spl_MemberID+'%')
			)
	
			--First set of parameters
			AND (
				COALESCE(@FirstName, '' ) = '' 
				OR (COALESCE(@FirstName, '' ) <> '' and MemberFirstName like @FirstName + '%')
			)
			AND (
				COALESCE(@LastName, '' ) = ''
				OR (COALESCE(@LastName, '' ) <> '' and MemberLastName like @LastName + '%')
			)
	
			--Second set of parameters
			AND (
				COALESCE(@Spl_FirstName, '' ) = ''
				OR (COALESCE(@Spl_FirstName, '' ) <> '' and MemberFirstName like @Spl_FirstName + '%')
			)
			AND (
				COALESCE(@Spl_LastName, '' ) = ''
				OR (COALESCE(@Spl_LastName, '' ) <> '' and MemberLastName like @Spl_LastName + '%')
			)
	
			AND (
				COALESCE(@DOB, '') = ''
				OR (COALESCE(@DOB, '' ) <> '' and DateOfBirth = @DOB)
			)
			AND (
				COALESCE(@Gender, '') = ''
				OR (COALESCE(@Gender, '' ) <> '' and Gender = @Gender)
			)
			AND (
				COALESCE(@State, '') = ''
				OR (COALESCE(@State, '' ) <> '' and [State] = @State)
			)
			AND (
				COALESCE(@City, '') = ''
				OR (COALESCE(@City, '' ) <> '' and City = @City)
			)
			AND (
				COALESCE(@Zipcode, '') = ''
				OR (COALESCE(@Zipcode, '' ) <> '' and Zipcode = @Zipcode)
			)
			AND (
				COALESCE(@Phone, '') = ''
				OR (COALESCE(@Phone, '' ) <> '' and HomePhone = @Phone)
			)
		END;
		ELSE
		BEGIN
		INSERT INTO #FinalResult (
			ICENUMBER
			,FirstName
			,LastName
			,DOB
			,Gender
			,Address1
			,Address2
			,City
			,[State]
			,PostalCode
			,HomePhone
			,WorkPhone
			,CellPhone
			,FaxPhone
			,Email
			,InsMemberId
			)
		SELECT
			MVDID
			,dbo.fnInitCap(MemberFirstName) 
			,dbo.fnInitCap(MemberLastName) 
			,CAST(DateOfBirth AS DATE) AS DOB
			,Gender
			,dbo.fnInitCap(Address1) 
			,dbo.fnInitCap(Address2) 
			,dbo.fnInitCap(City) 
			,[State]		
			,Zipcode
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(HomePhone,' ','')))) AS HomePhone
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(WorkPhone,' ','')))) AS WorkPhone
			,NULL
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(Fax,' ','')))) AS FaxPhone
			,Email
			,MemberId 
		FROM 
			dbo.FinalMemberETL (readuncommitted)
		Where 
			CustID = @Cust_ID
			AND (
				(@CanSeeAllMembers = 1 and HealthPlanEmployeeFlag in ( '1', '0'))
				OR (@CanSeeAllMembers = 0 and HealthPlanEmployeeFlag = '0')
			)
			AND (
				COALESCE(@Spl_MemberID, '' ) = ''
				OR (COALESCE(@Spl_MemberID, '' ) <> '' and MemberID like '%'+@Spl_MemberID+'%')
			)
	
			--First set of parameters
			AND (
				COALESCE(@FirstName, '' ) = '' 
				OR (COALESCE(@FirstName, '' ) <> '' and MemberFirstName like @FirstName + '%')
			)
			AND (
				COALESCE(@LastName, '' ) = ''
				OR (COALESCE(@LastName, '' ) <> '' and MemberLastName like @LastName + '%')
			)
	
			--Second set of parameters
			AND (
				COALESCE(@Spl_FirstName, '' ) = ''
				OR (COALESCE(@Spl_FirstName, '' ) <> '' and MemberFirstName like @Spl_FirstName + '%')
			)
			AND (
				COALESCE(@Spl_LastName, '' ) = ''
				OR (COALESCE(@Spl_LastName, '' ) <> '' and MemberLastName like @Spl_LastName + '%')
			)
	
			AND (
				COALESCE(@DOB, '') = ''
				OR (COALESCE(@DOB, '' ) <> '' and DateOfBirth = @DOB)
			)
			AND (
				COALESCE(@Gender, '') = ''
				OR (COALESCE(@Gender, '' ) <> '' and Gender = @Gender)
			)
			AND (
				COALESCE(@State, '') = ''
				OR (COALESCE(@State, '' ) <> '' and [State] = @State)
			)
			AND (
				COALESCE(@City, '') = ''
				OR (COALESCE(@City, '' ) <> '' and City = @City)
			)
			AND (
				COALESCE(@Zipcode, '') = ''
				OR (COALESCE(@Zipcode, '' ) <> '' and Zipcode = @Zipcode)
			)
			AND (
				COALESCE(@Phone, '') = ''
				OR (COALESCE(@Phone, '' ) <> '' and HomePhone = @Phone)
			)
		END;
--END	

---- Special Case: Where MemberID or LastName, FirstName can typed in the search criteria
--IF @Spl_MemberID IS NOT NULL OR @Spl_FirstName IS NOT NULL OR @Spl_LastName IS NOT NULL
--BEGIN
-- --   DROP TABLE IF EXISTS #MPDS;

--	--CREATE Table #MPDS (
--	--	ICENUMBER	Varchar(30), FirstName	Varchar(100), LastName	Varchar(100), DOB			Date, GenderID	varchar(1), Address1	Varchar(100), Address2	Varchar(100), City	Varchar(100),
--	--	[State]	Varchar(100), PostalCode	Varchar(20), HomePhone	Varchar(20), WorkPhone	Varchar(20), CellPhone	Varchar(20), FaxPhone	Varchar(20), Email	Varchar(100), 
--	--	Ethnicity	Varchar(30), [Language]	Varchar(30), InCaseManagement BIT ,InsMemberId		Varchar(30),BreakGlass BIT DEFAULT (0)
--	--)

--	--INSERT INTO #MPDS (ICENUMBER,FirstName, LastName, DOB, GenderID, Address1, Address2, City, [State], PostalCode, HomePhone, WorkPhone, CellPhone, FaxPhone 
--	--	,Email, Ethnicity, [Language], InCaseManagement, InsMemberId)
--	--SELECT
--	--	D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, D.Address1, D.Address2, D.City, D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
--	--	,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId  			


--	INSERT INTO #FinalResult (
--		ICENUMBER, FirstName, LastName, DOB, Gender, Address1, Address2, City, State, PostalCode,
--		HomePhone, WorkPhone, CellPhone, FaxPhone, Email, InsMemberId)
--	SELECT
--		D.MVDID 
--		,dbo.fnInitCap(D.MemberFirstName) 
--		,dbo.fnInitCap(D.MemberLastName) 
--		,CAST(D.DateOfBirth AS DATE) AS DOB
--		,D.Gender
--		,dbo.fnInitCap(D.Address1) 
--		,dbo.fnInitCap(D.Address2) 
--		,dbo.fnInitCap(D.City) 
--		,D.[State] 
--		,D.Zipcode 
--		,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(D.HomePhone,' ','')))) AS HomePhone
--		,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(D.WorkPhone,' ','')))) AS WorkPhone
--		,NULL
--		,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(D.Fax,' ','')))) AS FaxPhone
--		,D.Email, D.MemberId 
--	FROM dbo.FinalMember D WITH (NOLOCK)
--	WHERE D.CustID = @Cust_ID
--		AND
--		(
--			(@CanSeeAllMembers = 1 and D.HealthPlanEmployeeFlag in ('1','0'))
--			or
--			(@CanSeeAllMembers = 0 and D.HealthPlanEmployeeFlag in ('0'))
--		)
--		AND
--		(
--			(@Spl_MemberID is not null and MemberID like '%'+@Spl_MemberID+'%')
--			or
--			(@Spl_MemberID is null)
--		)
--		AND
--		(
--			(
--				( 
--					IsNULL(@Spl_FirstName, '') <> IsNULL(@Spl_LastName,'') AND
--					(@Spl_FirstName is not null and MemberFirstName Like @Spl_FirstName + '%')
--					or
--					(@Spl_FirstName is null)
--				)
--			AND
--				(
--					(@Spl_LastName is not null and MemberLastName Like @Spl_LastName + '%')
--					or
--					(@Spl_LastName is null)
--				)
--			)
--		OR
--			(
--			@Spl_FirstName = @Spl_LastName 
--			AND 
--			(MemberFirstName Like @Spl_FirstName + '%'or MemberLastName Like @Spl_LastName + '%')
--			)
--		)

--END


SELECT 
	@MVDIDCount = COUNT(DISTINCT ICENUMBER)
FROM 
	#FinalResult 
	      

--IF (@Spl_MemberID IS NOT NULL OR @Spl_FirstName IS NOT NULL OR @Spl_LastName IS NOT NULL)
--BEGIN
--	SELECT @MVDIDCount = COUNT(DISTINCT MPD.ICENUMBER)
--	FROM #MPDS MPD
--	WHERE 
--		(LastName = @Spl_LastName
--			OR FirstName = @Spl_FirstName 
--			OR FirstName +' '+ LastName =  @Spl_FirstName+' '+ @Spl_LastName
--			OR FirstName +' '+ LastName =  @Spl_LastName+' '+ @Spl_FirstName
--			OR @Spl_LastName IS NULL 
--			OR @Spl_FirstName IS NULL
--			)
--		AND (InsMemberId LIKE '%'+ @Spl_MemberID +'%' OR @Spl_MemberID IS NULL)
--END
--ELSE
--BEGIN
-- 	SELECT @MVDIDCount = COUNT(DISTINCT MPD.ICENUMBER)
--	FROM #MPD MPD
--	WHERE ((MPD.InsMemberId = @Spl_MemberID ) )
--		AND (MPD.LastName LIKE @LastName+'%' OR @LastName	IS NULL)
--		AND (MPD.FirstName LIKE @FirstName+'%' OR @FirstName IS NULL)
--		AND (MPD.DOB = @DOB OR @DOB IS NULL)
--		AND (MPD.City = @City OR @City IS NULL)
--		AND (MPD.State = @State OR @State IS NULL)
--		AND (MPD.PostalCode = @Zipcode OR @Zipcode IS NULL)
--		AND (MPD.HomePhone = @Phone OR @Phone IS NULL)
--END

		
--IF (@Spl_MemberID IS NOT NULL OR @Spl_FirstName IS NOT NULL OR @Spl_LastName IS NOT NULL)
--BEGIN
--	INSERT INTO #FinalResult (
--		ICENUMBER, InsMemberId, FirstName, LastName, DOB, Gender, Address1, Address2, City, State, PostalCode, 
--		HomePhone, WorkPhone, CellPhone, FaxPhone, Email
--		)
--	SELECT --TOP (100)
--		MPD.ICENUMBER 
--		,MPD.InsMemberId 
--		,dbo.fnInitCap(MPD.FirstName) 
--		,dbo.fnInitCap(MPD.LastName) 
--		,CAST(MPD.DOB AS DATE) AS DOB
--		,MPD.GenderID
--		,dbo.fnInitCap(MPD.Address1) 
--		,dbo.fnInitCap(MPD.Address2) 
--		,dbo.fnInitCap(MPD.City) 
--		,MPD.[State]
--		,MPD.PostalCode 
--		,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.HomePhone,' ','')))) AS HomePhone
--		,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.WorkPhone,' ','')))) AS WorkPhone
--		,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.CellPhone,' ','')))) AS CellPhone
--		,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.FaxPhone,' ','')))) AS FaxPhone
--		,MPD.Email
--	FROM #MPDS MPD

--	WHERE 
--		((MPD.LastName = @Spl_LastName 
--			OR MPD.FirstName = @Spl_FirstName 
--			OR MPD.FirstName +' '+ MPD.LastName =  @Spl_FirstName+' '+ @Spl_LastName
--			OR MPD.FirstName +' '+ MPD.LastName =  @Spl_LastName+' '+ @Spl_FirstName
--			OR @Spl_LastName IS NULL 
--			OR @Spl_FirstName IS NULL
--		)
--		AND 
--		(MPD.InsMemberId LIKE '%'+ @Spl_MemberID +'%' OR @Spl_MemberID IS NULL))
--	ORDER BY 
--		MPD.InsMemberId
--END
--ELSE 
--BEGIN
--	INSERT INTO #FinalResult (
--		ICENUMBER, InsMemberId, FirstName, LastName, DOB, Gender, Address1, Address2, City, State, PostalCode, 
--		HomePhone, WorkPhone, CellPhone, FaxPhone, Email
--	)
--	SELECT --TOP (100)
--		MPD.ICENUMBER 
--		,MPD.InsMemberId 
--		,dbo.fnInitCap(MPD.FirstName) 
--		,dbo.fnInitCap(MPD.LastName) 
--		,CAST(MPD.DOB AS DATE) AS DOB
--		,MPD.GenderID
--		,dbo.fnInitCap(MPD.Address1) 
--		,dbo.fnInitCap(MPD.Address2) 
--		,dbo.fnInitCap(MPD.City) 
--		,MPD.[State]
--		,MPD.PostalCode 
--		,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.HomePhone,' ','')))) AS HomePhone
--		,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.WorkPhone,' ','')))) AS WorkPhone
--		,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.CellPhone,' ','')))) AS CellPhone
--		,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.FaxPhone,' ','')))) AS FaxPhone
--		,MPD.Email
--	FROM #MPD MPD

--	WHERE 
--		(MPD.LastName LIKE @LastName+'%' OR @LastName	IS NULL)
--		AND (MPD.FirstName LIKE @FirstName+'%' OR @FirstName IS NULL)
--		AND (MPD.DOB = @DOB OR @DOB IS NULL)
--		AND (MPD.City = @City OR @City IS NULL)
--		AND (MPD.State = @State OR @State IS NULL)
--		AND (MPD.PostalCode = @Zipcode OR @Zipcode IS NULL)
--		AND (MPD.HomePhone = @Phone OR @Phone IS NULL)
--	ORDER BY 
--		MPD.InsMemberId
--END

	

-- Final Output Result
SELECT
	MPD.ICENUMBER AS MVDID, 
	MPD.InsMemberId AS MemberID, 
	MPD.FirstName, 
	MPD.LastName, 
	MPD.DOB, 
	MPD.Gender, 
	MPD.Address1, 
	MPD.Address2, 
	MPD.City, 
	MPD.[State],
	MPD.PostalCode, 
	MPD.HomePhone, 
	MPD.WorkPhone, 
	MPD.CellPhone, 
	MPD.FaxPhone, 
	MPD.Email
FROM #FinalResult MPD 
--	LEFT JOIN dbo.CareSpaceMemberEdit ME WITH (NOLOCK) ON MPD.ICENUMBER = ME.ICENUMBER
--OPTION(RECOMPILE)
ORDER BY 
	MPD.InsMemberId

END