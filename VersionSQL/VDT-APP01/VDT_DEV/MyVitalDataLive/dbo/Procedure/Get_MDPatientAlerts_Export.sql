/****** Object:  Procedure [dbo].[Get_MDPatientAlerts_Export]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Marc De Luca	
-- Create date: 05/04/2017
-- Description:	Created from Get_MDPatientAlerts for Excel export.
-- Example:		EXEC dbo.Get_MDPatientAlerts_Export @DoctorID='742947261',@NPI='ALL',@PatientMVDID='',@DateRange=90,@Page=1,@RecsPerPage=15,@EMS=N'742947261',@UserID_SSO=N''
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDPatientAlerts_Export] 
	@DoctorID varchar(20),
	@NPI varchar(20) = 'ALL',
	@PatientMVDID varchar(20),
	@DateRange int = null,
	@EMS varchar(50) = null,
	@UserID_SSO varchar(50) = null,
	@Page int = null,
	@RecsPerPage int = null
AS
BEGIN
	SET NOCOUNT ON;

	SET @PatientMVDID = NULLIF(@PatientMVDID,'')

	DECLARE @tempRange DATETIME, @VisitCountDateRange DATETIME
		
	SELECT @tempRange = '01/01/1950', @VisitCountDateRange = DATEADD(mm,-6,GETDATE())

	IF(@DateRange IS NOT NULL AND @DateRange <> 0)
	BEGIN
		SELECT @tempRange = DATEADD(DD,-@DateRange,GETDATE())
	END

	IF OBJECT_ID('tempdb..#v') IS NOT NULL DROP TABLE #v;
	SELECT
	 v.ICENUMBER
	,[First Name] = p.firstname
	,[Last Name] = p.lastname
	,[DOB] = CAST(p.DOB AS DATE)
	,[Gender] = CASE p.GenderID WHEN 1 THEN 'Male' WHEN 2 THEN 'Female' ELSE NULL END
	,[Home Phone] = p.HomePhone
	,[Address1] = p.Address1
	,[Address2] = p.Address2
	,[City] = p.City
	,[State] = p.State
	,[Zip] = p.PostalCode
	,[Medicaid number] = i.InsMemberId
	,[ER Visit count] = ev.ERVisitCount
	,[HealthPlanID] = i.InsMemberId
	,[Eligibility Start Date] = CAST(mi.EffectiveDate AS DATE)
	,[Eligibility End Date] = CAST(mi.TerminationDate AS DATE)
	,[PCP Name] = ISNULL([Provider First Name], '')+' '+ISNULL([Provider Last Name (Legal Name)], '')
	,[ER Visit Date] = CONVERT(VARCHAR(10),v.VisitDate ,101)
	,[ER Location / Name] = v.FacilityName
	,[ER Chief Complaint] = UPPER(SUBSTRING(v.ChiefComplaint,1,1))+LOWER(SUBSTRING(v.ChiefComplaint,2,LEN(v.ChiefComplaint)))
	,[ER Discharge Diagnosis] = DD.Diagnosis
	,[ER Discharge To Location] = CASE WHEN IsHospitalAdmit = 1 THEN 'Admitted to hospital' ELSE 'Sent home' END
	INTO #v
	FROM dbo.EDVisitHistory v
	JOIN dbo.MainPersonalDetails p on v.ICENUMBER = p.ICENUMBER
	JOIN dbo.Link_MemberId_MVD_Ins i ON v.ICENUMBER = i.MVDId
	JOIN dbo.HPCustomer c ON i.Cust_ID = c.Cust_ID
	JOIN dbo.MainInsurance mi ON v.ICENUMBER = mi.ICENUMBER
	LEFT JOIN
	(
		SELECT ICENUMBER, COUNT(*) AS ERVisitCount
		FROM dbo.EDVisitHistory 
		WHERE VisitType = 'ER'
		AND visitdate > @VisitCountDateRange
		GROUP BY ICENUMBER
	) ev ON v.ICENUMBER = ev.ICENUMBER
	OUTER APPLY
	(
		SELECT TOP (1) s.NPI 
		FROM dbo.MainSpecialist s 
		WHERE s.ICENUMBER = p.ICENUMBER 
		AND RoleID = 1 
		ORDER BY s.ModifyDate DESC
	) PCP
	JOIN dbo.LookupNPI npi ON PCP.NPI = npi.[NPI]
	OUTER APPLY
	(
		SELECT TOP (1) MC.OtherName AS Diagnosis
		FROM dbo.EDVisitHistory ER
		JOIN dbo.MainCondition MC ON ER.ICENUMBER = MC.ICENUMBER AND CAST(ER.VisitDate AS DATE) = CAST(MC.ReportDate AS DATE)
		WHERE ER.VisitType = 'ER'
		AND MC.IsPrincipal = 1
		AND p.ICENUMBER = ER.ICENUMBER
		AND V.VisitDate = ER.VisitDate
	) DD
	WHERE v.VisitType = 'ER' 
	AND	v.VisitDate > @tempRange
	AND	(@PatientMVDID IS NULL OR p.ICENUMBER = @PatientMVDID)
	AND MVDID IN
	(
		SELECT s.ICENUMBER
		FROM dbo.MDUser u
		JOIN dbo.Link_MDAccountGroup ag on u.ID = ag.MDAccountID
		JOIN dbo.MDGroup g on ag.MDGroupID = g.ID
		JOIN dbo.Link_MDGroupNPI n on g.ID = n.MDGroupID
		JOIN dbo.MainSpecialist s on n.NPI = s.NPI
		WHERE u.Username = @DoctorID
		AND (@NPI = 'ALL' OR n.[NPI] = @NPI)
		AND s.RoleID = 1
	)
	ORDER BY v.VisitDate DESC

	IF OBJECT_ID('tempdb..#h') IS NOT NULL DROP TABLE #h;
	SELECT DISTINCT f.MVDID, hm.Abbreviation
	INTO #h
	FROM dbo.Final_HEDIS_Member_FULL f
	JOIN dbo.HedisMeasures hm ON f.TestID = hm.ID
	WHERE f.MVDID IN (SELECT ICENUMBER FROM #v)
	AND f.IsTestDue = 1
	AND LEFT(f.MonthID,4) = YEAR(GETDATE())

	SELECT
	 [First Name]
	,[Last Name]
	,[DOB]
	,[Gender]
	,[Home Phone]
	,[Address1]
	,[Address2]
	,[City]
	,[State]
	,[Zip]
	,[Medicaid number]
	,[ER Visit count]
	,[TestsDue] = (SELECT DISTINCT SUBSTRING((SELECT ',' + CAST(LTRIM(RTRIM(ISNULL(h.Abbreviation,''))) AS VARCHAR(20)) 
					FROM #h h
					WHERE v.ICENUMBER = h.MVDID
					ORDER BY h.Abbreviation
					FOR XML PATH ('')), 2, 128000) )
	,[HealthPlanID]
	,[Eligibility Start Date]
	,[Eligibility End Date]
	,[PCP Name]
	,[ER Visit Date]
	,[ER Location / Name]
	,[ER Chief Complaint]
	,[ER Discharge Diagnosis]
	,[ER Discharge To Location]
	FROM #v v
	ORDER BY ICENUMBER, [ER Visit Date] DESC
--	OFFSET (@Page-1)*@RecsPerPage ROWS FETCH NEXT @RecsPerPage ROWS ONLY
	
	-- Record SP Log
	DECLARE @params nvarchar(1000) = null
	SET @params = '@DoctorID=' + ISNULL(@DoctorID, 'null') + ';' +
				  '@NPI=' + ISNULL(@NPI, 'null') + ';' +
				  '@PatientMVDID=' + ISNULL(@PatientMVDID, 'null') + ';' +
				  '@DateRange=' + CONVERT(varchar(50), @DateRange) + ';'
	EXEC [dbo].[Set_StoredProcedures_Log] '[dbo].[Get_MDPatientAlerts_Export]', @EMS, @UserID_SSO, @params
	
END