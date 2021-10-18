/****** Object:  Procedure [dbo].[Get_MDPatientAlerts]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 8/11/2009
-- Description:	Returns doctor's alerts for all patients
--	If @PatientMVDID is valued, return alerts only for specific patient
-- Example:	EXEC dbo.Get_MDPatientAlerts @dateRange=90, @DoctorID='741662481', @PatientMVDID = NULL, @Page = 1, @RecsPerPage = 100
-- Modified Date:	Modified By:	Description:
-- 02/14/2017		Marc De Luca	Removed unused table MDMemberVisit and replaced with EDVisitHistory
-- 08/23/2018		Marc De Luca	Added CustID filter
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDPatientAlerts] 
	@DoctorID varchar(20),
	@NPI varchar(20) = 'ALL',
	@PatientMVDID varchar(20),
	@DateRange int = null,
	@EMS varchar(50) = null,
	@UserID_SSO varchar(50) = null,
	@Page int,
	@RecsPerPage int
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CustID INT

	SELECT TOP(1) @CustID = g.CustID_Import
	FROM dbo.MDUser u
	JOIN dbo.Link_MDAccountGroup ag on u.ID = ag.MDAccountID
	JOIN dbo.MDGroup g on ag.MDGroupID = g.ID
	WHERE u.Username = @DoctorID

	SET @PatientMVDID = NULLIF(@PatientMVDID,'')

	DECLARE @tempRange DATETIME, @VisitCountDateRange DATETIME
		
	SELECT @tempRange = '01/01/1950', @VisitCountDateRange = DATEADD(mm,-6,GETDATE())

	IF(@DateRange IS NOT NULL AND @DateRange <> 0)
	BEGIN
		SELECT @tempRange = DATEADD(DD,-@DateRange,GETDATE())
	END

	--NPI
	--SELECT @NPI = (CASE WHEN @NPI = '' THEN 'ALL' ELSE @NPI END)
	
	SELECT
	 COUNT (*) OVER () AS TotalRecords, v.ID, isnull(p.firstname,'') + isnull(' ' + p.lastname,'') AS Name
	,c.Name AS hpName
	,i.InsMemberID AS InsMemberID	
	,p.icenumber AS mvdid
	,CONVERT(VARCHAR(10),v.VisitDate ,101) AS Date
	,v.FacilityName AS Facility
	,upper(substring(v.ChiefComplaint,1,1))+lower(substring(v.ChiefComplaint,2,len(v.ChiefComplaint))) AS ChiefComplaint
	,NULL AS Notes --	,upper(substring(v.EMSNote,1,1))+lower(substring(v.EMSNote,2,len(v.EMSNote))) AS Notes
	,PCP.NPI AS PCP_NPI
	,ev.ERVisitCount
	FROM dbo.EDVisitHistory v
	JOIN dbo.MainPersonalDetails p on v.ICENUMBER = p.ICENUMBER
	JOIN dbo.Link_MemberId_MVD_Ins i ON v.ICENUMBER = i.MVDId
	JOIN dbo.HPCustomer c ON i.Cust_ID = c.Cust_ID AND i.Cust_ID = @CustID
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
	OFFSET (@Page-1)*@RecsPerPage ROWS FETCH NEXT @RecsPerPage ROWS ONLY
	
	-- Record SP Log
	DECLARE @params nvarchar(1000) = null
	SET @params = '@DoctorID=' + ISNULL(@DoctorID, 'null') + ';' +
				  '@NPI=' + ISNULL(@NPI, 'null') + ';' +
				  '@PatientMVDID=' + ISNULL(@PatientMVDID, 'null') + ';' +
				  '@DateRange=' + CONVERT(varchar(50), @DateRange) + ';'
	EXEC [dbo].[Set_StoredProcedures_Log] '[dbo].[Get_MDPatientAlerts]', @EMS, @UserID_SSO, @params
	
END