/****** Object:  Procedure [dbo].[GET_MemberData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[GET_MemberData]      
@Cust_ID	INT
,@UserName	VARCHAR(60) = NULL
,@MVDID		VARCHAR(30) = NULL
,@Product INT = NULL
,@MVDIDCount INT OUTPUT
AS
/*

Changes
WHO		WHEN		WHAT
Deepank 2020-11-23  Added fields (COBCD,DentalXtra,HealthConditions,MedicalCost,RXCount,ERCount)
Scott	2020-11-30	Change PCPVisitsCount and added LastPCPVisit
Deepank 2020-12-01  Updated HealthConditions to varchar(50)
Scott	2020-12-01	Limited the HealthCondition Abbreviations to 512 chars.
Ed		2021-03-15	CAST( IH.PCPNPI AS varchar(15) ) = FP.NPI in join from FinalProvider to FinalEligibility
Mike	2021-03-16  Apply cast in two more places for PCPNPI per TFS 4874
Scott   2021-03-29  Added CFR and BENI columns at lines 283 and 298
Sunil   2021-04-30  Added FakeSpanId TFS5227
Scott	2021-06-04  Hot fix for #5442.  Change "Virtual Visit" to "Virtual Therapy"
Craig	2021-05-17  Change source of data for the Dental Benefit TFS 5124
Jose	2021-05-19	Add BenefitGroup from ComputerCareQueue to the resulset
Craig	2021-05-28	Add ValBasedProg to the resultset TFS 5148
Craig	2021-06-09	Remove ValBasedProg as standalone field and concatenate with BENI.
Craig	2021-06-09	If @BENI and/or @CFR = '[]', convert to NULL
Luna    2021-06-30  Make Benefitgroup shows up
Luna,Ed 2021-07-01  Changed INNER JOIN to LEFT OUTER JOIN for FinalEligibility to get BenefitGroup
Mike	2021-07-21	Left Join to Computed Maternity to include the larger of two risk scores (TFS 5794)

DECLARE @Ct int
EXEC GET_MemberData @Cust_ID = 16,
                    @UserName = 'Executive1',
					@MVDID = '1611D533E442CA0D8243',
					@Product = NULL,
					@MVDIDCount = @Ct OUTPUT

SELECT MVDID FROM FinalMember WHERE MemberID = 'M1238282800'

*/
BEGIN
	
    SET NOCOUNT ON;

