/****** Object:  Procedure [dbo].[uspComputedCareQueue]    Committed by VersionSQL https://www.versionsql.com ******/

/*
1/11/2021		Sunil Nokku		add readuncommitted hint
2021-01-13		Jose Pons		Load data to alternate table
								Switch to new loaded table using synonym
2021-05-19		Ed Zanelli		Added BenefitGroup
*/
CREATE PROCEDURE [dbo].[uspComputedCareQueue] 
AS
BEGIN 

  SET NOCOUNT ON;

	DECLARE 
		@TableName		VARCHAR(32)

	--Create synonym for alternate table
	SELECT @TableName = base_object_name FROM sys.synonyms WHERE [name] = 'synComputedCareQueue'

	DROP SYNONYM IF EXISTS synComputedCareQueue

	--SELECT @TableName 

	IF @TableName = '[dbo].[ComputedCareQueue1]'
	CREATE SYNONYM synComputedCareQueue FOR dbo.ComputedCareQueue2
	ELSE
	CREATE SYNONYM synComputedCareQueue FOR dbo.ComputedCareQueue1

	--SELECT * FROM sys.synonyms

	--Prep temp tables
	Drop Table If Exists #Form
	Drop Table If Exists #Task
	Drop Table IF Exists #Eligibility
	Drop Table IF Exists #ComputedCareQueue


	SELECT *
	INTO #Form
	FROM
		(
			SELECT 
			*,
			ROW_NUMBER() OVER ( 
				PARTITION BY 
					MVDID 
				ORDER BY 
					CASE WHEN CaseProgram = 'Case Management' THEN 1 ELSE 2 END, 
					CaseID DESC ) row_number
			FROM
				dbo.ABCBS_MemberManagement_Form (readuncommitted)
			WHERE
				qCloseCase = 'No'
				AND CaseID IS NOT NULL
			) mmf
	WHERE
		mmf.row_number = 1

	SELECT
		COUNT( DISTINCT ot.TaskId ) AS OpenTaskCount,
		ot.MVDID
	INTO #Task
	FROM
		(
			SELECT DISTINCT
				t.MVDID,
				tal.TaskId,
				FIRST_VALUE( tal.StatusId ) OVER ( 
					PARTITION BY t.MVDID, tal.TaskId 
					ORDER BY tal.ID DESC ) StatusId
			FROM
				dbo.Task t (readuncommitted)
			INNER JOIN 
				dbo.TaskActivityLog tal (readuncommitted)
			ON 
				tal.TaskId = t.id
		) ot
	INNER JOIN 
		dbo.Lookup_Generic_Code tt (readuncommitted)
	ON 
		tt.CodeId = ot.StatusId
		AND tt.Label != 'Completed'
	GROUP BY
		ot.MVDID
 
	;with [cteEligibility] as (
	Select 
		MVDID,
		MemberEffectiveDate,
		MemberTerminationDate, 
		RiskGroupID, 
		PlanGroup,
		BenefitGroup,
		ROW_NUMBER() OVER ( 
			PARTITION BY 
				MVDID 
			ORDER BY 
				MemberTerminationDate DESC, 
				RecordID DESC ) row_number
	From (
		Select
			RecordID,
			MVDID,
			MemberEffectiveDate,
			MemberTerminationDate, 
			RiskGroupID,
			PlanGroup,
			BenefitGroup
		From
			dbo.FinalEligibilityETL (readuncommitted)
		union all
		Select
			RecordID,
			MVDID,
			MemberEffectiveDate,
			MemberTerminationDate, 
			RiskGroupID,
			PlanGroup,
			BenefitGroup
		From
			dbo.FinalEligibilityTemporary (readuncommitted)
		) a
	)
	Select
		MVDID,
		MemberEffectiveDate,
		MemberTerminationDate, 
		RiskGroupID,
		PlanGroup,
		BenefitGroup
	Into #Eligibility
	From
		[cteEligibility]
	Where
		row_number = 1

	CREATE INDEX IX_Eligibility ON #Eligibility( [MVDID] )


  SELECT
	  mmf.CaseId,
	  fm.MVDID,
	-- OpenCaseCount will be loaded separately
	  0 OpenCaseCount,
	  ISNULL( ot.OpenTaskCount, 0 ) OpenTaskCount,
	  mmf.CaseProgram,
	  CASE
