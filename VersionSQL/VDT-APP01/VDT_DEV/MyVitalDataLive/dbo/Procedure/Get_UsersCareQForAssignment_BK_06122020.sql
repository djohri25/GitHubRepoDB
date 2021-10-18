/****** Object:  Procedure [dbo].[Get_UsersCareQForAssignment_BK_06122020]    Committed by VersionSQL https://www.versionsql.com ******/

create PROCEDURE [dbo].[Get_UsersCareQForAssignment_BK_06122020]

	@CustID		int,
	@ProductID	int,
	@County		Varchar(100),
	@State      VARCHAR(20),
	@OrgTeam	VARCHAR(200),
	@UserType	VARCHAR(200),
	@FirstName  VARCHAR(50),
	@LastName   VARCHAR(50),
	@UserName   VARCHAR(50),
	@IsEmployee bit

AS 

BEGIN

--TEST SECTION
--DECLARE 
--@CustID int='16',
--@ProductID int='2',
--@County Varchar(100)=NULL,
--@State  VARCHAR(20)=NULL,
--@OrgTeam VARCHAR(200)=null,
--@UserType VARCHAR(30)=null,
--@FirstName  VARCHAR(50)=NULL,
--@LastName   VARCHAR(50)=NULL,
--@UserName   VARCHAR(50)='camain'


SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
			BEGIN 
				DROP TABLE #TEMP
			END 

	IF OBJECT_ID('tempdb..#filter') IS NOT NULL
			BEGIN 
				DROP TABLE #filter
			END 

	
	select @County	= IsNull(@County,'')
	select @State	=IsNull(@State,'')
	select @OrgTeam	=IsNull(@OrgTeam,'')
	if LEN(@OrgTeam) > 0
	begin
		set @OrgTeam = 'VDT_Assign_OrgTeam_' + @OrgTeam
	end
	select @UserType = IsNull(@UserType,'')
	if LEN(@UserType) > 0
	begin
		set @UserType = 'VDT_Assign_UserType_' + @UserType
	end
	
	SELECT @FirstName =ISNULL(@FirstName,'')
	SELECT @LastName  =ISNULL(@LastName,'')
	SELECT @UserName  =ISNULL(@UserName,'')
	

	SELECT * 
	INTO #TEMP
	FROM 
	(
		SELECT DISTINCT
		U.Id							AS ID
		,U.UserName						AS [Name]
		,'USER'							AS EntityType
		,I.Groups+','					AS UserType
		,I.Groups+','					AS OrgTeam
		,null							AS LicenseType
		,null							AS [State]
		,null							AS [Status]
		,null							AS [County]
		,U.FirstName
		,U.LastName
		FROM [AspNetIdentity].[dbo].[AspNetUsers] U WITH (NOLOCK)
		LEFT JOIN [AspNetIdentity].[dbo].[AspNetUserInfo] I WITH (NOLOCK)
		on I.UserId = U.Id
		WHERE
		CASE
		WHEN @IsEmployee = 0 THEN 1
		WHEN @IsEmployee = 1 AND dbo.fnABCBSUserMemberCheck( U.UserName ) = 1 THEN 1
		ELSE 0
		END = 1
		AND
		(
	--(I.Groups LIKE '%ORGTEAM%' AND I.Groups LIKE '%' + @OrgTeam + '%')
	--OR 
	--(I.Groups LIKE '%USERTYPE%' AND I.Groups LIKE '%' + @UserType + '%')
	--AND 
			(
				(LTRIM(RTRIM(U.FirstName)) LIKE  '%' + @FirstName + '%')
				AND (LTRIM(RTRIM(U.LastName)) LIKE  '%' + @LastName + '%')
				AND (LTRIM(RTRIM(U.UserName)) LIKE  '%' + @UserName + '%')
			)
		)
		UNION 
		SELECT DISTINCT
		U.Id						AS ID
		,U.UserName					AS [Name]
		,'USER'						AS EntityType
		,I.Groups					AS UserType
		,I.Groups					AS OrgTeam
		,N.LicenseType				AS LicenseType
		,N.State					AS [State]
		,IsNull(N.Status,'2')		AS [Status]
		,C.County_Name				AS [County]
		,U.FirstName
		,U.LastName
		FROM [AspNetIdentity].[dbo].[AspNetUsers] U WITH (NOLOCK)
		LEFT JOIN [dbo].[NurseLicensure] N WITH (NOLOCK)
		on LTRIM(RTRIM(N.UserName)) = LTRIM(RTRIM(U.UserName))
		LEFT JOIN [dbo].[LookUp_CountyRegion] C WITH (NOLOCK)
		on C.State_Code = N.State AND C.County_Name = N.County
		LEFT JOIN [AspNetIdentity].[dbo].[AspNetUserInfo] I WITH (NOLOCK)
		on I.UserId = U.Id
		WHERE 
		CASE
		WHEN @IsEmployee = 0 THEN 1
		WHEN @IsEmployee = 1 AND dbo.fnABCBSUserMemberCheck( U.UserName ) = 1 THEN 1
		ELSE 0
		END = 1
		AND
		(
	--(I.Groups LIKE '%ORGTEAM%' AND I.Groups LIKE '%' + @OrgTeam + '%')
	--OR 
	--(I.Groups LIKE '%USERTYPE%' AND I.Groups LIKE '%' + @UserType + '%')
	--AND 
			(
				(LTRIM(RTRIM(U.FirstName)) LIKE  '%' + @FirstName + '%')
				AND (LTRIM(RTRIM(U.LastName)) LIKE  '%' + @LastName + '%')
				AND (LTRIM(RTRIM(U.UserName)) LIKE  '%' + @UserName + '%')
			)
		)
		AND Status = '2' 
	)  x;

