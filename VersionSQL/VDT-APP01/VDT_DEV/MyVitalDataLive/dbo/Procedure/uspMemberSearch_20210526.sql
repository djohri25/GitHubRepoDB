/****** Object:  Procedure [dbo].[uspMemberSearch_20210526]    Committed by VersionSQL https://www.versionsql.com ******/

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
-- =============================================
CREATE PROCEDURE [dbo].[uspMemberSearch_20210526]
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
AS
BEGIN

	SET NOCOUNT ON;

	Declare @CanSeeAllMembers bit = 0

	Set @CanSeeAllMembers = dbo.[fnABCBSUserMemberCheck](@UserName)

	DROP TABLE IF EXISTS #FinalResult
	CREATE TABLE #FinalResult
	(
		ICENUMBER	varchar(30), InsMemberId	varchar(30), FirstName	varchar(100), LastName	varchar(100), DOB		Date, Gender	varchar(1), Address1	varchar(100), Address2	varchar(100), 
		City	varchar(100), State	varchar(30), PostalCode	varchar(10), HomePhone	varchar(20), WorkPhone	varchar(20), CellPhone	varchar(20), FaxPhone	varchar(20),Email	varchar(100)
	)

IF @Spl_MemberID is NULL and (@Spl_FirstName IS NULL OR @Spl_LastName IS NULL)
BEGIN
	DROP TABLE IF EXISTS #MPD;
	CREATE TABLE #MPD
	(
		ICENUMBER VARCHAR (30), FirstName	VARCHAR (50), LastName	VARCHAR (50), DOB	DATE, GenderID	varchar(1) ,Address1	VARCHAR (100), Address2	VARCHAR (50)
	,City	VARCHAR (50), [State]	VARCHAR (2), PostalCode	VARCHAR (9), HomePhone	VARCHAR (10), WorkPhone	VARCHAR (14), CellPhone	VARCHAR (10), FaxPhone	VARCHAR (10)
	,Email	VARCHAR (100), Ethnicity	VARCHAR (20), [Language]	VARCHAR (50), InCaseManagement	BIT, InsMemberId	VARCHAR (30), BreakGlass BIT DEFAULT (0)
	)

	INSERT INTO #MPD (ICENUMBER,FirstName,LastName,DOB,GenderID,Address1,Address2,City,State,PostalCode,HomePhone,WorkPhone,CellPhone,FaxPhone,Email,Ethnicity,Language,InCaseManagement,InsMemberId)
	SELECT
		D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, D.Address1, D.Address2, D.City, D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
	,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId 
	FROM dbo.FinalMember D WITH (NOLOCK)
	Where 
	D.CustID = @Cust_ID
	AND
	(
	(@CanSeeAllMembers = 1 and D.HealthPlanEmployeeFlag in ('1','0'))
	or
	(@CanSeeAllMembers = 0 and D.HealthPlanEmployeeFlag in ('0'))
	)
	AND
	(
		(@Spl_MemberID is not null and MemberID like '%'+@Spl_MemberID+'%')
		or
		(@Spl_MemberID is null)
	)
	AND
	(
		(@FirstName is not null and MemberFirstName like @FirstName + '%')
		or
		(@FirstName is null)
	)
	AND
	(
		(@LastName is not null and MemberLastName like @LastName + '%')
		or
		(@LastName is null)
	)
	AND
	(
		(@DOB is not null and DateOfBirth = @DOB)
		or
		(@DOB is null)
	)
		AND
	(
		(@Gender is not null and Gender = @Gender)
		or
		(@Gender is null)
	)
	AND
	(
		(@State is not null and [State] = @State)
		or
		(@State is null)
	)
	AND
	(
		(@City is not null and City = @City)
		or
		(@City is null)
	)
	AND
		(
		(@Zipcode is not null and Zipcode = @Zipcode)
		or
		(@Zipcode is null)
	)
	AND
		(
		(@Phone is not null and HomePhone = @Phone)
		or
		(@Phone is null)
	)


	END	
	-- Special Case: Where MemberID or LastName, FirstName can typed in the search criteria
	IF @Spl_MemberID IS NOT NULL OR (@Spl_FirstName IS NOT NULL OR @Spl_LastName IS NOT NULL)
	BEGIN
        DROP TABLE IF EXISTS #MPDS;
		CREATE Table #MPDS 
		(
			ICENUMBER	Varchar(30), FirstName	Varchar(100), LastName	Varchar(100), DOB			Date, GenderID	varchar(1), Address1	Varchar(100), Address2	Varchar(100), City	Varchar(100),
			[State]	Varchar(100), PostalCode	Varchar(20), HomePhone	Varchar(20), WorkPhone	Varchar(20), CellPhone	Varchar(20), FaxPhone	Varchar(20), Email	Varchar(100), 
			Ethnicity	Varchar(30), [Language]	Varchar(30), InCaseManagement BIT ,InsMemberId		Varchar(30),BreakGlass BIT DEFAULT (0)
		)

		INSERT INTO #MPDS (ICENUMBER,FirstName, LastName, DOB, GenderID, Address1, Address2, City, [State], PostalCode, HomePhone, WorkPhone, CellPhone, FaxPhone ,Email, Ethnicity, [Language], InCaseManagement, InsMemberId)
		SELECT
		 D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, D.Address1, D.Address2, D.City, D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
		,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId  			
		FROM dbo.FinalMember D WITH (NOLOCK)
		WHERE D.CustID = @Cust_ID
		AND
		(
			(@CanSeeAllMembers = 1 and D.HealthPlanEmployeeFlag in ('1','0'))
			or
			(@CanSeeAllMembers = 0 and D.HealthPlanEmployeeFlag in ('0'))
		)
		AND
		(
			(@Spl_MemberID is not null and MemberID like '%'+@Spl_MemberID+'%')
			or
			(@Spl_MemberID is null)
		)
		AND
		(
			(
				( 
					IsNULL(@Spl_FirstName, '') <> IsNULL(@Spl_LastName,'') AND
					(@Spl_FirstName is not null and MemberFirstName Like @Spl_FirstName + '%')
					or
					(@Spl_FirstName is null)
				)
			AND
				(
					(@Spl_LastName is not null and MemberLastName Like @Spl_LastName + '%')
					or
					(@Spl_LastName is null)
				)
			)
		OR
			(
			@Spl_FirstName = @Spl_LastName 
			AND 
			(MemberFirstName Like @Spl_FirstName + '%'or MemberLastName Like @Spl_LastName + '%')
			)
		)

			

	END
	      

	IF (@Spl_MemberID IS NOT NULL OR @Spl_FirstName IS NOT NULL OR @Spl_LastName IS NOT NULL)
	BEGIN
		SELECT @MVDIDCount = COUNT(DISTINCT MPD.ICENUMBER)
		FROM #MPDS MPD
		WHERE 
		((LastName = @Spl_LastName
				OR FirstName = @Spl_FirstName 
				OR FirstName +' '+ LastName =  @Spl_FirstName+' '+ @Spl_LastName
				OR FirstName +' '+ LastName =  @Spl_LastName+' '+ @Spl_FirstName
				OR @Spl_LastName IS NULL 
				OR @Spl_FirstName IS NULL
			)
		AND (InsMemberId LIKE '%'+ @Spl_MemberID +'%' OR @Spl_MemberID IS NULL))

	END
	ELSE
	BEGIN
 		SELECT @MVDIDCount = COUNT(DISTINCT MPD.ICENUMBER)
		FROM #MPD MPD
		WHERE ((MPD.InsMemberId = @Spl_MemberID ) )
		AND (MPD.LastName LIKE @LastName+'%' OR @LastName	IS NULL)
		AND (MPD.FirstName LIKE @FirstName+'%' OR @FirstName IS NULL)
		AND (MPD.DOB = @DOB OR @DOB IS NULL)
		AND (MPD.City = @City OR @City IS NULL)
		AND (MPD.State = @State OR @State IS NULL)
		AND (MPD.PostalCode = @Zipcode OR @Zipcode IS NULL)
		AND (MPD.HomePhone = @Phone OR @Phone IS NULL)
	END

		
		IF (@Spl_MemberID IS NOT NULL OR @Spl_FirstName IS NOT NULL OR @Spl_LastName IS NOT NULL)
		BEGIN
			INSERT INTO #FinalResult
			(
			ICENUMBER, InsMemberId, FirstName, LastName, DOB, Gender, Address1, Address2, City, State, PostalCode, HomePhone, WorkPhone, 
			CellPhone, FaxPhone, Email
			)
			SELECT --TOP (100)
			 MPD.ICENUMBER 
			,MPD.InsMemberId 
			,dbo.fnInitCap(MPD.FirstName) 
			,dbo.fnInitCap(MPD.LastName) 
			,CAST(MPD.DOB AS DATE) AS DOB
			,MPD.GenderID
			,dbo.fnInitCap(MPD.Address1) 
			,dbo.fnInitCap(MPD.Address2) 
			,dbo.fnInitCap(MPD.City) 
			,MPD.[State]
			,MPD.PostalCode 
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.HomePhone,' ','')))) AS HomePhone
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.WorkPhone,' ','')))) AS WorkPhone
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.CellPhone,' ','')))) AS CellPhone
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.FaxPhone,' ','')))) AS FaxPhone
			,MPD.Email
			FROM #MPDS MPD

			WHERE 
			((MPD.LastName = @Spl_LastName 
				OR MPD.FirstName = @Spl_FirstName 
				OR MPD.FirstName +' '+ MPD.LastName =  @Spl_FirstName+' '+ @Spl_LastName
				OR MPD.FirstName +' '+ MPD.LastName =  @Spl_LastName+' '+ @Spl_FirstName
				OR @Spl_LastName IS NULL 
				OR @Spl_FirstName IS NULL
			)
			AND 
			(MPD.InsMemberId LIKE '%'+ @Spl_MemberID +'%' OR @Spl_MemberID IS NULL))
			ORDER BY MPD.InsMemberId
		END
		ELSE 
		BEGIN
			INSERT INTO #FinalResult
			(
			ICENUMBER, InsMemberId, FirstName, LastName, DOB, Gender, Address1, Address2, City, State, PostalCode, HomePhone, WorkPhone, 
			CellPhone, FaxPhone, Email
			)
			SELECT --TOP (100)
			 MPD.ICENUMBER 
			,MPD.InsMemberId 
			,dbo.fnInitCap(MPD.FirstName) 
			,dbo.fnInitCap(MPD.LastName) 
			,CAST(MPD.DOB AS DATE) AS DOB
			,MPD.GenderID
			,dbo.fnInitCap(MPD.Address1) 
			,dbo.fnInitCap(MPD.Address2) 
			,dbo.fnInitCap(MPD.City) 
			,MPD.[State]
			,MPD.PostalCode 
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.HomePhone,' ','')))) AS HomePhone
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.WorkPhone,' ','')))) AS WorkPhone
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.CellPhone,' ','')))) AS CellPhone
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.FaxPhone,' ','')))) AS FaxPhone
			,MPD.Email
			FROM #MPD MPD

			WHERE 
			(MPD.LastName LIKE @LastName+'%' OR @LastName	IS NULL)
			AND (MPD.FirstName LIKE @FirstName+'%' OR @FirstName IS NULL)
			AND (MPD.DOB = @DOB OR @DOB IS NULL)
			AND (MPD.City = @City OR @City IS NULL)
			AND (MPD.State = @State OR @State IS NULL)
			AND (MPD.PostalCode = @Zipcode OR @Zipcode IS NULL)
			AND (MPD.HomePhone = @Phone OR @Phone IS NULL)
			ORDER BY MPD.InsMemberId
		END

	

-- Final Output Result

	SELECT DISTINCT
	 MPD.ICENUMBER AS MVDID, MPD.InsMemberId AS MemberID, MPD.FirstName, MPD.LastName, MPD.DOB, MPD.Gender, MPD.Address1, MPD.Address2, MPD.City, MPD.[State]
	,MPD.PostalCode, MPD.HomePhone, MPD.WorkPhone, MPD.CellPhone, MPD.FaxPhone, MPD.Email
	FROM #FinalResult MPD 
	LEFT JOIN dbo.CareSpaceMemberEdit ME WITH (NOLOCK) ON MPD.ICENUMBER = ME.ICENUMBER
	OPTION(RECOMPILE)
END