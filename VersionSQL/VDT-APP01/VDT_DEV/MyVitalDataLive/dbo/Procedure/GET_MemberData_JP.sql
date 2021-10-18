/****** Object:  Procedure [dbo].[GET_MemberData_JP]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Example: EXEC GET_MemberData @Cust_ID = 16, @UserName = N'NULL', @MVDID = N'166784694E72',@Product = NULL,@MVDIDCount = NULL
--					EXEC dbo.GET_MemberData @Cust_ID=16,@UserName=N'NULL',@MVDID=N'161567682A4EB',@Product = NULL,@MVDIDCount = NULL

-- Date				Name			Comments				

-- =============================================
Create PROCEDURE [dbo].[GET_MemberData_JP]
	 @Cust_ID	INT
	,@UserName	VARCHAR(60) = NULL
	,@MVDID		VARCHAR(30) = NULL
	,@Product INT = NULL
	,@MVDIDCount INT OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @MaxMonthID CHAR(6)

	SELECT @MaxMonthID = MAX(MonthID) FROM dbo.Final_ALLMember WHERE CustID = @Cust_ID
	--updated mvdcount
	SET @MVDIDCount = 1
	
	DECLARE @Today DATE

	SELECT @Today = CASE WHEN @Cust_ID = 16 THEN '03/31/2016' ELSE GETDATE() END

	DROP TABLE IF EXISTS #FinalResult
	CREATE TABLE #FinalResult
	(
		ICENUMBER	varchar(30), InsMemberId	varchar(30), FirstName	varchar(100), LastName	varchar(100), DOB Date, Gender	varchar(30), Address1	varchar(100), Address2	varchar(100), 
		City varchar(100), State	varchar(30), PostalCode	varchar(10), HomePhone	varchar(20), WorkPhone	varchar(20), CellPhone	varchar(20), FaxPhone	varchar(20),Email	varchar(100),
		Ethnicity varchar(100), Language	varchar(100), EffectiveDate	Datetime, TerminationDate Datetime, TIN	varchar(100), PCP	varchar(100), PCP_Address	varchar(500), PCP_City	varchar(100), 
		PCP_State varchar(30), PCP_Postal	varchar(20), PCP_Phone	varchar(20), RegMobileApp BIT, HeadOfHousehold 	varchar(100), Housing_Status	varchar(100), Homeless	varchar(100), Household_Size INT, 
		CitizenshipStatus	varchar(100), FPL_Level	varchar(100), HighER	varchar(10), HasAsthma	BIT, HasDiabetes BIT, InCaseManagement BIT, HedisDue	varchar(2000), LockedBy	varchar(200), 
		CaseID	varchar(100), CaseStatus	varchar(100), IsHighER BIT, ERVisitDescription	varchar(300), IsHighRX	BIT, RXAvgCost	Decimal(10,2), RXDescription	varchar(100), IsHighUtil BIT, 
		HighUtilCost	Decimal(5,2), HighUtilDescription	varchar(100), HCCScore Decimal(5,2), ElixhauserScore varchar(100), CharlsonScore varchar(100), NotesCount INT, PCCIRiskscore varchar(100),
		BreakGlass BIT DEFAULT (0)
	)

	IF (@MVDID IS NULL)
	BEGIN
		DROP TABLE IF EXISTS #MPD;
		CREATE TABLE #MPD
		(
		 ICENUMBER VARCHAR (15), FirstName	VARCHAR (50), LastName	VARCHAR (50), DOB	SMALLDATETIME, GenderID	varchar(1) ,Address1	VARCHAR (128), Address2	VARCHAR (128)
		,City	VARCHAR (50), [State]	VARCHAR (2), PostalCode	VARCHAR (5), HomePhone	VARCHAR (10), WorkPhone	VARCHAR (10), CellPhone	VARCHAR (10), FaxPhone	VARCHAR (10)
		,Email	VARCHAR (100), Ethnicity	NVARCHAR (100), [Language]	VARCHAR (50), InCaseManagement	BIT, InsMemberId	VARCHAR (20), BreakGlass BIT DEFAULT (0)
		)

		INSERT INTO #MPD (ICENUMBER,FirstName,LastName,DOB,GenderID,Address1,Address2,City,State,PostalCode,HomePhone,WorkPhone,CellPhone,FaxPhone,Email,Ethnicity,Language,InCaseManagement,InsMemberId)
		-- MVDId IS NOT NULL
		SELECT 
		 D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, dbo.fnInitCap(D.Address1), dbo.fnInitCap(D.Address2), dbo.fnInitCap(D.City), D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
		,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId  	
		FROM dbo.FinalMember D
		WHERE D.CustID = @Cust_ID
		AND @MVDID IS NOT NULL
		AND D.MVDId = @MVDID
		AND D.HealthPlanEmployeeFlag=0
		
		CREATE INDEX IX_#MPD_ICENUMBER ON #MPD (ICENUMBER)

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
	IF (@MVDID IS NOT NULL )
	BEGIN
		DROP TABLE IF EXISTS #MPDS
		CREATE Table #MPDS 
		(
			ICENUMBER	Varchar(30), FirstName	Varchar(100), LastName	Varchar(100), DOB			Date, GenderID	varchar(1), Address1	Varchar(100), Address2	Varchar(100), City	Varchar(100),
			[State]	Varchar(100), PostalCode	Varchar(20), HomePhone	Varchar(20), WorkPhone	Varchar(20), CellPhone	Varchar(20), FaxPhone	Varchar(20), Email	Varchar(100), 
			Ethnicity	Varchar(30), [Language]	Varchar(30), InCaseManagement BIT ,InsMemberId		Varchar(30),BreakGlass BIT DEFAULT (0)
		)

		INSERT INTO #MPDS (ICENUMBER,FirstName, LastName, DOB, GenderID, Address1, Address2, City, [State], PostalCode, HomePhone, WorkPhone, CellPhone, FaxPhone ,Email, Ethnicity, [Language], InCaseManagement, InsMemberId)
		SELECT
		 D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, dbo.fnInitCap(D.Address1), dbo.fnInitCap(D.Address2), dbo.fnInitCap(D.City), D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
		,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId  			
		FROM dbo.FinalMember D
		WHERE D.CustID = @Cust_ID
		AND @MVDID IS NOT NULL 
		AND D.MVDID  = @MVDID
		AND D.HealthPlanEmployeeFlag=0

		Create Table #FinalEligibility
		(
		[MVDID] varchar(30),
		[MemberEffectiveDate] date,
		[MemberTerminationDate] date,
		[LOB] varchar(50),
		PCP varchar(150), 
		PCP_Address varchar(200),
		PCP_City varchar(50),
		PCP_State varchar(2),
		PCP_Postal varchar(9),
		PCP_Phone varchar(10)
		)


		IF EXISTS (Select 1 from #MPDS Where @Cust_ID= 16)
		BEGIN
		Insert Into #FinalEligibility
		Select MVDID, MemberEffectiveDate, Case MemberTerminationDate When '9999-12-31' Then NULL Else MemberTerminationDate End, LOB,
		dbo.fnInitCap(ISNULL(ProviderFirstname + ' ','') + ISNULL(ProviderLastname,'')) as PCP,
		dbo.fnInitCap(ISNULL(ServiceAddress1 + ' ', '') + ISNULL(ServiceAddress2,'')) as PCP_Address,
		dbo.fnInitCap(ISNULL(ServiceCity, '')) as PCP_City,
		ServiceState as PCP_State,
		ServiceZip as PCP_Postal,
		ServicePhone as PCP_Phone
		From vwRecentMemberEligibility
		Where MVDID in (Select ICENUMBER From #MPDS)
		END

		IF NOT EXISTS (Select 1 from #MPDS)
		BEGIN
			INSERT INTO #MPDS (ICENUMBER,FirstName, LastName, DOB, GenderID, Address1, Address2, City, [State], PostalCode, HomePhone, WorkPhone, CellPhone, FaxPhone ,Email, Ethnicity, [Language], InCaseManagement, InsMemberId)
			SELECT
			 D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, dbo.fnInitCap(D.Address1), dbo.fnInitCap(D.Address2), dbo.fnInitCap(D.City), D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
		     ,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId 	 		
			FROM dbo.FinalMember D
			WHERE 
			@MVDID IS NOT NULL 
			AND D.MVDID LIKE  '%'+ @MVDID +'%'
			AND D.HealthPlanEmployeeFlag=0
			UNION ALL
			SELECT
			 D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, dbo.fnInitCap(D.Address1), dbo.fnInitCap(D.Address2), dbo.fnInitCap(D.City), D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
		    ,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId 	
			FROM dbo.FinalMember D
			WHERE D.CustID = @Cust_ID
			AND @MVDID IS NULL
			AND D.HealthPlanEmployeeFlag=0
		END

		IF NOT EXISTS (Select 1 from #MPDS)
		BEGIN
			INSERT INTO #MPDS (ICENUMBER,FirstName, LastName, DOB, GenderID, Address1, Address2, City, [State], PostalCode, HomePhone, WorkPhone, CellPhone, FaxPhone ,Email, Ethnicity, [Language], InCaseManagement, InsMemberId)
			SELECT
			 D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, dbo.fnInitCap(D.Address1), dbo.fnInitCap(D.Address2), dbo.fnInitCap(D.City), D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
		    ,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId 			
			FROM dbo.FinalMember D
			WHERE D.CustID = @Cust_ID
			AND @MVDID IS NULL
			AND D.HealthPlanEmployeeFlag=0
		END

		CREATE INDEX IX_#MPDS_ICENUMBER ON #MPDS (ICENUMBER)

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

	IF (@MVDID IS NOT NULL )
	BEGIN
		SELECT @MVDID = COUNT(DISTINCT MPD.ICENUMBER)
		FROM #MPDS MPD
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

		IF (@MVDID IS NOT NULL )
		BEGIN
			INSERT INTO #FinalResult
			(
			ICENUMBER, InsMemberId, FirstName, LastName, DOB, Gender, Address1, Address2, City, State, PostalCode, HomePhone, WorkPhone, 
			CellPhone, FaxPhone, Email, Ethnicity, Language, EffectiveDate, TerminationDate, TIN, PCP, PCP_Address, PCP_City, PCP_State, 
			PCP_Postal, PCP_Phone, RegMobileApp, HeadOfHousehold, Housing_Status, Homeless, Household_Size, CitizenshipStatus, FPL_Level, 
			HighER, HasAsthma, HasDiabetes, InCaseManagement, HedisDue, LockedBy, CaseID, CaseStatus, IsHighER, ERVisitDescription, IsHighRX, 
			RXAvgCost, RXDescription, IsHighUtil, HighUtilCost, HighUtilDescription, HCCScore, ElixhauserScore, CharlsonScore, NotesCount, PCCIRiskscore, BreakGlass
			)
			SELECT TOP (100)
			 MPD.ICENUMBER 
			,MPD.InsMemberId 
			,MPD.FirstName 
			,MPD.LastName 
			,CAST(MPD.DOB AS DATETIME) AS DOB
			,MPD.GenderID
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
			,CAST(MPD.Ethnicity AS VARCHAR(100)) AS Ethnicity
			,CAST(MPD.[Language] AS VARCHAR(100)) AS [Language]
			,IsNULL(IH.EffectiveDate, FE.MemberEffectiveDate) as EffectiveDate
			,IsNULL(IH.TerminationDate, FE.MemberTerminationDate) as TerminationDate
			,SP.TIN	AS TIN 
			,IsNULL(SP.FirstName +' '+ SP.LastName, FE.PCP) AS PCP 
			,IsNULL(SP.Address1, FE.PCP_Address) AS PCP_Address 
			,IsNULL(SP.City, FE.PCP_City) AS PCP_City 
			,IsNULL(SP.State, FE.PCP_State) AS PCP_State 
			,IsNULL(SP.Postal, FE.PCP_Postal) AS PCP_Postal 
			,IsNULL(SP.Phone, FE.PCP_Phone) AS PCP_Phone
			,CASE WHEN MobileL.MVDID IS NULL THEN '0' ELSE '1' END AS RegMobileApp
			,CASE WHEN (MPD.FirstName = ISNULL(MC.FirstName,'') AND MPD.LastName = ISNULL(MC.LastName,'')) THEN '1' ELSE '0' END AS HeadOfHousehold
			,CAST(NULL AS VARCHAR(50)) AS Housing_Status
			,CAST(NULL AS VARCHAR(100)) AS Homeless
			,CAST(NULL AS INT) AS Household_Size
			,CAST(NULL AS VARCHAR(50)) AS CitizenshipStatus
			,CAST(NULL AS VARCHAR(50)) AS FPL_Level
			,CASE WHEN ER.ER_6months > 1 THEN ER.ER_6months	WHEN ER.ER_12months > 2 THEN ER.ER_12months ELSE 0 END AS HighER
			,M.HasAsthma
			,M.HasDiabetes
			,CAST(ISNULL(MPD.InCaseManagement,0) AS BIT) AS InCaseManagement
			,M.TestDueList AS HedisDue
			,A.LockedBy
			,CAST(NULL AS VARCHAR(100)) AS CaseID 
			,CAST(NULL AS VARCHAR(20)) AS CaseStatus
			,IsHighER = CAST(CASE WHEN ER.ER_6months >= 3 THEN 1 ELSE 0 END AS BIT)
			,ERVisitDescription = CAST(ER.ER_6months AS VARCHAR(10))+' visits in the last 6 months'
			,IsHighRX =  CAST(ISNULL(RXP.IsHighRx,0) AS BIT)
			,RXAvgCost = ISNULL(RXP.BilledAmountLast6Months,0.00)
			,RXDescription = ' RX Totals of $'+CAST(RXP.BilledAmountLast6Months AS VARCHAR(25))+' in the last 6 months'
			,IsHighUtil = CAST(CASE WHEN mr.HCC_Score_Adj > 5 THEN 1 ELSE 0 END AS BIT)
			,HighUtilCost = CAST(mr.HCC_Score_Adj AS DECIMAL(5,2))
			,HighUtilDescription = 'Has an HCC Score of '+CAST(mr.HCC_Score_Adj AS VARCHAR(25))+' '
			,CAST(mr.HCC_Score_Adj AS DECIMAL(5,2)) AS HCCScore
			,mr.Elixhauser_Score AS ElixhauserScore
			,mr.Charlson_Score AS CharlsonScore
			,ISNULL(N.NotesCount, 0) AS NotesCount
			,PCR.RiskScores AS PCCIRiskscore
			,MPD.BreakGlass
			FROM #MPDS MPD
			LEFT JOIN dbo.MainInsurance IH ON MPD.ICENUMBER = IH.ICENUMBER
			LEFT JOIN #FinalEligibility FE ON MPD.ICENUMBER = FE.MVDID
			LEFT JOIN dbo.MainSpecialist SP ON MPD.ICENUMBER = SP.ICENUMBER AND SP.RoleID = 1
			LEFT JOIN 
			(
				SELECT ML.MVDID
				FROM MobileMVDLive.dbo.Link_Device_MVDMember ML
				JOIN
				(
					SELECT MVDID, MAX(ID) AS ID
					FROM MobileMVDLive.dbo.Link_Device_MVDMember
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
			(@MVDID LIKE '%'+ @MVDID +'%' OR @MVDID IS NULL)
			
		END
		ELSE 
		BEGIN
			INSERT INTO #FinalResult
			(
			ICENUMBER, InsMemberId, FirstName, LastName, DOB, Gender, Address1, Address2, City, State, PostalCode, HomePhone, WorkPhone, 
			CellPhone, FaxPhone, Email, Ethnicity, Language, EffectiveDate, TerminationDate, TIN, PCP, PCP_Address, PCP_City, PCP_State, 
			PCP_Postal, PCP_Phone, RegMobileApp, HeadOfHousehold, Housing_Status, Homeless, Household_Size, CitizenshipStatus, FPL_Level, 
			HighER, HasAsthma, HasDiabetes, InCaseManagement, HedisDue, LockedBy, CaseID, CaseStatus, IsHighER, ERVisitDescription, IsHighRX, 
			RXAvgCost, RXDescription, IsHighUtil, HighUtilCost, HighUtilDescription, HCCScore, ElixhauserScore, CharlsonScore, NotesCount, PCCIRiskscore, BreakGlass
			)
			SELECT TOP (100)
			 MPD.ICENUMBER 
			,MPD.InsMemberId 
			,MPD.FirstName 
			,MPD.LastName 
			,CAST(MPD.DOB AS DATETIME) AS DOB
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
			,CAST(MPD.Ethnicity AS VARCHAR(100)) AS Ethnicity
			,CAST(MPD.[Language] AS VARCHAR(100)) AS [Language]
			,IH.EffectiveDate
			,IH.TerminationDate
			,SP.TIN	AS TIN 
			,SP.FirstName +' '+ SP.LastName AS PCP 
			,SP.Address1 AS PCP_Address 
			,SP.City AS PCP_City 
			,SP.State AS PCP_State 
			,SP.Postal AS PCP_Postal 
			,SP.Phone AS PCP_Phone
			,CASE WHEN MobileL.MVDID IS NULL THEN '0' ELSE '1' END AS RegMobileApp
			,CASE WHEN (MPD.FirstName = ISNULL(MC.FirstName,'') AND MPD.LastName = ISNULL(MC.LastName,'')) THEN '1' ELSE '0' END AS HeadOfHousehold
			,CAST(NULL AS VARCHAR(50)) AS Housing_Status
			,CAST(NULL AS VARCHAR(100)) AS Homeless
			,CAST(NULL AS INT) AS Household_Size
			,CAST(NULL AS VARCHAR(50)) AS CitizenshipStatus
			,CAST(NULL AS VARCHAR(50)) AS FPL_Level
			,CASE WHEN ER.ER_6months > 1 THEN ER.ER_6months	WHEN ER.ER_12months > 2 THEN ER.ER_12months ELSE 0 END AS HighER
			,M.HasAsthma
			,M.HasDiabetes
			,CAST(ISNULL(MPD.InCaseManagement,0) AS BIT) AS InCaseManagement
			,M.TestDueList AS HedisDue
			,A.LockedBy
			,CAST(NULL AS VARCHAR(100)) AS CaseID 
			,CAST(NULL AS VARCHAR(20)) AS CaseStatus
			,IsHighER = CAST(CASE WHEN ER.ER_6months >= 3 THEN 1 ELSE 0 END AS BIT)
			,ERVisitDescription = CAST(ER.ER_6months AS VARCHAR(10))+' visits in the last 6 months'
			,IsHighRX =  CAST(ISNULL(RXP.IsHighRx,0) AS BIT)
			,RXAvgCost = ISNULL(RXP.BilledAmountLast6Months,0.00)
			,RXDescription = ' RX Totals of $'+CAST(RXP.BilledAmountLast6Months AS VARCHAR(25))+' in the last 6 months'
			,IsHighUtil = CAST(CASE WHEN mr.HCC_Score_Adj > 5 THEN 1 ELSE 0 END AS BIT)
			,HighUtilCost = CAST(mr.HCC_Score_Adj AS DECIMAL(5,2))
			,HighUtilDescription = 'Has an HCC Score of '+CAST(mr.HCC_Score_Adj AS VARCHAR(25))+' '
			,CAST(mr.HCC_Score_Adj AS DECIMAL(5,2)) AS HCCScore
			,mr.Elixhauser_Score AS ElixhauserScore
			,mr.Charlson_Score AS CharlsonScore
			,ISNULL(N.NotesCount, 0) AS NotesCount
			,PCR.RiskScores AS PCCIRiskscore
			,MPD.BreakGlass
			FROM #MPD MPD
			LEFT JOIN dbo.MainInsurance IH ON MPD.ICENUMBER = IH.ICENUMBER
			LEFT JOIN dbo.MainSpecialist SP ON MPD.ICENUMBER = SP.ICENUMBER AND SP.RoleID = 1
			LEFT JOIN 
			(
				SELECT ML.MVDID
				FROM MobileMVDLive.dbo.Link_Device_MVDMember ML
				JOIN
				(
					SELECT MVDID, MAX(ID) AS ID
					FROM MobileMVDLive.dbo.Link_Device_MVDMember
					GROUP BY MVDID
				) ML2 ON ML.ID = ML2.ID
			) MobileL ON MPD.ICENUMBER = MobileL.MVDID
			LEFT JOIN dbo.MainCareInfo MC ON MPD.ICENUMBER = MC.ICENUMBER
			LEFT JOIN dbo.Link_Gender_MVD_Ins G ON MPD.GenderID = G.MVDGenderId
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
				UNION
				SELECT 
				 COUNT(*) AS ER_12months
				,SUM(CASE WHEN VisitDate >= DATEADD(MM, -6, GETDATE()) AND VisitDate < DATEADD(DD, 1, GETDATE()) THEN 1 ELSE 0 END) AS ER_6months
				FROM dbo.ComputedMemberEncounterHistory 
				WHERE VisitType = 'ER' 
				AND VisitDate >= DATEADD(MM, -6, GETDATE()) 
				AND VisitDate < DATEADD(DD, 1, GETDATE())
				AND MVDID = MPD.ICENUMBER

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
	SELECT TOP 1
	 MPD.ICENUMBER, MPD.InsMemberId, dbo.fnInitCap(MPD.FirstName) as FirstName, dbo.fnInitCap(MPD.LastName) as LastName, MPD.DOB, MPD.Gender, dbo.fnInitCap(MPD.Address1) as Address1, dbo.fnInitCap(MPD.Address2) as Address2, dbo.fnInitCap(MPD.City) as City, MPD.[State]
	,MPD.PostalCode, MPD.HomePhone, MPD.WorkPhone, MPD.CellPhone, MPD.FaxPhone, MPD.Email, MPD.Ethnicity, MPD.[Language], MPD.EffectiveDate
	,MPD.TerminationDate, MPD.TIN, MPD.PCP, MPD.PCP_Address, MPD.PCP_City, MPD.PCP_State, MPD.PCP_Postal, MPD.PCP_Phone, MPD.RegMobileApp
	,MPD.HeadOfHousehold, MPD.Housing_Status, MPD.Homeless, MPD.Household_Size, MPD.CitizenshipStatus, MPD.FPL_Level, MPD.HighER, MPD.HasAsthma
	,MPD.HasDiabetes, MPD.InCaseManagement
	,COALESCE(HTDM.HedisDue,MPD.HedisDue) AS HedisDue
	,MPD.LockedBy, MPD.CaseID, MPD.CaseStatus, MPD.IsHighER, MPD.ERVisitDescription, MPD.IsHighRX
	,MPD.RXAvgCost, MPD.RXDescription, MPD.IsHighUtil, MPD.HighUtilCost, MPD.HighUtilDescription, MPD.HCCScore, MPD.ElixhauserScore, MPD.CharlsonScore
	,MPD.NotesCount, MPD.PCCIRiskscore, BreakGlass
	,ME.LastName AS CSME_LastName, ME.FirstName AS CSME_FirstName, ME.MiddleName AS CSME_MiddleName, ME.Address1 AS CSME_Address1, ME.Address2 AS CSME_Address2
	,ME.City AS CSME_City, ME.[State] AS CSME_State, ME.PostalCode AS CSME_PostalCode, ME.HomePhone AS CSME_HomePhone, ME.CellPhone AS CSME_CellPhone
	,ME.WorkPhone AS CSME_WorkPhone, ME.FaxPhone AS CSME_FaxPhone, ME.Email AS CSME_Email, ME.[Language] AS CSME_Language, ME.Ethnicity AS CSME_Ethnicity
	,ME.Housing AS CSME_Housing, case when ME.ICENUMBER is null then cast( 0 as bit) else cast (1 as bit) end as CSME_FLG
	FROM #FinalResult MPD 
	LEFT JOIN dbo.CareSpaceMemberEdit ME ON MPD.ICENUMBER = ME.ICENUMBER
	LEFT JOIN #HTDM HTDM ON MPD.ICENUMBER = HTDM.MVDID
	ORDER BY MPD.EffectiveDate desc
END