-- FILTER ANY PARAMETER
	SELECT * 
	INTO #FILTER
	FROM #TEMP  X	
	WHERE 
	ISNULL(x.[State],'') like '%' + @State  + '%' 
	AND ISNULL(x.County,'') like '%' + @County + '%'
	AND ISNULL(X.FirstName,'') LIKE '%' + @FirstName + '%'
	AND ISNULL(X.LastName,'') LIKE '%' + @LastName + '%'
	AND ISNULL(X.[Name],'') LIKE '%' + @UserName + '%'   	
	AND ISNULL(X.UserType,'') Like '%' + @UserType + ',%'  	
	AND ISNULL(X.OrgTeam,'')  Like  '%' + @OrgTeam  + ',%'
	AND 1 = 
	CASE 
	WHEN @State=''      THEN 1
	WHEN @County= ''    THEN 1 	
	WHEN @OrgTeam=''	THEN 1
	WHEN @UserType =''	THEN 1  
	WHEN @FirstName=''	THEN 1
	WHEN @LastName =''	THEN 1
	WHEN @UserName =''	THEN 1
	ELSE 0  
	END;

-- FINAL RESULT
	SELECT
	ID
	,TP.[Name] AS [Name]
	,EntityType
	,UserType
	,OrgTeam
	,LicenseType
	,[State]
	,[County]
	,[FirstName]
	,[LastName]
	,AG.CountOfAssignments
	,CM.CountOfCases
	FROM #FILTER		AS TP
	LEFT OUTER JOIN 
	(
		SELECT
		COUNT(1) AS CountOfAssignments
		,TP.[Name]
		 -- FROM  [MyVitalDataLive].[dbo].[AssignedUsers] AU
		FROM [dbo].[Final_MemberOwner] AU WITH (NOLOCK)
		INNER JOIN #TEMP   TP 
		ON AU.OwnerName=TP.[Name] 
		where AU.IsDeactivated is null 
		and AU.OwnerType='primary'
		GROUP BY TP.[Name]
	) AS AG
	on TP.[Name]=AG.[Name]
	LEFT OUTER JOIN
	(
		SELECT COUNT(1) AS CountOfCases,TP.[Name]
		FROM [dbo].[ABCBS_MemberManagement_Form] AF WITH (NOLOCK)
		INNER JOIN #TEMP  tp
		ON TP.[Name]=AF.q1CaseOwner	  
		WHERE AF.q1CaseCloseDate IS NULL 
		GROUP BY TP.[Name] 
	)   AS CM
	ON CM.[Name]=TP.[Name];

END