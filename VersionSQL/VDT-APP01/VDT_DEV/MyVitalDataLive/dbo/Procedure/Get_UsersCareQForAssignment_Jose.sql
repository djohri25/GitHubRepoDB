/****** Object:  Procedure [dbo].[Get_UsersCareQForAssignment_Jose]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_UsersCareQForAssignment_Jose]
@CustID			bigint,
@ProductID		bigint,
@County			varchar(100),
@State			varchar(20),
@OrgTeam		varchar(200),
@UserType		varchar(200),
@FirstName		varchar(50),
@LastName		varchar(50),
@UserName		varchar(50),
@IsEmployee		bit
AS 
/*


Test Case:
Exec [dbo].[Get_UsersCareQForAssignment_Jose]
@CustID			= 16,
@ProductID		= 2,
@County			= NULL,
@State			= 'TX',
@OrgTeam		= 'WALMART',
@UserType		= NULL,
@FirstName		= NULL,
@LastName		= NULL,
@UserName		= NULL,
@IsEmployee		= 0


Changes:
WHO			WHEN			WHAT
Scott		2020-09-12		Modified final query to improve performance.  Counting "assigned today" takes way too long.  
							The functions ConvertUTCToCT and IsDST take too long when called repeatedly each row.
							Saving 40% by externalizing @Today and @Tomorrow but still takes too long.
Sunil		2020-12-31		Changed datatype on #user (Name) from nvarchar(256) to varchar(256)
Luna
Jose		 
Jose		20210222		Optimize search condition when is ''
*/
BEGIN

--SET NOCOUNT ON;

SET @County = ISNULL( @County, '' );
SET @State = ISNULL( @State, '' );
SET @OrgTeam = ISNULL( @OrgTeam, '' );

IF ( LEN( @OrgTeam ) > 0 )
BEGIN
	SET @OrgTeam = 'VDT_Assign_OrgTeam_' + @OrgTeam;
END

SET @UserType = ISNULL( @UserType, '' );

IF ( LEN( @UserType ) > 0 )
BEGIN
	SET @UserType = 'VDT_Assign_UserType_' + @UserType;
END
	
SET @FirstName = ISNULL( @FirstName, '' );
SET @LastName = ISNULL( @LastName, '' );
SET @UserName = ISNULL( @UserName, '' );

	
DROP TABLE IF EXISTS #User;

CREATE TABLE #User (
ID nvarchar(max),
--Name nvarchar(256), -- Date 12/31 1:32PM
Name varchar(256),
EntityType nvarchar(max),
UserType nvarchar(max),
OrgTeam nvarchar(max),
LicenseType nvarchar(max),
State nvarchar(max),
Status nvarchar(max),
County nvarchar(max),
FirstName nvarchar(max),
LastName nvarchar(max)
);


INSERT INTO #User (
	ID,
	[Name],
	EntityType,
	UserType,
	OrgTeam,
	LicenseType,
	[State],
	[Status],
	County,
	FirstName,
	LastName
)
SELECT
	anu.Id ID,
	anu.UserName [Name],
	'USER' EntityType,
	anui.Groups + ',' UserType,
	anui.Groups + ',' OrgTeam,
	NULL LicenseType,
	NULL [State],
	NULL [Status],
	NULL County,
	anu.FirstName,
	anu.LastName
FROM dbo.[AspNetUsers] anu WITH (readuncommitted)
	LEFT OUTER JOIN dbo.[AspNetUserInfo] anui WITH (readuncommitted)
		ON anui.UserId = anu.Id
WHERE
	CASE
		WHEN @IsEmployee = 0 THEN 1
		WHEN @IsEmployee = 1 AND dbo.fnABCBSUserMemberCheck( anu.UserName ) = 1 THEN 1
		ELSE 0
		END = 1
	AND (( @FirstName = '') OR (LTRIM( RTRIM( anu.FirstName ) ) LIKE  '%' + LTRIM( RTRIM( @FirstName ) ) + '%'))
	AND (( @LastName = '' ) OR (LTRIM( RTRIM( anu.LastName ) ) LIKE  '%' + LTRIM( RTRIM( @LastName ) ) + '%'))
	AND (( @UserName = '' ) OR (anu.UserName LIKE  '%' + LTRIM( RTRIM( @UserName ) ) + '%'))