IF @Cust_ID =  16 
  BEGIN
	--DECLARE @MaxMonthID CHAR(6)

	--SELECT @MaxMonthID = MAX(MonthID) FROM dbo.Final_ALLMember WHERE CustID = @Cust_ID
	--updated mvdcount
	SET @MVDIDCount = 1
	
	DECLARE @Today DATE

	Declare @CanSeeAllMembers bit = 0

	Set @CanSeeAllMembers = dbo.[fnABCBSUserMemberCheck](@UserName)

	SELECT @Today = GETDATE()

	DECLARE @MVDMember TABLE
	(
	MVDID varchar(20)
	)

	DROP TABLE IF EXISTS #FinalResult
	CREATE TABLE #FinalResult
	(
		ICENUMBER	varchar(30),
		InsMemberId	varchar(30),
		FirstName	varchar(100),
		LastName	varchar(100),
		DOB Date,
		Gender	varchar(30),
		Address1	varchar(100),
		Address2	varchar(100), 
		City varchar(100),
		State	varchar(30),
		PostalCode	varchar(10),
		HomePhone	varchar(20),
		WorkPhone	varchar(20),
		CellPhone	varchar(20),
		FaxPhone	varchar(20),
		Email	varchar(100),
		Ethnicity varchar(100),
		Language	varchar(100),
		EffectiveDate	Date,
		TerminationDate Date,
		TIN	varchar(100),
		PCP	varchar(100),
		PCP_Address	varchar(500),
		PCP_City	varchar(100), 
		PCP_State varchar(30),
		PCP_Postal	varchar(20),
		PCP_Phone	varchar(20),
		RegMobileApp BIT,
		HeadOfHousehold varchar(100),
		Housing_Status	varchar(100),
		Homeless	varchar(100),
		Household_Size INT, 
		CitizenshipStatus	varchar(100),
		FPL_Level	varchar(100),
		HighER	varchar(10),
		HasAsthma	BIT,
		HasDiabetes BIT,
		InCaseManagement BIT,
		HedisDue	varchar(2000),
		LockedBy	varchar(200), 
		CaseID	varchar(100),
		CaseStatus	varchar(100),
		IsHighER BIT,
		ERVisitDescription	varchar(300),
		IsHighRX	BIT,
		RXAvgCost	Decimal(10,2),
		RXDescription	varchar(100),
		IsHighUtil BIT, 
		HighUtilCost	Decimal(5,2),
		HighUtilDescription	varchar(100),
		HCCScore Decimal(5,2),
		ElixhauserScore varchar(100),
		CharlsonScore varchar(100),
		NotesCount INT,
		PCCIRiskscore varchar(100),
		BreakGlass BIT DEFAULT (0),
		LOB varchar(50) ,
		CompanyName varchar(100),
		Company_Key varchar(50),
		GroupName varchar(255),
		GroupID varchar(255),
		SubGroupName varchar(100),
		SubGroupID varchar(50),
		[ABCBS Employee Group] varchar(1),
		CM_ORG_REGION varchar(255),
		Branding_Name  varchar(255),
		CountyName varchar(30),
		HealthPlanEmployeeFlag varchar(1),
		COBCD varchar(10),
		DentalXtraInd varchar(50),
        ERCount int,
		RXCount int,
		PCPVisitsCount int,
		LastPCPVisit date,
		MedCost decimal(18,2),
		HealthConditions varchar(512)
		,CFR varchar(MAX)
		,BENI varchar(MAX),
		[BenefitGroup] varchar(255)	
	)

	-- Special Case: Where MemberID or LastName, FirstName can typed in the search criteria
	IF (@MVDID IS NOT NULL )
	BEGIN
		DROP TABLE IF EXISTS #MPDS
		CREATE Table #MPDS 
		(
			ICENUMBER	Varchar(30), FirstName	Varchar(100), LastName	Varchar(100), DOB			Date, GenderID	varchar(1), Address1	Varchar(100), Address2	Varchar(100), City	Varchar(100),
			[State]	Varchar(100), PostalCode	Varchar(20), HomePhone	Varchar(20), WorkPhone	Varchar(20), CellPhone	Varchar(20), FaxPhone	Varchar(20), Email	Varchar(100), 
			Ethnicity	Varchar(30), [Language]	Varchar(30), InCaseManagement BIT ,InsMemberId		Varchar(30),BreakGlass BIT DEFAULT (0), CM_ORG_REGION varchar(50), Branding_Name  varchar(50),HealthPlanEmployeeFlag varchar(1)
            ,COBCD varchar(10),DentalXtraInd varchar(50)
		)

		INSERT INTO #MPDS (ICENUMBER,FirstName, LastName, DOB, GenderID, Address1, Address2, City, [State], PostalCode, HomePhone, WorkPhone, CellPhone, FaxPhone ,Email, Ethnicity, [Language], InCaseManagement, InsMemberId, CM_ORG_REGION, Branding_Name,HealthPlanEmployeeFlag,COBCD,DentalXtraInd) -- JPG 0820
		SELECT
			 D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, dbo.fnInitCap(D.Address1), dbo.fnInitCap(D.Address2), dbo.fnInitCap(D.City), D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
			,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId,D.CmOrgRegion, D.BrandingName ,D.HealthPlanEmployeeFlag,D.COBCD,NULL	
		FROM 
			dbo.FinalMember D (readuncommitted)
		WHERE D.CustID = @Cust_ID
			AND @MVDID IS NOT NULL 
			AND D.MVDID  = @MVDID
			AND
			(
			(@CanSeeAllMembers = 1 and D.HealthPlanEmployeeFlag in ('1','0'))
			or
			(@CanSeeAllMembers = 0 and D.HealthPlanEmployeeFlag in ('0'))
			)

		IF NOT EXISTS (Select 1 from #MPDS)
		BEGIN

			INSERT INTO #MPDS (ICENUMBER,FirstName, LastName, DOB, GenderID, Address1, Address2, City, [State], PostalCode, HomePhone, WorkPhone, CellPhone, FaxPhone ,Email, Ethnicity, [Language], InCaseManagement, InsMemberId, CM_ORG_REGION, Branding_Name, HealthPlanEmployeeFlag,COBCD,DentalXtraInd)
			SELECT
				 D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, dbo.fnInitCap(D.Address1), dbo.fnInitCap(D.Address2), dbo.fnInitCap(D.City), D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
				 ,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId,D.CmOrgRegion, D.BrandingName ,D.HealthPlanEmployeeFlag,D.COBCD,NULL		
			FROM dbo.FinalMember D (readuncommitted)
			WHERE 
				@MVDID IS NOT NULL 
				AND D.MVDID LIKE  '%'+ @MVDID +'%'
				AND
				(
				(@CanSeeAllMembers = 1 and D.HealthPlanEmployeeFlag in ('1','0'))
				or
				(@CanSeeAllMembers = 0 and D.HealthPlanEmployeeFlag in ('0'))
				)
			UNION ALL
			SELECT
				 D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, dbo.fnInitCap(D.Address1), dbo.fnInitCap(D.Address2), dbo.fnInitCap(D.City), D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
				,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId,D.CmOrgRegion, D.BrandingName,D.HealthPlanEmployeeFlag,D.COBCD,NULL
			FROM dbo.FinalMember D (readuncommitted)
			WHERE 
				D.CustID = @Cust_ID
				AND @MVDID IS NULL
				AND
				(
				(@CanSeeAllMembers = 1 and D.HealthPlanEmployeeFlag in ('1','0'))
				or
				(@CanSeeAllMembers = 0 and D.HealthPlanEmployeeFlag in ('0'))
				)

		END

		IF NOT EXISTS (Select 1 from #MPDS)
		BEGIN

			INSERT INTO #MPDS (ICENUMBER,FirstName, LastName, DOB, GenderID, Address1, Address2, City, [State], PostalCode, HomePhone, WorkPhone, CellPhone, FaxPhone ,Email, Ethnicity, [Language], InCaseManagement, InsMemberId, CM_ORG_REGION, Branding_Name,HealthPlanEmployeeFlag,COBCD,DentalXtraInd)
			SELECT
			 D.MVDID,D.MemberFirstName, D.MemberLastName, D.DateOfBirth, D.Gender, dbo.fnInitCap(D.Address1), dbo.fnInitCap(D.Address2), dbo.fnInitCap(D.City), D.[State], D.Zipcode, D.HomePhone, D.WorkPhone,NULL, D.Fax 
		    ,D.Email, D.Ethnicity, D.[Language],NULL, D.MemberId,D.CmOrgRegion, D.BrandingName,D.HealthPlanEmployeeFlag,D.COBCD,NULL		
			FROM dbo.FinalMember D (readuncommitted)
			WHERE D.CustID = @Cust_ID
			AND @MVDID IS NULL
			AND
			(
			(@CanSeeAllMembers = 1 and D.HealthPlanEmployeeFlag in ('1','0'))
			or
			(@CanSeeAllMembers = 0 and D.HealthPlanEmployeeFlag in ('0'))
			)
		END

		CREATE INDEX IX_#MPDS_ICENUMBER ON #MPDS (ICENUMBER)

	END

   --ER Counts     

        DROP TABLE IF EXISTS #ERVisit

		SELECT MVDID,COUNT(DISTINCT AdmissionDate) ERCount
		INTO #ERVisit
		FROM 
			dbo.finalclaimsheader (readuncommitted)
		WHERE 
        DATEDIFF( DAY, AdmissionDate, GetUTCDate() ) <= 365
        AND EmergencyIndicator = 1 
        AND MVDID = @MVDID
		GROUP BY 
			MVDID
    
   --RX Counts

        DROP TABLE IF EXISTS #RXCount

		SELECT 
			MVDID,COUNT(DISTINCT DrugProductName) RXCount
		INTO #RXCount
		FROM dbo.FinalRX (readuncommitted)
		WHERE  
			DATEDIFF( DAY, ServiceDate, GetUTCDate() ) <= 365
			AND MVDID = @MVDID
		GROUP BY 
			MVDID

   --Health Conditions

		DROP TABLE IF EXISTS #List;
		DROP TABLE IF EXISTS #HealthConditions;

        SELECT eg.abbr,MONTHID,em.MVDID
        INTO #List
        FROM 
			FinalMember fm (readuncommitted)
        JOIN [dbo].[ElixMemberRisk]  em (readuncommitted)
			ON fm.MVDID = em.MVDID      
        JOIN [dbo].[LookupElixGroup] eg (readuncommitted)
			ON em.GroupID = eg.GroupID
        where em.MVDID = @MVDID
        GROUP BY 
			em.MONTHID,
			eg.abbr,
			em.MVDID
        ORDER BY em.MONTHID desc

		SELECT TOP 1 
			MVDID,MONTHID, 
			abbr = 
			   STUFF((SELECT ', ' + abbr
			   FROM #List b 
			   WHERE b.MONTHID = a.MONTHID
			   AND b.MVDID = a.MVDID
			   FOR XML PATH('')), 1, 2, '')
		INTO #HealthConditions
		FROM (
			SELECT em.MVDID,MONTHID FROM FinalMember fm (readuncommitted)
			LEFT JOIN [dbo].[ElixMemberRisk]  em (readuncommitted)
			ON fm.MVDID = em.MVDID      
			JOIN [dbo].[LookupElixGroup] eg (readuncommitted)
			ON em.GroupID = eg.GroupID
			WHERE 
				em.MVDID = @MVDID) a
		GROUP BY 
			MONTHID,
			MVDID
		ORDER BY 
			MONTHID desc

		UPDATE #HealthConditions SET abbr = LEFT(abbr,512) 

--Care Flow Rules (CFR)

		DECLARE @CFR varchar(MAX) = '['

		SELECT @CFR += '{"name":"' + Name + '"},'
		  FROM CareFlowTask cft
		  JOIN HPWorkFlowRule wfr ON cft.RuleID = wfr.Rule_ID
		 WHERE cft.MVDID = @MVDID
		 ORDER BY Name

		   SET @CFR = CASE WHEN RIGHT(@CFR,1) = ',' THEN LEFT(@CFR,LEN(@CFR)-1) ELSE @CFR END + ']' 
		    --PRINT ' CFR: ' + @CFR	
			--[{"name":"Exchange - Claims $$ GT 30k"},{"name":"Exchange - GT 3 ER Visits in rolling 12 months"}]

		--Benefits (BENI)
		
		DECLARE @BENI varchar(MAX) = ''
		 SELECT @BENI = '[' + IIF(me.MaternityElig = 'Yes','{"name":"Maternity"},','') 
		                    + IIF(IH.EligibleDentalBenefit = 'Y','{"name":"Dental Xtra"},','')
		                    + IIF(fm.EmpLocCd IN (SELECT StoreID FROM LookupPhyseraVirtualVisit),'{"name":"Virtual Therapy"}','')
				--CASE WHEN me.MaternityElig = 'Yes' THEN 1 ELSE 0 END MaternityEligibility,
				--CASE WHEN md.DentalXtraInd = 'Y' THEN 1 ELSE 0 END DentalXtra,
				--CASE WHEN fm.EmpLocCd IS NOT NULL THEN 1 ELSE 0 END VirtualVisit
		 FROM FinalMember fm (readuncommitted)
		 LEFT JOIN [dbo].[FinalEligibility] IH (readuncommitted) ON fm.MVDID = IH.MVDID
		 LEFT OUTER JOIN VitalData_MaternityEligibleFull me ON me.MemberID = fm.MemberID
			  WHERE fm.MVDID = @MVDID --'16AE4E39B125904C6770'

		  SET @BENI = CASE WHEN RIGHT(@BENI,1)= ',' THEN LEFT(@BENI,LEN(@BENI)-1) ELSE @BENI END + ']'
		  --PRINT 'BENI : ' + @BENI

        IF (@MVDID IS NOT NULL )
			BEGIN
				SELECT @MVDID = COUNT(DISTINCT MPD.ICENUMBER)
				FROM #MPDS MPD
			END

		if @BENI = '[]'
			select @BENI = NULL

		IF (@MVDID IS NOT NULL )
		BEGIN

			INSERT INTO #FinalResult
			(
			ICENUMBER, InsMemberId, FirstName, LastName, DOB, Gender, Address1, Address2, City, State, PostalCode, HomePhone, WorkPhone, 
			CellPhone, FaxPhone, Email, Ethnicity, Language, EffectiveDate, TerminationDate, TIN, PCP, PCP_Address, PCP_City, PCP_State, 
			PCP_Postal, PCP_Phone, RegMobileApp, HeadOfHousehold, Housing_Status, Homeless, Household_Size, CitizenshipStatus, FPL_Level, 
			HighER, HasAsthma, HasDiabetes, InCaseManagement, HedisDue, LockedBy, CaseID, CaseStatus, IsHighER,ERCount,RXCount,ERVisitDescription, IsHighRX, 
			RXAvgCost, RXDescription, IsHighUtil, HighUtilCost, HighUtilDescription, HCCScore, ElixhauserScore, CharlsonScore, NotesCount, PCCIRiskscore
			,BreakGlass, LOB, CompanyName, Company_Key, GroupName, GroupID, SubGroupName, SubGroupID,[ABCBS Employee Group], CM_ORG_REGION,
            Branding_Name, CountyName,HealthPlanEmployeeFlag,COBCD,DentalXtraInd,PCPVisitsCount,LastPCPVisit, MedCost,HealthConditions, CFR, BENI, 
			[BenefitGroup])		
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
				,IH.MemberEffectiveDate 
				,IH.MemberTerminationDate 
				,FP.TIN	AS TIN 
				,ISNULL(FP.ProviderFirstName,'') +' '+ ISNULL(FP.ProviderLastName,'') AS PCP 
				,FP.ServiceAddress1 AS PCP_Address 
				,FP.ServiceCity AS PCP_City 
				,FP.ServiceState AS PCP_State 
				,FP.ServiceZip AS PCP_Postal 
				,FP.ServicePhone AS PCP_Phone
				,'0' AS RegMobileApp
				,'0' AS HeadOfHousehold
				,CAST(NULL AS VARCHAR(50)) AS Housing_Status
				,CAST(NULL AS VARCHAR(100)) AS Homeless
				,CAST(NULL AS INT) AS Household_Size
				,CAST(NULL AS VARCHAR(50)) AS CitizenshipStatus
				,CAST(NULL AS VARCHAR(50)) AS FPL_Level
				,0 AS HighER
				,0 as HasAsthma
				,0 as HasDiabetes
				,CAST(ISNULL(MPD.InCaseManagement,0) AS BIT) AS InCaseManagement
				,'' AS HedisDue
				,0 as LockedBy --A.LockedBy
				,CAST(NULL AS VARCHAR(100)) AS CaseID 
				,CAST(NULL AS VARCHAR(20)) AS CaseStatus
				,IsHighER = 0--CAST(CASE WHEN ER.ER_6months >= 3 THEN 1 ELSE 0 END AS BIT)
				,ISNULL(er.ERCount,0) AS ERCount
				,ISNULL(rx.RXCount,0) AS RXCount
				,ERVisitDescription = '' --CAST(ER.ER_6months AS VARCHAR(10))+' visits in the last 6 months'
				,IsHighRX =  0 --CAST(ISNULL(RXP.IsHighRx,0) AS BIT)
				,RXAvgCost = 0 --ISNULL(RXP.BilledAmountLast6Months,0.00)
				,RXDescription = '' --' RX Totals of $'+CAST(RXP.BilledAmountLast6Months AS VARCHAR(25))+' in the last 6 months'
				,IsHighUtil = 0 --CAST(CASE WHEN mr.HCC_Score_Adj > 5 THEN 1 ELSE 0 END AS BIT)
				,HighUtilCost = 0 --CAST(mr.HCC_Score_Adj AS DECIMAL(5,2))
				,HighUtilDescription = '' --'Has an HCC Score of '+CAST(mr.HCC_Score_Adj AS VARCHAR(25))+' '
				,CAST(0 AS DECIMAL(5,2)) AS HCCScore
				,case when IsNULL(cmm.MaternityRiskScore,0) > ISNULL( ccq.RiskGroupID, 0 ) then IsNULL(cmm.MaternityRiskScore,0) else ISNULL( ccq.RiskGroupID, 0 ) end AS ElixhauserScore
				,0 AS CharlsonScore
				,0 AS NotesCount --ISNULL(N.NotesCount, 0) AS NotesCount
				,'' AS PCCIRiskscore
				,MPD.BreakGlass
				,FM.LOB
				,LCN.company_name
				,LCN.company_key
				,LG.grp_name
				,LG.grp_id
				,LS.sub_grp_name
				,LS.sub_grp_id
				,CASE WHEN LCN.company_key = 215 THEN 'Y' ELSE 'N' END AS [ABCBS Employee Group]
				,MPD.CM_ORG_REGION AS CM_ORG_REGION 
				,MPD.Branding_Name AS Branding_Name
				,FM.CountyName
				,MPD.HealthPlanEmployeeFlag
				,CASE WHEN FM.COBCD = 'M' THEN 'Medicare'
					  WHEN FM.COBCD = 'P' THEN 'Primary'
					  WHEN FM.COBCD = 'S' THEN 'Secondary'
					  WHEN FM.COBCD = 'U' THEN 'Primary'
					  WHEN FM.COBCD IS NULL THEN 'Primary'
				 END AS COBCD
				,CASE WHEN IH.EligibleDentalBenefit = 'N' THEN 'No'
					WHEN IH.EligibleDentalBenefit = 'Y' THEN 'Yes'
					WHEN IH.EligibleDentalBenefit IS NULL THEN ''
					END as DentalXtraInd			
				,ISNULL(vst.PCPVisitCount,0) PCPVisitsCount
				,vst.LastPCPVisit
				,ISNULL(mcst.TotalPaidAmount,0.00) as MedCost
				,LEFT(hc.abbr,255) as HealthConditions
				,@CFR AS CFR
				--TFS-5148: Concatenate/Append ValBasedProg to BENI
				,case 
				when isnull(@BENI, '') = '' and isnull(fm.ValBasedProg, '') = '' then '[]'
				else replace(replace(isnull(@BENI, '') + isnull(fm.ValBasedProg, ''), '"benefit"', '"name"'), '}][{', '},{') end AS BENI
				
				--,ccq.[BenefitGroup]	
				--ticket 5199 
				,CASE WHEN IH.PlanIdentifier='H9699' AND IH.BenefitGroup IN (004,001,002,003) THEN 'Health Advantage Blue Classic (HMO)'
					 WHEN IH.PlanIdentifier='H9699'  AND IH.BenefitGroup IN (006)			  THEN 'Health Advantage Blue Premier (HMO)'
					 WHEN IH.PlanIdentifier='H4213'  AND IH.BenefitGroup IN (016,001,003,004) THEN 'BlueMedicare Value (PFFS)'
					 WHEN IH.PlanIdentifier='H4213'  AND IH.BenefitGroup IN (017,001,005,006) THEN 'BlueMedicare Preferred (PFFS)'
					 WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (001,002)		  THEN 'BlueMedicare Saver Choice (PPO)'
					 WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (003,004,005,006) THEN 'BlueMedicare Value Choice (PPO)'
					 WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (007,008,009,010) THEN 'BlueMedicare Premier Choice (PPO)'
					 WHEN IH.PlanIdentifier='H6158'  AND IH.BenefitGroup IN (001,002)		  THEN 'BlueMedicare Premier (PPO)'
				ELSE NULL 
				END  AS BenefitGroup 	
						
			FROM #MPDS MPD
			LEFT JOIN [dbo].[FinalEligibility] IH (readuncommitted) ON MPD.ICENUMBER = IH.MVDID AND IsNull(IH.FakeSpanInd,'N') != 'Y' and IsNull(IH.SpanVoidInd,'N') != 'Y'
			LEFT JOIN [dbo].[FinalMember] FM (readuncommitted) ON IH.MVDID = FM.MVDID
			LEFT JOIN [dbo].[LookupLOB] LL (readuncommitted) ON IH.LOB = LL.source_code
			LEFT JOIN LookupGroup LG (readuncommitted) ON IH.PlanGroup = LG.grp_key 
            LEFT JOIN LookupCompanyName LCN(readuncommitted) ON LG.company_key = LCN.company_key
			LEFT JOIN FinalProvider FP (readuncommitted) ON CAST( IH.PCPNPI AS varchar(15) ) = FP.NPI
			LEFT JOIN LookupSubgroup LS (readuncommitted) ON IH.SubgroupKey = LS.sub_grp_key
			LEFT JOIN ComputedCareQueue ccq (readuncommitted) ON ccq.MVDID = mpd.IceNumber
			LEFT JOIN ComputedMemberMaternity cmm on cmm.MVDID = mpd.IceNumber
            LEFT JOIN #RXCount rx ON FM.MVDID = rx.MVDID
            LEFT JOIN #ERVisit er ON FM.MVDID = er.MVDID 
            LEFT JOIN #HealthConditions hc ON FM.MVDID = hc.MVDID
			-- ADDED LUNA 0629 FOR TICKET 5199 change starts
			LEFT OUTER JOIN 
			(
			  SELECT MVDID,MAX(MemberTerminationDate) AS MAXDATE
			  FROM [dbo].[FinalEligibility]			  				  		  
			  GROUP BY MVDID 
			 ) AS MAEligibility
				ON IH.mvdid=MAEligibility.mvdid
				AND IH.MemberTerminationDate=MAEligibility.MAXDATE
			-- change ends
			OUTER APPLY (
				SELECT e.MVDID, COUNT(DISTINCT ch.ClaimNumber) PCPVisitCount, MAX(ch.StatementFromDate) AS LastPCPVisit
				FROM FinalEligibility e (readuncommitted)
		        JOIN FinalClaimsHeader ch (readuncommitted)
					ON ch.RenderingProviderNPI = CAST( e.PCPNPI AS varchar(15)) AND ch.MVDID = e.MVDID  
			   WHERE ch.StatementFromDate BETWEEN 
					CASE WHEN MemberEffectiveDate <= DATEADD(MM, -12, GETDATE()) THEN DATEADD(MM, -12, GETDATE()) 
						ELSE MemberEffectiveDate END AND MemberTerminationDate         
					 AND e.MVDID = IH.MVDID				
					 AND case when ISNUMERIC(ch.ClaimStatus) = 0 THEN 0
							  when ch.ClaimStatus = 1 THEN 1 ELSE 0 END = 1
					 AND ch.RenderingProviderNPI IS NOT NULL
					 AND CAST( e.PCPNPI AS varchar(15)) IS NOT NULL
			   GROUP BY e.MVDID 
						 ) vst
            OUTER APPLY (
				SELECT TOP 1 TotalPaidAmount
                FROM [dbo].[ComputedMemberTotalPaidClaimsRollling12] (readuncommitted) 
                WHERE MVDID=IH.MVDID
                ORDER BY MONTHID desc
                ) mcst
			WHERE @MVDID IS NOT NULL
		    ORDER BY MPD.InsMemberId
		
        END

-- Final Output Result
	SELECT TOP 1
	 MPD.ICENUMBER
	 ,MPD.InsMemberId
	 , dbo.fnInitCap(MPD.FirstName) as FirstName
	 , dbo.fnInitCap(MPD.LastName) as LastName
	 , MPD.DOB, MPD.Gender, dbo.fnInitCap(MPD.Address1) as Address1, dbo.fnInitCap(MPD.Address2) as Address2, dbo.fnInitCap(MPD.City) as City, MPD.[State]
	,MPD.PostalCode, MPD.HomePhone, MPD.WorkPhone, MPD.CellPhone, MPD.FaxPhone, MPD.Email, MPD.Ethnicity, MPD.[Language], MPD.EffectiveDate
	,MPD.TerminationDate, MPD.TIN, MPD.PCP, MPD.PCP_Address, MPD.PCP_City, MPD.PCP_State, MPD.PCP_Postal, MPD.PCP_Phone, MPD.RegMobileApp
	,MPD.HeadOfHousehold, MPD.Housing_Status, MPD.Homeless, MPD.Household_Size, MPD.CitizenshipStatus, MPD.FPL_Level, MPD.HighER, MPD.HasAsthma
	,MPD.HasDiabetes, MPD.InCaseManagement
	,MPD.HedisDue AS HedisDue
	,MPD.LockedBy, MPD.CaseID, MPD.CaseStatus, MPD.IsHighER,MPD.ERCount,MPD.RXCount, MPD.ERVisitDescription, MPD.IsHighRX
	,MPD.RXAvgCost, MPD.RXDescription, MPD.IsHighUtil, MPD.HighUtilCost, MPD.HighUtilDescription, MPD.HCCScore, MPD.ElixhauserScore, MPD.CharlsonScore
	,MPD.NotesCount, MPD.PCCIRiskscore, BreakGlass , BreakGlass, LOB, CompanyName, Company_Key, GroupName, GroupID, SubGroupName, SubGroupID,[ABCBS Employee Group]
    , CM_ORG_REGION, Branding_Name, CountyName,HealthPlanEmployeeFlag,COBCD,DentalXtraInd,PCPVisitsCount, LastPCPVisit, MedCost,HealthConditions
	,ME.LastName AS CSME_LastName, ME.FirstName AS CSME_FirstName, ME.MiddleName AS CSME_MiddleName, ME.Address1 AS CSME_Address1, ME.Address2 AS CSME_Address2
	,ME.City AS CSME_City, ME.[State] AS CSME_State, ME.PostalCode AS CSME_PostalCode, ME.HomePhone AS CSME_HomePhone, ME.CellPhone AS CSME_CellPhone
	,ME.WorkPhone AS CSME_WorkPhone, ME.FaxPhone AS CSME_FaxPhone, ME.Email AS CSME_Email, ME.[Language] AS CSME_Language, ME.Ethnicity AS CSME_Ethnicity
	,ME.Housing AS CSME_Housing, case when ME.ICENUMBER is null then cast( 0 as bit) else cast (1 as bit) end as CSME_FLG
    ,MPD.CFR, MPD.BENI, [BenefitGroup]
	FROM #FinalResult MPD 
	LEFT JOIN dbo.CareSpaceMemberEdit ME (readuncommitted) 
		ON MPD.ICENUMBER = ME.ICENUMBER
	GROUP BY  MPD.ICENUMBER
		,MPD.InsMemberId
		, dbo.fnInitCap(MPD.FirstName) 
		, dbo.fnInitCap(MPD.LastName)
		, MPD.DOB, MPD.Gender, dbo.fnInitCap(MPD.Address1) , dbo.fnInitCap(MPD.Address2) , dbo.fnInitCap(MPD.City) , MPD.[State]
		,MPD.PostalCode, MPD.HomePhone, MPD.WorkPhone, MPD.CellPhone, MPD.FaxPhone, MPD.Email, MPD.Ethnicity, MPD.[Language], MPD.EffectiveDate
		,MPD.TerminationDate, MPD.TIN, MPD.PCP, MPD.PCP_Address, MPD.PCP_City, MPD.PCP_State, MPD.PCP_Postal, MPD.PCP_Phone, MPD.RegMobileApp
		,MPD.HeadOfHousehold, MPD.Housing_Status, MPD.Homeless, MPD.Household_Size, MPD.CitizenshipStatus, MPD.FPL_Level, MPD.HighER, MPD.HasAsthma
		,MPD.HasDiabetes, MPD.InCaseManagement
		,MPD.HedisDue 
		,MPD.LockedBy, MPD.CaseID, MPD.CaseStatus, MPD.IsHighER, MPD.ERCount,MPD.RXCount, MPD.ERVisitDescription, MPD.IsHighRX
		,MPD.RXAvgCost, MPD.RXDescription, MPD.IsHighUtil, MPD.HighUtilCost, MPD.HighUtilDescription, MPD.HCCScore, MPD.ElixhauserScore, MPD.CharlsonScore
		,MPD.NotesCount, MPD.PCCIRiskscore, BreakGlass , BreakGlass, LOB, CompanyName, Company_Key, GroupName, GroupID, SubGroupName, SubGroupID,[ABCBS Employee Group]
		, CM_ORG_REGION, Branding_Name, CountyName , HealthPlanEmployeeFlag,COBCD,DentalXtraInd,PCPVisitsCount,LastPCPVisit, MedCost,HealthConditions
		,ME.LastName , ME.FirstName , ME.MiddleName , ME.Address1 , ME.Address2 
		,ME.City , ME.[State] , ME.PostalCode , ME.HomePhone , ME.CellPhone 
		,ME.WorkPhone , ME.FaxPhone, ME.Email , ME.[Language], ME.Ethnicity 
		,ME.Housing,ME.ICENUMBER,MPD.CFR,MPD.BENI, [BenefitGroup]
	ORDER BY 
		MAX(MPD.TerminationDate) desc,
		MAX(MPD.EffectiveDate) desc
	OPTION(RECOMPILE)
  
  END
END