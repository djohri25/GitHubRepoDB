/****** Object:  Procedure [dbo].[GET_MemberData_For_MemberMerge]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Example: EXEC dbo.GET_MemberData_For_MemberMerge @Cust_ID= 16,@UserName	= NULL,@Memberid = NULL,@MVDID	 = NULL,@FirstName= 'GR',@LastName = 'T',@DOB  = NULL,@City  = NULL,@Gender  = NULL,@Zipcode  = NULL,@State  = NULL,@Phone	 = NULL,@Spl_MemberID  = NULL,@Spl_FirstName= NULL,@Spl_LastName = NULL,@MVDIDCount=0
-- Date				Name			Comments				
-- 0812 JPG optimized sp search order by removing union. Then bracketed criterias from highest to lowest. Removed Indexes. Avg' qry time reduced from 17 to 7 seconds. 
-- 0812 JPG Added Gender Search Criteria
-- =============================================
CREATE PROCEDURE [dbo].[GET_MemberData_For_MemberMerge]
	 @Cust_ID	INT='16'
	,@UserName	VARCHAR(60) = NULL
	,@Memberid	VARCHAR(30) = NULL
	,@MVDID		VARCHAR(30) = NULL
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
	,@Product INT = 2 -- SELECT * FROM dbo.Products 1	ProviderLink, 2	PlanLink, 3	ChaseTool
AS
BEGIN

	SET NOCOUNT ON;
--declare 
-- @Cust_ID	INT = 16
--	,@UserName	VARCHAR(60) = NULL
--	,@Memberid	VARCHAR(30) = NULL
--	,@MVDID		VARCHAR(30) = NULL
--	,@FirstName	VARCHAR(100) = 'GR'
--	,@LastName	VARCHAR(100) = 'T'
--	,@DOB DATETIME = NULL
--	,@City VARCHAR(50) = NULL
--	,@Gender VARCHAR(2) = NULL
--	,@Zipcode VARCHAR(10) = NULL
--	,@State VARCHAR(2) = NULL
--	,@Phone	VARCHAR(10) = NULL
--	,@Spl_MemberID VARCHAR(30) = NULL
--	,@Spl_FirstName	VARCHAR(100) = NULL
--	,@Spl_LastName	VARCHAR(100) = NULL
--	,@MVDIDCount INT

	DECLARE @MaxMonthID CHAR(6)

	SELECT @MaxMonthID = MAX(MonthID) FROM dbo.Final_ALLMember WHERE CustID = @Cust_ID

	DECLARE @Today DATE

	SELECT @Today = CASE WHEN @Cust_ID = 16 THEN '03/31/2016' ELSE GETDATE() END

	Declare @CanSeeAllMembers bit 

	Set @CanSeeAllMembers = dbo.[fnABCBSUserMemberCheck](@UserName)

	DROP TABLE IF EXISTS #FinalResult
	CREATE TABLE #FinalResult
	(
		ICENUMBER	varchar(30), InsMemberId	varchar(30), FirstName	varchar(100), LastName	varchar(100), DOB		Date, Gender	varchar(30), Address1	varchar(100), Address2	varchar(100), 
		City	varchar(100), State	varchar(30), PostalCode	varchar(10), HomePhone	varchar(20), WorkPhone	varchar(20), CellPhone	varchar(20), FaxPhone	varchar(20),Email	varchar(100)
	)

	IF (@MemberID IS NULL OR @Spl_FirstName IS NULL OR @Spl_LastName IS NULL)
	BEGIN
		DROP TABLE IF EXISTS #MPD;
		CREATE TABLE #MPD
		(
		 ICENUMBER VARCHAR (30), FirstName	VARCHAR (50), LastName	VARCHAR (50), DOB	DATE, GenderID	varchar(1) ,Address1	VARCHAR (100), Address2	VARCHAR (50)
		,City	VARCHAR (50), [State]	VARCHAR (2), PostalCode	VARCHAR (9), HomePhone	VARCHAR (10), WorkPhone	VARCHAR (14), CellPhone	VARCHAR (10), FaxPhone	VARCHAR (10)
		,Email	VARCHAR (100), Ethnicity	VARCHAR (2), [Language]	VARCHAR (50), InCaseManagement	BIT, InsMemberId	VARCHAR (15), BreakGlass BIT DEFAULT (0)
		)

		INSERT INTO #MPD (ICENUMBER,FirstName,LastName,DOB,GenderID,Address1,Address2,City,State,PostalCode,HomePhone,WorkPhone,CellPhone,FaxPhone,Email,Ethnicity,Language,InCaseManagement,InsMemberId)
		-- MemberID IS NOT NULL
		SELECT
		 D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, D.Address1, D.Address2, D.City, D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
		,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId 
		FROM dbo.FinalMember D
		WHERE D.CustID = @Cust_ID
		AND D.BaseBatchID <> 0 and D.CurrentBatchID <> 0 -- Exclude Temporary Members
		AND
		(
			(@CanSeeAllMembers = 1 and D.HealthPlanEmployeeFlag in ('1','0'))
			or
			(@CanSeeAllMembers = 0 and D.HealthPlanEmployeeFlag in ('0'))
		)		
		AND
		(
			(@Gender is not null and Gender = @Gender)
			or
			(@Gender is null)
		)
		AND
		(
		(@Memberid IS NULL
		AND @MVDID IS NULL
		AND @LastName	IS NULL
		AND @DOB IS NULL
		AND @Phone IS NULL
		AND (D.MemberFirstName LIKE @FirstName+'%' OR @FirstName IS NULL)
		AND (D.City = @City OR @City IS NULL)
		AND (D.State = @State OR @State IS NULL)
		AND (D.Zipcode = @Zipcode OR @Zipcode IS NULL))
		OR
		(@Memberid IS NULL
		AND @MVDID IS NULL
		AND @FirstName IS NOT NULL 
		AND @LastName	IS NOT NULL
		AND MemberLastName LIKE '%'+@LastName+'%'
		AND MemberFirstName LIKE @FirstName+'%'
		AND @DOB IS NULL)
		OR
		(@Memberid IS NULL
		AND @MVDID IS NULL
		AND @FirstName IS NULL 
		AND @LastName	IS NOT NULL
		AND MemberLastName LIKE '%'+@LastName+'%'
		AND @DOB IS NULL)
		OR
		(@Memberid IS NULL
		AND @MVDID IS NULL
		AND D.DateOfBirth = @DOB
		AND @DOB IS NOT NULL)
		OR
		(@Memberid IS NULL
		AND @MVDID IS NULL
		AND @LastName IS NULL
		AND @DOB IS NULL 
		AND @Phone IS NOT NULL
		AND D.HomePhone = @Phone)
		OR
		(@Memberid IS NOT NULL
		AND D.MemberId LIKE @Memberid+'%'
		AND (@MVDID IS NULL OR D.MVDId = @MVDID))
		OR
		(@Memberid IS NULL
		AND @MVDID IS NOT NULL
		AND D.MVDId = @MVDID)
		)

		--CREATE INDEX IX_#MPD_ICENUMBER ON #MPD (ICENUMBER)

		IF (@UserName IS NOT NULL)
		BEGIN
			DECLARE @TIN_MVDID TABLE (MVDID VARCHAR(30))
			
			INSERT INTO @TIN_MVDID(MVDID)
			SELECT DISTINCT MPD.ICENUMBER 
			FROM #MPD MPD 
			LEFT JOIN dbo.MainSpecialist SP ON MPD.ICENUMBER = SP.ICENUMBER	
			LEFT JOIN dbo.Link_MDGroupNPI MDNPI ON MDNPI.NPI = SP.NPI
			LEFT JOIN dbo.MDGroup MDG ON MDG.ID = MDNPI.MDGroupID AND MDG.GroupName = SP.TIN
			LEFT JOIN dbo.Link_MDAccountGroup L_MDA ON L_MDA.MDGroupID = MDG.ID
			LEFT JOIN dbo.MDUser MDU ON MDU.ID = L_MDA.MDAccountID 
			WHERE SP.RoleID = 1 
			AND MDU.Username = @UserName
			
			UPDATE #MPD 
			SET BreakGlass = 1
			WHERE ICENUMBER NOT IN (SELECT MVDID FROM @TIN_MVDID)
           
		END
	END	
	-- Special Case: Where MemberID or LastName, FirstName can typed in the search criteria
	IF (@MemberID IS NOT NULL OR @Spl_FirstName IS NOT NULL OR @Spl_LastName IS NOT NULL)
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
		FROM dbo.FinalMember D
		WHERE D.CustID = @Cust_ID
		AND D.BaseBatchID <> 0 and D.CurrentBatchID <> 0 -- Exclude Temporary Members
		AND @MemberID IS NOT NULL 
		AND D.MemberId  = @MemberID
		AND
		(
		(@CanSeeAllMembers = 1 and D.HealthPlanEmployeeFlag in ('1','0'))
		or
		(@CanSeeAllMembers = 0 and D.HealthPlanEmployeeFlag in ('0'))
		)
		
		IF NOT EXISTS (Select 1 from #MPDS)
		BEGIN
			INSERT INTO #MPDS (ICENUMBER,FirstName, LastName, DOB, GenderID, Address1, Address2, City, [State], PostalCode, HomePhone, WorkPhone, CellPhone, FaxPhone ,Email, Ethnicity, [Language], InCaseManagement, InsMemberId)
			SELECT
			 D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, D.Address1, D.Address2, D.City, D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
		,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId 	 		
			FROM dbo.FinalMember D
			WHERE 
			@MemberID IS NOT NULL 
			AND D.MemberId LIKE  '%'+ @MemberID +'%'
			AND D.BaseBatchID <> 0 and D.CurrentBatchID <> 0 -- Exclude Temporary Members
			AND
			(
			(@CanSeeAllMembers = 1 and D.HealthPlanEmployeeFlag in ('1','0'))
			or
			(@CanSeeAllMembers = 0 and D.HealthPlanEmployeeFlag in ('0'))
			)
			UNION ALL
			SELECT
			 D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, D.Address1, D.Address2, D.City, D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
		    ,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId 	
			FROM dbo.FinalMember D
			WHERE D.CustID = @Cust_ID
			AND D.BaseBatchID <> 0 and D.CurrentBatchID <> 0 -- Exclude Temporary Members
			AND @MemberID IS NULL
			AND (MemberFirstName +' '+ MemberLastName =  @Spl_FirstName+' '+ @Spl_LastName OR MemberFirstName +' '+ MemberLastName =  @Spl_LastName+' '+ @Spl_FirstName)
			AND
			(
			(@CanSeeAllMembers = 1 and D.HealthPlanEmployeeFlag in ('1','0'))
			or
			(@CanSeeAllMembers = 0 and D.HealthPlanEmployeeFlag in ('0'))
			)
		END
        
		IF NOT EXISTS (Select 1 from #MPDS)
		BEGIN
			INSERT INTO #MPDS (ICENUMBER,FirstName, LastName, DOB, GenderID, Address1, Address2, City, [State], PostalCode, HomePhone, WorkPhone, CellPhone, FaxPhone ,Email, Ethnicity, [Language], InCaseManagement, InsMemberId)
			SELECT
			 D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, D.Address1, D.Address2, D.City, D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
		    ,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId 			
			FROM dbo.FinalMember D
			WHERE D.CustID = @Cust_ID
			AND D.BaseBatchID <> 0 and D.CurrentBatchID <> 0 -- Exclude Temporary Members
			AND @MemberID IS NULL
			AND (MemberLastName = @Spl_LastName  OR MemberFirstName = @Spl_FirstName)
			AND
			(
			(@CanSeeAllMembers = 1 and D.HealthPlanEmployeeFlag in ('1','0'))
			or
			(@CanSeeAllMembers = 0 and D.HealthPlanEmployeeFlag in ('0'))
			)
		END

		--CREATE INDEX IX_#MPDS_ICENUMBER ON #MPDS (ICENUMBER)

		IF (@UserName IS NOT NULL)
		BEGIN
			DECLARE @TIN_MVDIDs TABLE (MVDID VARCHAR(30))

			INSERT INTO @TIN_MVDIDs(MVDID)
			SELECT DISTINCT MPD.ICENUMBER 
			FROM #MPDS MPD 
			LEFT JOIN dbo.MainSpecialist SP ON MPD.ICENUMBER = SP.ICENUMBER	
			LEFT JOIN dbo.Link_MDGroupNPI MDNPI ON MDNPI.NPI = SP.NPI
			LEFT JOIN dbo.MDGroup MDG ON MDG.ID = MDNPI.MDGroupID AND MDG.GroupName = SP.TIN
			LEFT JOIN dbo.Link_MDAccountGroup L_MDA ON L_MDA.MDGroupID = MDG.ID
			LEFT JOIN dbo.MDUser MDU ON MDU.ID = L_MDA.MDAccountID 
			WHERE SP.RoleID = 1 
			AND (MDU.Username = @UserName)

			UPDATE #MPDS 
			SET BreakGlass = 1
			WHERE ICENUMBER NOT IN (SELECT MVDID FROM @TIN_MVDIDs)

		END
	END
	      

	IF (@MemberID IS NOT NULL OR @Spl_FirstName IS NOT NULL OR @Spl_LastName IS NOT NULL)
	BEGIN
		SELECT @MVDIDCount = COUNT(DISTINCT MPD.ICENUMBER)
		FROM #MPDS MPD
		WHERE ((LastName = @Spl_LastName
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
		WHERE ((MPD.InsMemberId = @Memberid OR @Memberid IS NULL) AND (MPD.ICENUMBER = @MVDID OR @MVDID IS NULL) )
		AND (MPD.LastName LIKE @LastName+'%' OR @LastName	IS NULL)
		AND (MPD.FirstName LIKE @FirstName+'%' OR @FirstName IS NULL)
		AND (MPD.DOB = @DOB OR @DOB IS NULL)
		AND (MPD.City = @City OR @City IS NULL)
		AND (MPD.State = @State OR @State IS NULL)
		AND (MPD.PostalCode = @Zipcode OR @Zipcode IS NULL)
		AND (MPD.HomePhone = @Phone OR @Phone IS NULL)
	END

		DROP TABLE IF EXISTS #P;

		SELECT ICENUMBER, SUM(BilledAmount) AS BilledAmountLast6Months
		INTO #P
		FROM dbo.MainMedicationPayments M
		WHERE FillDate > DATEADD(MM, -6, @Today)
		GROUP BY ICENUMBER

		DROP TABLE IF EXISTS #RXT;
		SELECT ICENUMBER, BilledAmountLast6Months, AvgBilledAmountLast6Months = (SELECT AVG(BilledAmountLast6Months) FROM #P)
		INTO #RXT
		FROM #P

		DROP TABLE IF EXISTS #RXP;
		SELECT 	 
		 ICENUMBER
		,BilledAmountLast6Months
		,AvgBilledAmountLast6Months
		,CASE WHEN BilledAmountLast6Months > AvgBilledAmountLast6Months*1.5 THEN 1 ELSE 0 END AS IsHighRx
		INTO #RXP
		FROM #RXT
		ORDER BY ICENUMBER

		CREATE NONCLUSTERED INDEX [IX_#RXP] ON #RXP ([ICENUMBER]) INCLUDE ([BilledAmountLast6Months],[IsHighRx])

		IF (@MemberID IS NOT NULL OR @Spl_FirstName IS NOT NULL OR @Spl_LastName IS NOT NULL)
		BEGIN
			INSERT INTO #FinalResult
			(
			ICENUMBER, InsMemberId, FirstName, LastName, DOB, Gender, Address1, Address2, City, State, PostalCode, HomePhone, WorkPhone, 
			CellPhone, FaxPhone, Email
			)
			SELECT TOP (100)
			 MPD.ICENUMBER 
			,MPD.InsMemberId 
			,MPD.FirstName 
			,MPD.LastName 
			,CAST(MPD.DOB AS DATE) AS DOB
			,GenderID
			,MPD.Address1 
			,MPD.Address2 
			,MPD.City 
			,MPD.[State]
			,MPD.PostalCode 
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.HomePhone,' ','')))) AS HomePhone
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.WorkPhone,' ','')))) AS WorkPhone
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.CellPhone,' ','')))) AS CellPhone
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.FaxPhone,' ','')))) AS FaxPhone
			,MPD.Email 
			FROM #MPDS MPD
			LEFT JOIN dbo.MainInsurance IH ON MPD.ICENUMBER = IH.ICENUMBER
			LEFT JOIN dbo.MainSpecialist SP ON MPD.ICENUMBER = SP.ICENUMBER AND SP.RoleID = 1
			LEFT JOIN 
			(
				SELECT ML.MVDID
				FROM dbo.Link_Device_MVDMember ML
				JOIN
				(
					SELECT MVDID, MAX(ID) AS ID
					FROM dbo.Link_Device_MVDMember
					GROUP BY MVDID
				) ML2 ON ML.ID = ML2.ID
			) MobileL ON MPD.ICENUMBER = MobileL.MVDID
			LEFT JOIN dbo.MainCareInfo MC ON MPD.ICENUMBER = MC.ICENUMBER
			LEFT JOIN #RXP RXP ON MPD.ICENUMBER = RXP.ICENUMBER
			LEFT JOIN 
				(
					SELECT MR.MVDID,MR.MonthID,MR.ReportDate,MR.HCC_Score_Adj,MR.HCC_Score_NonAdj,MR.Charlson_Score,MR.Elixhauser_Score
					FROM dbo.MainRisk MR
					JOIN
					(
						SELECT MAX(MonthID) AS MonthID, MVDID
						FROM dbo.MainRisk 
						GROUP BY MVDID
					) MMR ON MR.MVDID = MMR.MVDID AND MR.MonthID = MMR.MonthID
				) mr ON MPD.ICENUMBER = mr.MVDID
			LEFT JOIN
				(
					SELECT S.MVDID, COUNT(*) AS NotesCount
					FROM dbo.HPAlertNote S
					WHERE 
					S.NoteTypeID IN (12,13,14,15)
					GROUP BY S.MVDID
				) N ON MPD.ICENUMBER = N.MVDID
			LEFT JOIN dbo.ParklandPCCICOPCRisk PCR ON MPD.ICENUMBER = PCR.MVDID
			OUTER APPLY
			(
				SELECT 
				 COUNT(*) AS ER_12months
				,SUM(CASE WHEN VisitDate >= DATEADD(MM, -6, GETDATE()) AND VisitDate < DATEADD(DD, 1, GETDATE()) THEN 1 ELSE 0 END) AS ER_6months
				FROM dbo.EDVisitHistory 
				WHERE VisitType = 'ER' 
				AND VisitDate >= DATEADD(MM, -6, GETDATE()) 
				AND VisitDate < DATEADD(DD, 1, GETDATE())
				AND ICENUMBER = MPD.ICENUMBER
			) ER
			OUTER APPLY
			(
				SELECT TOP (1) LockedBy
				FROM dbo.HPAlert A 
				WHERE LockedBy IS NOT NULL
				AND MemberID = MPD.InsMemberId
			) A
			OUTER APPLY
			(
				SELECT TOP (1) HasAsthma, HasDiabetes, TestDueList
				FROM dbo.Final_AllMember 
				WHERE MVDID = MPD.ICENUMBER
				AND CustID = @Cust_ID
				AND MonthID = @MaxMonthID
			) M
			WHERE 
			((MPD.LastName = @Spl_LastName 
				OR MPD.FirstName = @Spl_FirstName 
				OR MPD.FirstName +' '+ MPD.LastName =  @Spl_FirstName+' '+ @Spl_LastName
				OR MPD.FirstName +' '+ MPD.LastName =  @Spl_LastName+' '+ @Spl_FirstName
				OR @Spl_LastName IS NULL 
				OR @Spl_FirstName IS NULL
			)
			AND 
			(MPD.InsMemberId LIKE '%'+ @MemberID +'%' OR @MemberID IS NULL))
			ORDER BY MPD.InsMemberId
		END
		ELSE 
		BEGIN
			INSERT INTO #FinalResult
			(
			ICENUMBER, InsMemberId, FirstName, LastName, DOB, Gender, Address1, Address2, City, State, PostalCode, HomePhone, WorkPhone, 
			CellPhone, FaxPhone, Email
			)
			SELECT TOP (100)
			 MPD.ICENUMBER 
			,MPD.InsMemberId 
			,MPD.FirstName 
			,MPD.LastName 
			,CAST(MPD.DOB AS DATE) AS DOB
			,GenderID
			,MPD.Address1 
			,MPD.Address2 
			,MPD.City 
			,MPD.[State]
			,MPD.PostalCode 
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.HomePhone,' ','')))) AS HomePhone
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.WorkPhone,' ','')))) AS WorkPhone
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.CellPhone,' ','')))) AS CellPhone
			,dbo.FormatPhone(LTRIM(RTRIM(REPLACE(MPD.FaxPhone,' ','')))) AS FaxPhone
			,MPD.Email 
			FROM #MPD MPD
			LEFT JOIN dbo.MainInsurance IH ON MPD.ICENUMBER = IH.ICENUMBER
			LEFT JOIN dbo.MainSpecialist SP ON MPD.ICENUMBER = SP.ICENUMBER AND SP.RoleID = 1
			LEFT JOIN 
			(
				SELECT ML.MVDID
				FROM dbo.Link_Device_MVDMember ML
				JOIN
				(
					SELECT MVDID, MAX(ID) AS ID
					FROM dbo.Link_Device_MVDMember
					GROUP BY MVDID
				) ML2 ON ML.ID = ML2.ID
			) MobileL ON MPD.ICENUMBER = MobileL.MVDID
			LEFT JOIN dbo.MainCareInfo MC ON MPD.ICENUMBER = MC.ICENUMBER
			LEFT JOIN #RXP RXP ON MPD.ICENUMBER = RXP.ICENUMBER
			LEFT JOIN 
				(
					SELECT MR.MVDID,MR.MonthID,MR.ReportDate,MR.HCC_Score_Adj,MR.HCC_Score_NonAdj,MR.Charlson_Score,MR.Elixhauser_Score
					FROM dbo.MainRisk MR
					JOIN
					(
						SELECT MAX(MonthID) AS MonthID, MVDID
						FROM dbo.MainRisk 
						GROUP BY MVDID
					) MMR ON MR.MVDID = MMR.MVDID AND MR.MonthID = MMR.MonthID
				) mr ON MPD.ICENUMBER = mr.MVDID
			LEFT JOIN
				(
					SELECT S.MVDID, COUNT(*) AS NotesCount
					FROM dbo.HPAlertNote S
					WHERE 
					S.NoteTypeID IN (12,13,14,15)
					GROUP BY S.MVDID
				) N ON MPD.ICENUMBER = N.MVDID
			LEFT JOIN dbo.ParklandPCCICOPCRisk PCR ON MPD.ICENUMBER = PCR.MVDID
			OUTER APPLY
			(
				SELECT 
				 COUNT(*) AS ER_12months
				,SUM(CASE WHEN VisitDate >= DATEADD(MM, -6, GETDATE()) AND VisitDate < DATEADD(DD, 1, GETDATE()) THEN 1 ELSE 0 END) AS ER_6months
				FROM dbo.EDVisitHistory 
				WHERE VisitType = 'ER' 
				AND VisitDate >= DATEADD(MM, -6, GETDATE()) 
				AND VisitDate < DATEADD(DD, 1, GETDATE())
				AND ICENUMBER = MPD.ICENUMBER
			) ER
			OUTER APPLY
			(
				SELECT TOP (1) LockedBy
				FROM dbo.HPAlert A 
				WHERE LockedBy IS NOT NULL
				AND MemberID = MPD.InsMemberId
			) A
			OUTER APPLY
			(
				SELECT TOP (1) HasAsthma, HasDiabetes, TestDueList
				FROM dbo.Final_AllMember 
				WHERE MVDID = MPD.ICENUMBER
				AND CustID = @Cust_ID
				AND MonthID = @MaxMonthID
			) M
			WHERE (MPD.LastName LIKE @LastName+'%' OR @LastName	IS NULL)
			AND (MPD.FirstName LIKE @FirstName+'%' OR @FirstName IS NULL)
			AND (MPD.DOB = @DOB OR @DOB IS NULL)
			AND (MPD.City = @City OR @City IS NULL)
			AND (MPD.State = @State OR @State IS NULL)
			AND (MPD.PostalCode = @Zipcode OR @Zipcode IS NULL)
			AND (MPD.HomePhone = @Phone OR @Phone IS NULL)
			ORDER BY MPD.InsMemberId
		END

	-- Get hedis test due for those who have been recently entered in HedisTestStatus
	DROP TABLE IF EXISTS #HTS;
	SELECT DISTINCT MVDID
	INTO #HTS
	FROM dbo.HedisTestStatus
	WHERE MVDID IN (SELECT ICENUMBER FROM #FinalResult)
	AND TestID IS NOT NULL
	AND StatusID = 16
	AND Created >= DATEADD(DD, -8, GETDATE())

	DROP TABLE IF EXISTS #HTDM;
	SELECT HTS.MVDID
	,CAST(SUBSTRING(
	( 
		SELECT DISTINCT ','+CAST(Abbreviation AS VARCHAR(10)) 
		FROM dbo.Final_HEDIS_Member_FULL F
		JOIN dbo.LookupHedis l ON F.TestID = l.id
		WHERE F.MVDID = HTS.MVDID
		AND F.CustID = @Cust_ID
		AND F.MonthID = @MaxMonthID
		AND F.IsTestDue = 0
		AND NOT EXISTS
		(
			SELECT 1
			FROM dbo.HedisTestStatus TS
			WHERE TS.MVDID IN (SELECT MVDID FROM #HTS)
			AND TS.TestID IS NOT NULL
			AND TS.StatusID = 16
			AND TS.Created >= DATEFROMPARTS(YEAR(GETDATE()),'01', '01')
			AND TS.TestID = F.TestID
			AND TS.MVDID = F.MVDID
		)
		FOR XML PATH('')),2,200000
	) AS VARCHAR(2000)) AS HedisDue
	INTO #HTDM
	FROM #HTS HTS

-- Final Output Result
	declare @bit BIT = 1

	SELECT Distinct
	 MPD.ICENUMBER, MPD.InsMemberId, MPD.FirstName, MPD.LastName, MPD.DOB, MPD.Gender, MPD.Address1, MPD.Address2, MPD.City, MPD.[State],'' as CountyName
	,MPD.PostalCode, MPD.HomePhone, MPD.WorkPhone, MPD.CellPhone, MPD.FaxPhone, MPD.Email, '' as Ethnicity, '' as Language, GetDate() as EffectiveDate,
	GetDate() as TerminationDate, '' as PCP, '' as PCP_Address,
    '' as PCP_City,
    '' as PCP_State,
    '' as PCP_Postal,
    '' as PCP_Phone,
    @bit as RegMobileApp,
    '' as HeadOfHousehold,
    '' as Housing_Status,
    '' as Homeless,
    null as Household_Size,
    '' as CitizenshipStatus,
    '' as FPL_Level,
    '' as HighER,
    @bit as HasAsthma,
    @bit as HasDiabetes,
    @bit as InCaseManagement,
    '' as HEDISDue,
    '' as TIN,
    '' as LockedBy,
    '' as CaseID,
    '' as CaseStatus,
    @bit as IsHighER,
    '' as ERVisitDescription,
    @bit as IsHighRX,
    0.0 as RXAvgCost,
    '' as RXDescription,
    @bit as IsHighUtil,
    0.0 as HighUtilCost,
    '' as HighUtilDescription,
    0.0 as HCCScore,
    null as ElixhauserScore,
    null as CharlsonScore,
    null as NotesCount,
    '' as PCCIRiskscore,
    @bit as CSME_FLG,
    '' as HealthPlanEmployeeFlag,
	'' as LOB,
    '' as CM_ORG_REGION,
    '' as Branding_Name,
    '' as CompanyName,
    '' as Company_Key,
    '' as GroupID,
    '' as GroupName,
    '' as SubGroupID,
    '' as SubGroupName ,
    '' as CSME_LastName,
    '' as CSME_FirstName,
    '' as CSME_MiddleName,
    '' as CSME_Address1,
    '' as CSME_Address2,
    '' as CSME_City,
    '' as CSME_State,
    '' as CSME_PostalCode,
    '' as CSME_HomePhone,
    '' as CSME_CellPhone,
    '' as CSME_WorkPhone,
    '' as CSME_FaxPhone,
    '' as CSME_Email,
    '' as CSME_Language,
    '' as CSME_Ethnicity,
    '' as CSME_Housing,
    @bit as BreakGlass
	FROM #FinalResult MPD 
	LEFT JOIN dbo.CareSpaceMemberEdit ME ON MPD.ICENUMBER = ME.ICENUMBER
	LEFT JOIN #HTDM HTDM ON MPD.ICENUMBER = HTDM.MVDID

END