INSERT INTO #User (
	ID,
	[Name],
	EntityType,
	UserType,
	OrgTeam,
	LicenseType,
	[State],
	[Status],
	County,
	FirstName,
	LastName
)
SELECT DISTINCT
	anu.Id ID,
	anu.UserName [Name],
	'USER' EntityType,
	anui.Groups UserType,
	anui.Groups OrgTeam,
	nl.LicenseType,
	nl.[State],
	ISNULL( nl.[Status], '2' ) [Status],
	c.County_Name County,
	anu.FirstName,
	anu.LastName
FROM dbo.[AspNetUsers] anu WITH (readuncommitted)
	LEFT OUTER JOIN
		(
			SELECT DISTINCT 
				UserID, 
				FIRST_VALUE( Groups ) OVER ( 
					PARTITION BY UserID 
					ORDER BY 
						CASE WHEN [Signature] IS NOT NULL THEN 1 ELSE 2 END, 
						LEN( Groups ) DESC ) Groups
			FROM dbo.[AspNetUserInfo] WITH (readuncommitted)
		) anui
		ON anui.UserId = anu.Id
	LEFT OUTER JOIN dbo.[NurseLicensure] nl WITH (readuncommitted)
		--	ON LTRIM( RTRIM( nl.UserName ) ) = LTRIM( RTRIM( anu.UserName ) )
		ON nl.UserName = anu.UserName
			AND ISNULL( nl.Status, '2' ) = '2'
	LEFT OUTER JOIN dbo.[LookUp_CountyRegion] c WITH (readuncommitted)
		ON c.State_Code = nl.[State]
			AND c.County_Name = nl.County
WHERE 
	CASE
		WHEN @IsEmployee = 0 THEN 1
		WHEN @IsEmployee = 1 AND dbo.fnABCBSUserMemberCheck( anu.UserName ) = 1 THEN 1
		ELSE 0
		END = 1
	AND (( @FirstName = '' ) OR (LTRIM( RTRIM(  anu.FirstName ) ) LIKE  '%' + LTRIM( RTRIM( @FirstName ) ) + '%'))
	AND (( @LastName = '' ) OR (LTRIM( RTRIM( anu.LastName ) ) LIKE  '%' + LTRIM( RTRIM( @LastName ) ) + '%'))
	AND (( @UserName = '' ) OR (anu.UserName LIKE  '%' + LTRIM( RTRIM( @UserName ) ) + '%'))


CREATE INDEX IX_User_ID ON #User ( [Name] );


-- Filter any parameter
DROP TABLE IF EXISTS #FilterUser;

SELECT
	ID,
	[Name],
	EntityType,
	UserType,
	OrgTeam,
	LicenseType,
	[State],
	County,
	FirstName,
	LastName
INTO #FilterUser
FROM #User
WHERE 
	(( @State = '' ) OR ISNULL( [State], '' ) LIKE '%' + @State + '%' )
	AND (( @County = '' ) OR ISNULL( County, '' ) LIKE '%' + @County + '%')
	----The next condition were already applied
	--AND (( @FirstName = '' ) OR ISNULL( FirstName, '' ) LIKE '%' + @FirstName + '%')
	--AND (( @LastName = '' ) OR ISNULL( LastName, '' ) LIKE '%' + @LastName + '%')
	--AND (( @UserName = '' ) OR ISNULL( [Name], '' ) LIKE '%' + @UserName + '%')   	
	AND (( @UserType = '' ) OR ISNULL( UserType, '' ) LIKE '%' + @UserType + ',%')  	
	AND (( @OrgTeam = '' ) OR ISNULL( OrgTeam, '' )  LIKE  '%' + @OrgTeam + ',%')
	--AND
	--	CASE 
	--	WHEN @State = '' THEN 1
	--	WHEN @County = '' THEN 1 	
	--	WHEN @OrgTeam = '' THEN 1
	--	WHEN @UserType = '' THEN 1  
	--	WHEN @FirstName= '' THEN 1
	--	WHEN @LastName = '' THEN 1
	--	WHEN @UserName = '' THEN 1
	--	ELSE 0  
	--	END = 1;