--		  WHEN dbo.MVDIsNull( mmf.q1CaseOwner ) = 1 THEN mmf.ReferralOwner
		  WHEN ISNULL(  mmf.q1CaseOwner, '' ) = '' THEN mmf.ReferralOwner
		  WHEN mmf.q1CaseOwner = 'NULL' THEN mmf.ReferralOwner
		  ELSE mmf.q1CaseOwner
		  END CaseOwner,
	-- TakOwner will not be loaded
	  NULL TaskOwner,
	  CASE
		  WHEN fmo.GroupID IS NULL THEN fmo.OwnerName
		  ELSE NULL
		  END MemberOwnerByUser,
	  fm.MemberID,
	  fm.LOB,
	  lg.grp_name PlanGroup,
	  fm.CountyName County,
	  fm.State,
	  lgrc.region_name Region,
	  CASE
		  WHEN fe.MemberEffectiveDate <= getDate() AND getDate() <= fe.MemberTerminationDate THEN 1
		  ELSE 0
		  END Isactive,
	  fm.HealthPlanEmployeeFlag,
	  fm.MemberFirstName FirstName,
	  fm.MemberLastName LastName,
	  fm.DateOfBirth DOB,
	  fmo.GroupId,
	  fmo.OwnerName MemberOwnedByGroup,
	  fm.CmOrGRegion,
	  fm.CompanyKey,
	  lcn.company_name CompanyName,
	  CAST( fe.RiskGroupID AS int ) RiskGroupID,
	  fm.GrpInitvCd,
	  fe.BenefitGroup
  INTO #ComputedCareQueue
  FROM 
	dbo.FinalMember fm (readuncommitted)
	LEFT OUTER JOIN
		#Eligibility fe
	ON
		fe.MVDID = fm.MVDID
	LEFT OUTER JOIN
		#Form mmf
	ON
		mmf.MVDID = fm.MVDID
	LEFT OUTER JOIN
		(
		SELECT *
		FROM
			(
				SELECT
				*,
				ROW_NUMBER() OVER ( 
					PARTITION BY 
						MVDID 
					ORDER BY 
						StartDate DESC, ID DESC ) row_number
				FROM
					dbo.Final_MemberOwner (readuncommitted)
				WHERE
					OwnerType = 'Primary'
					AND IsDeactivated = 0
				) mmf
		WHERE
			mmf.row_number = 1
		) fmo
	ON
		fmo.MVDID = fm.MVDID
	LEFT OUTER JOIN 
		dbo.LookupGroup lg (readuncommitted)
	ON 
		lg.grp_key = fe.PlanGroup
	LEFT OUTER JOIN 
		dbo.LookupCompanyName lcn (readuncommitted)
	ON 
		lcn.company_key = lg.company_key
	LEFT OUTER JOIN 
		dbo.LookupCountyName lcr (readuncommitted)
	ON 
		lcr.county_name = fm.CountyName
		AND lcr.st = fm.State
	LEFT OUTER JOIN 
		Final.dbo.LookupGeoRegionCode lgrc (readuncommitted)
	ON 
		lgrc.geo_region_cd = lcr.geo_region_cd
	LEFT OUTER JOIN
		#Task ot
	ON 
		ot.MVDID = fm.MVDID;

 -- MERGE INTO
	--#ComputedCareQueue d
 -- USING
	--  (
	--	SELECT
	--		MVDID,
	--		COUNT( DISTINCT ID ) OpenCaseCount
	--	FROM
	--		dbo.ABCBS_MemberManagement_Form ( READUNCOMMITTED )
	--	WHERE
	--		qCloseCase = 'No'
	--		AND CaseID IS NOT NULL
	--	GROUP BY
	--		MVDID
	--  ) s
 -- ON
	--s.MVDID = d.MVDID
 -- WHEN MATCHED THEN 
	--UPDATE SET
	--	d.OpenCaseCount = s.OpenCaseCount;

  --Update OpenCaseCount
  ;WITH [cteForms] AS (
	SELECT
		MVDID,
		COUNT( DISTINCT ID ) OpenCaseCount
	FROM
		dbo.ABCBS_MemberManagement_Form ( READUNCOMMITTED )
	WHERE
		qCloseCase = 'No'
		AND CaseID IS NOT NULL
	GROUP BY
		MVDID
  )
  UPDATE cc
  SET
	OpenCaseCount = f.OpenCaseCount
  FROM
	#ComputedCareQueue cc
  INNER JOIN 
	[cteForms] f
  ON
	cc.MVDID = f.MVDID;

	--Populate alternate table
	IF @TableName = '[dbo].[ComputedCareQueue1]'
	TRUNCATE TABLE dbo.ComputedCareQueue2
	ELSE
	TRUNCATE TABLE dbo.ComputedCareQueue1

	-- Insert members
	INSERT INTO dbo.synComputedCareQueue (
		CaseId,
		MVDID,
		OpenCaseCount,
		OpenTaskCount,
		CaseProgram,
		CaseOwner,
		TaskOwner,
		MemberOwnerByUser,
		MemberID,
		LOB,
		PlanGroup,
		County,
		State,
		Region,
		Isactive,
		HealthPlanEmployeeFlag,
		FirstName,
		LastName,
		DOB,
		GroupId,
		MemberOwnedByGroup,
		CmOrGRegion,
		CompanyKey,
		CompanyName,
		RiskGroupID,
		GrpInitvCd,
		BenefitGroup
	)
	SELECT
		CaseId,
		MVDID,
		OpenCaseCount,
		OpenTaskCount,
		CaseProgram,
		CaseOwner,
		TaskOwner,
		MemberOwnerByUser,
		MemberID,
		LOB,
		PlanGroup,
		County,
		State,
		Region,
		Isactive,
		HealthPlanEmployeeFlag,
		FirstName,
		LastName,
		DOB,
		GroupId,
		MemberOwnedByGroup,
		CmOrGRegion,
		CompanyKey,
		CompanyName,
		RiskGroupID,
		GrpInitvCd,
		BenefitGroup
	FROM
		#ComputedCareQueue;

	--ALTER INDEX ALL ON ComputedCareQueue REBUILD;

	--sp_rename ComputedCareQueue, ComputedCareQueue_Old

	--SWitch table thru synonym ComputedCareQueue
	DROP SYNONYM IF EXISTS ComputedCareQueue

	--SELECT @TableName 

	IF @TableName = '[dbo].[ComputedCareQueue1]'
	CREATE SYNONYM ComputedCareQueue FOR dbo.ComputedCareQueue2
	ELSE
	CREATE SYNONYM ComputedCareQueue FOR dbo.ComputedCareQueue1

END;