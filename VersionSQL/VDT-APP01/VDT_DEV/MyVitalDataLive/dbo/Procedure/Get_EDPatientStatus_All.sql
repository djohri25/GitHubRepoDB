/****** Object:  Procedure [dbo].[Get_EDPatientStatus_All]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:      Tim Thein
-- Create date: 9/22/2009
-- Description: Returns all rows of EDPatientStatus that indicate the same
--              facility as user
-- =============================================
CREATE PROCEDURE [dbo].[Get_EDPatientStatus_All]
	@userName	varchar(50),
	@custId		int,
	@view		int = 0,
	@facilityID	int = -1
AS
BEGIN
	DECLARE	@status varchar(16), @dateLimit datetime, @filterFacility int,
		@parentCustID int
		
	select @parentCustID = dbo.Get_HPParentCustomerID(@custID)
		
	IF @userName <> ''
	BEGIN
		SET @filterFacility = 1
		SELECT	@facilityID = CompanyID FROM MainEMS WHERE username = @userName
		
		if @facilityID = -1
			SELECT	@facilityID = CompanyID FROM hospitalUser WHERE username = @userName
	END
	ELSE IF @facilityID = -1
		SET @filterFacility = 0
	ELSE
		SET @filterFacility = 1

	SET	@status = 
		CASE @view
			WHEN 0 THEN ''
			WHEN 1 THEN 'Followup'
			WHEN 2 THEN 'Admitted'
			WHEN 4 THEN 'Discharged'
			WHEN 8 THEN 'Complete'
			WHEN 16 THEN 'Deleted'
			ELSE ''
		END

	IF DB_NAME() LIKE '%Dev' -- SELECT part is different for Dev to generate random data
	BEGIN
		SET @dateLimit = DATEADD(WW, -25, GETUTCDATE())
		SELECT		status.PatientLastName + ', ' + status.PatientFirstName AS MemberName, status.MemberID, dbo.UTCtoET(status.DateVisited) as DateVisited, 
					SUBSTRING('Y', dbo.RandInt(RAND(ID), 2), 1) AS HQC, dbo.RandInt(RAND(ID), 10) AS VisitCount,
					status.Status, status.ID, link.MVDId
		FROM		EDPatientStatus AS status LEFT JOIN
					Link_MemberId_MVD_Ins AS link ON status.MemberID = link.InsMemberId LEFT JOIN
					(
						SELECT DISTINCT ICENUMBER FROM MainCondition AS mc INNER JOIN LookupICD9AdditionalInfo AS icd9 ON mc.Code = icd9.CodeNoPeriod WHERE icd9.FollowupPriority IS NOT NULL
					) AS hqc ON link.MVDId = hqc.ICENUMBER
		WHERE		(@filterFacility = 0 OR status.FacilityID = @facilityID) AND status.CustID = @parentCustID AND ISNULL(status.Status,'') = @status AND (@view IN (0, 1) OR status.DateVisited > @dateLimit)
		ORDER BY	MemberName
	END
	ELSE
	BEGIN
		SET @dateLimit = DATEADD(D, -10, GETUTCDATE())
		SELECT		status.PatientLastName + ', ' + status.PatientFirstName AS MemberName, status.MemberID, dbo.UTCtoET(status.DateVisited) as DateVisited, 
					SUBSTRING('Y', ISNULL(LEN(hqc.ICENUMBER)%1+1, 0), 1) AS HQC, dbo.EDVisitCount(status.MemberId) AS VisitCount, 
					status.Status, status.ID, link.MVDId
		FROM		EDPatientStatus AS status LEFT JOIN
					Link_MemberId_MVD_Ins AS link ON status.MemberID = link.InsMemberId LEFT JOIN
					(
						SELECT DISTINCT ICENUMBER FROM MainCondition AS mc INNER JOIN LookupICD9AdditionalInfo AS icd9 ON mc.Code = icd9.CodeNoPeriod WHERE icd9.FollowupPriority IS NOT NULL
					) AS hqc ON link.MVDId = hqc.ICENUMBER
		WHERE		(@filterFacility = 0 OR status.FacilityID = @facilityID) AND status.CustID = @parentCustID AND ISNULL(status.Status,'') = @status AND (@view IN (0, 1) OR status.DateVisited > @dateLimit)
		ORDER BY	MemberName
	END
END