CREATE INDEX IX_FilterUser_Name ON #FilterUser ( [Name] );


DECLARE @Today date = getUTCDate()
DECLARE @Tomorrow date = DATEADD( DAY, 1, getUTCDate() )

-- FINAL RESULT
SELECT
	fu.ID,
	fu.[Name],
	fu.EntityType,
	fu.UserType,
	fu.OrgTeam,
	fu.LicenseType,
	fu.[State],
	fu.County,
	fu.FirstName,
	fu.LastName,
	ISNULL( fmo.CountOfAssignments, 0 ) CountOfAssignments,
	ISNULL( mmf.CountOfCases, 0 ) CountOfCases,
	ISNULL( fmo.CountOfAssignmentsToday, 0 ) CountOfAssignmentsToday
FROM #FilterUser fu
--FROM @FilterUser fu
	LEFT OUTER JOIN 
		(
			SELECT
				u.[Name],
				COUNT( DISTINCT au.MVDID ) AS CountOfAssignments,
				--COUNT
				--(
				--	DISTINCT
				--	CASE
				--	WHEN au.CreatedDate IS NULL AND au.StartDate >= CAST( dbo.ConvertUTCToCT( getUTCDate() ) AS date )
				--		AND au.StartDate <= DATEADD( DAY, 1, CAST( dbo.ConvertUTCToCT( getUTCDate() ) AS date ) ) THEN au.MVDID
				--	WHEN dbo.ConvertUTCToCT( au.CreatedDate ) >= CAST( dbo.ConvertUTCToCT( getUTCDate() ) AS date )
				--		AND dbo.ConvertUTCToCT( au.CreatedDate ) <= DATEADD( DAY, 1, CAST( dbo.ConvertUTCToCT( getUTCDate() ) AS date ) ) THEN au.MVDID
				--	ELSE NULL
				--	END
				--) CountOfAssignmentsToday
				COUNT
				(
					DISTINCT
						CASE
						WHEN au.CreatedDate IS NULL AND au.StartDate BETWEEN @Today AND @Tomorrow THEN au.MVDID
						WHEN au.CreatedDate BETWEEN @Today AND @Tomorrow THEN au.MVDID
						ELSE NULL
						END
					) CountOfAssignmentsToday		--reduced query time by 40% but it is still hogging the time.
			FROM dbo.[Final_MemberOwner] au WITH (readuncommitted)
				INNER JOIN #User u
				--INNER JOIN @User u
					ON u.[Name] = au.OwnerName
			WHERE
				ISNULL( au.IsDeactivated, '0' ) = 0
				-- we no longer just want primary ownership
				--		AND au.OwnerType = 'primary'
			GROUP BY u.[Name]
		) fmo
			ON fmo.[Name] = fu.[Name]
	LEFT OUTER JOIN
		(
			SELECT
				u.[Name],
				COUNT(DISTINCT cm.ID ) AS CountOfCases
			FROM dbo.[ABCBS_MemberManagement_Form] cm WITH (readuncommitted)
				INNER JOIN #User u
				--INNER JOIN @User u
					ON u.[Name] = cm.q1CaseOwner	  
			WHERE
				ISNULL( cm.q1CaseCloseDate, '1900-01-01' ) = '1900-01-01'
			GROUP BY
				u.[Name] 
		) mmf
		ON mmf.[Name] = fu.[Name];

END