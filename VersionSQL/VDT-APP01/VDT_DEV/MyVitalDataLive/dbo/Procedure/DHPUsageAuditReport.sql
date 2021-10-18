/****** Object:  Procedure [dbo].[DHPUsageAuditReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:	Marc De Luca
-- Create date: 02/21/2017
-- Description:	Provides data for DHP - Usage Audit Report
-- Example:	EXEC dbo.DHPUsageAuditReport @TIN = '760092548', @StartDate = '10/1/2016', @EndDate = '12/31/2016', @DataSet = 2
-- =============================================
CREATE PROCEDURE dbo.DHPUsageAuditReport
	 @TIN CHAR(10)
	,@Cust_ID INT = 11
	,@StartDate DATE
	,@EndDate DATE
	,@DataSet INT = NULL
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SET @EndDate = DATEADD(DD, 1, @EndDate)

	DECLARE @MVDID VARCHAR(10)

	SELECT @MVDID = MVDID FROM dbo.MVD_AppRecord_MD WHERE UserName = @TIN

	-- Tab 1 - User SSO Logins
	SELECT
	 UserID AS SSO
	,UserTIN AS TIN
	,Action
	,Created
	,CAST(NULL AS NVARCHAR(300)) AS PageName
	,CAST(NULL AS DATETIME) AS [DateTime]
	,CAST(NULL AS VARCHAR(50)) AS MemberFirstName
	,CAST(NULL AS VARCHAR(50)) AS MemberLastName
	,CAST(NULL AS VARCHAR(15)) AS MVDID
	,CAST(NULL AS VARCHAR(20)) AS MemberID
	,CAST(NULL AS NVARCHAR(100)) AS LocationID
	,CAST(NULL AS NVARCHAR(100)) AS UserName
	,CAST(NULL AS NVARCHAR(4000)) AS AccessReason
	,CAST(NULL AS NVARCHAR(2000)) AS Criteria
	,CAST(NULL AS NVARCHAR(100)) AS ResultStatus
	,CAST(NULL AS INT) AS ResultCount
	,CAST(NULL AS DATETIME) AS AlertSendDate
	,CAST(NULL AS NVARCHAR(200)) AS ChiefComplaint
	,CAST(NULL AS NVARCHAR(2000)) AS EMSNote
	,CAST(NULL AS BIT) AS CancelNotification
	,CAST(NULL AS NVARCHAR(200)) AS CancelNotifyReason
	,CAST(NULL AS VARCHAR(50)) AS Status
	,CAST(NULL AS INT) AS UserFacilityID
	,CAST(NULL AS VARCHAR(MAX)) AS Note	
	,CAST(NULL AS DATETIME) AS DateCreated	
	,CAST(NULL AS VARCHAR(50)) AS CreatedBy	
	,CAST(NULL AS DATETIME) AS DateModified	
	,CAST(NULL AS VARCHAR(50)) AS ModifiedBy	
	,CAST(NULL AS VARCHAR(50)) AS CreatedByType	
	,CAST(NULL AS VARCHAR(50)) AS ModifiedByType	
	,CAST(NULL AS BIT) AS Active
	,CAST(NULL AS INT) AS IsTestDue	
	,CAST(NULL AS INT) AS TestID	
	,CAST(NULL AS VARCHAR(50)) AS DoctorUserName	
	,CAST(NULL AS INT) AS CustID	
	,CAST(NULL AS VARCHAR(50)) AS PCP_NPI	
	,CAST(NULL AS VARCHAR(50)) AS PCP_TIN	
	,CAST(NULL AS NVARCHAR(20)) AS LOB	
	,CAST(NULL AS NVARCHAR(100)) AS SDA	
	,CAST(NULL AS CHAR(1)) AS HasAsthma	
	,CAST(NULL AS CHAR(1)) AS HasDiabetes	
	,CAST(NULL AS INT) AS RemindInDays	
	,CAST(NULL AS INT) AS ERVisitCount	
	,CAST(NULL AS INT) AS NoteCount	
	,CAST(NULL AS VARCHAR(MAX)) AS MeasureNote
	FROM dbo.SSO_Log
	WHERE UserTIN = @TIN
	AND (@DataSet IS NULL OR @DataSet = 1)

	UNION ALL

	-- Tab 2 - Member Pages Viewed
	SELECT 
	 SSO
	,TIN
	,CAST(NULL AS VARCHAR(MAX)) AS Action
	,CAST(NULL AS DATETIME) AS Created
	,PageName	
	,[DateTime]
	,MemberFirstName
	,MemberLastName
	,MVDID	
	,MemberID
	,CAST(NULL AS NVARCHAR(100)) AS LocationID
	,CAST(NULL AS NVARCHAR(100)) AS UserName
	,CAST(NULL AS NVARCHAR(4000)) AS AccessReason
	,CAST(NULL AS NVARCHAR(2000)) AS Criteria
	,CAST(NULL AS NVARCHAR(100)) AS ResultStatus
	,CAST(NULL AS INT) AS ResultCount
	,CAST(NULL AS DATETIME) AS AlertSendDate
	,CAST(NULL AS NVARCHAR(200)) AS ChiefComplaint
	,CAST(NULL AS NVARCHAR(2000)) AS EMSNote
	,CAST(NULL AS BIT) AS CancelNotification
	,CAST(NULL AS NVARCHAR(200)) AS CancelNotifyReason
	,CAST(NULL AS VARCHAR(50)) AS Status
	,CAST(NULL AS INT) AS UserFacilityID
	,CAST(NULL AS VARCHAR(MAX)) AS Note	
	,CAST(NULL AS DATETIME) AS DateCreated	
	,CAST(NULL AS VARCHAR(50)) AS CreatedBy	
	,CAST(NULL AS DATETIME) AS DateModified	
	,CAST(NULL AS VARCHAR(50)) AS ModifiedBy	
	,CAST(NULL AS VARCHAR(50)) AS CreatedByType	
	,CAST(NULL AS VARCHAR(50)) AS ModifiedByType	
	,CAST(NULL AS BIT) AS Active
	,CAST(NULL AS INT) AS IsTestDue	
	,CAST(NULL AS INT) AS TestID	
	,CAST(NULL AS VARCHAR(50)) AS DoctorUserName	
	,CAST(NULL AS INT) AS CustID	
	,CAST(NULL AS VARCHAR(50)) AS PCP_NPI	
	,CAST(NULL AS VARCHAR(50)) AS PCP_TIN	
	,CAST(NULL AS NVARCHAR(20)) AS LOB	
	,CAST(NULL AS NVARCHAR(100)) AS SDA	
	,CAST(NULL AS CHAR(1)) AS HasAsthma	
	,CAST(NULL AS CHAR(1)) AS HasDiabetes	
	,CAST(NULL AS INT) AS RemindInDays	
	,CAST(NULL AS INT) AS ERVisitCount	
	,CAST(NULL AS INT) AS NoteCount	
	,CAST(NULL AS VARCHAR(MAX)) AS MeasureNote
	FROM
	(
		SELECT
		 S.UserTIN AS TIN	
		,S.UserID AS SSO	
		,L.PageName	
		,L.LoggingDate AS [DateTime]
		,D.FirstName AS [MemberFirstName]
		,D.LastName AS [MemberLastName]
		,I.MVDID	
		,I.InsMemberId AS MemberID
		FROM dbo.SSO_Log S
		JOIN dbo.MemberAccess_Log L ON S.UserTIN = L.UserID
		JOIN dbo.Link_MemberId_MVD_Ins I ON L.PatientID = I.InsMemberId
		JOIN dbo.MainPersonalDetails D ON I.MVDID = D.ICENUMBER
		WHERE S.UserTIN = @TIN
		AND I.Cust_ID = @Cust_ID
	) L
	WHERE [DateTime] >= @StartDate
	AND [DateTime] < @EndDate

	UNION ALL

	-- Tab 3 - Member Lookup
	SELECT
	 CAST(NULL AS VARCHAR(50)) AS SSO
	,CAST(NULL AS VARCHAR(50)) AS TIN
	,Action
	,Created
	,CAST(NULL AS NVARCHAR(300)) AS PageName
	,CAST(NULL AS DATETIME) AS [DateTime]
	,CAST(NULL AS VARCHAR(50)) AS MemberFirstName
	,CAST(NULL AS VARCHAR(50)) AS MemberLastName
	,MVDID
	,CAST(NULL AS VARCHAR(20)) AS MemberID
	,LocationID
	,UserName
	,AccessReason
	,Criteria
	,ResultStatus
	,ResultCount
	,AlertSendDate
	,ChiefComplaint
	,EMSNote
	,CancelNotification
	,CancelNotifyReason
	,Status
	,UserFacilityID
	,CAST(NULL AS VARCHAR(MAX)) AS Note	
	,CAST(NULL AS DATETIME) AS DateCreated	
	,CAST(NULL AS VARCHAR(50)) AS CreatedBy	
	,CAST(NULL AS DATETIME) AS DateModified	
	,CAST(NULL AS VARCHAR(50)) AS ModifiedBy	
	,CAST(NULL AS VARCHAR(50)) AS CreatedByType	
	,CAST(NULL AS VARCHAR(50)) AS ModifiedByType	
	,CAST(NULL AS BIT) AS Active
	,CAST(NULL AS INT) AS IsTestDue	
	,CAST(NULL AS INT) AS TestID	
	,CAST(NULL AS VARCHAR(50)) AS DoctorUserName	
	,CAST(NULL AS INT) AS CustID	
	,CAST(NULL AS VARCHAR(50)) AS PCP_NPI	
	,CAST(NULL AS VARCHAR(50)) AS PCP_TIN	
	,CAST(NULL AS NVARCHAR(20)) AS LOB	
	,CAST(NULL AS NVARCHAR(100)) AS SDA	
	,CAST(NULL AS CHAR(1)) AS HasAsthma	
	,CAST(NULL AS CHAR(1)) AS HasDiabetes	
	,CAST(NULL AS INT) AS RemindInDays	
	,CAST(NULL AS INT) AS ERVisitCount	
	,CAST(NULL AS INT) AS NoteCount	
	,CAST(NULL AS VARCHAR(MAX)) AS MeasureNote
	FROM dbo.MVD_AppRecord_MD
	WHERE UserName = @TIN
	AND (@DataSet IS NULL OR @DataSet = 3)

	UNION ALL

	-- Tab 4 - Notes Activity to Date

	SELECT 
	 CAST(NULL AS VARCHAR(50)) AS SSO
	,CAST(NULL AS VARCHAR(50)) AS TIN
	,CAST(NULL AS VARCHAR(MAX)) AS Action
	,CAST(NULL AS DATETIME) AS Created
	,CAST(NULL AS NVARCHAR(300)) AS PageName
	,CAST(NULL AS DATETIME) AS [DateTime]
	,CAST(NULL AS VARCHAR(50)) AS MemberFirstName
	,CAST(NULL AS VARCHAR(50)) AS MemberLastName
	,MVDID
	,CAST(NULL AS VARCHAR(20)) AS MemberID
	,CAST(NULL AS NVARCHAR(100)) AS LocationID
	,CAST(NULL AS NVARCHAR(100)) AS UserName
	,CAST(NULL AS NVARCHAR(4000)) AS AccessReason
	,CAST(NULL AS NVARCHAR(2000)) AS Criteria
	,CAST(NULL AS NVARCHAR(100)) AS ResultStatus
	,CAST(NULL AS INT) AS ResultCount
	,CAST(NULL AS DATETIME) AS AlertSendDate
	,CAST(NULL AS NVARCHAR(200)) AS ChiefComplaint
	,CAST(NULL AS NVARCHAR(2000)) AS EMSNote
	,CAST(NULL AS BIT) AS CancelNotification
	,CAST(NULL AS NVARCHAR(200)) AS CancelNotifyReason
	,CAST(NULL AS VARCHAR(50)) AS Status
	,CAST(NULL AS INT) AS UserFacilityID
	,Note
	,DateCreated	
	,CreatedBy	
	,DateModified	
	,ModifiedBy	
	,CreatedByType	
	,ModifiedByType	
	,Active
	,CAST(NULL AS INT) AS IsTestDue	
	,CAST(NULL AS INT) AS TestID	
	,CAST(NULL AS VARCHAR(50)) AS DoctorUserName	
	,CAST(NULL AS INT) AS CustID	
	,CAST(NULL AS VARCHAR(50)) AS PCP_NPI	
	,CAST(NULL AS VARCHAR(50)) AS PCP_TIN	
	,CAST(NULL AS NVARCHAR(20)) AS LOB	
	,CAST(NULL AS NVARCHAR(100)) AS SDA	
	,CAST(NULL AS CHAR(1)) AS HasAsthma	
	,CAST(NULL AS CHAR(1)) AS HasDiabetes	
	,CAST(NULL AS INT) AS RemindInDays	
	,CAST(NULL AS INT) AS ERVisitCount	
	,CAST(NULL AS INT) AS NoteCount	
	,CAST(NULL AS VARCHAR(MAX)) AS MeasureNote
	FROM dbo.HPAlertNote
	WHERE MVDID = @MVDID
	AND DateCreated >= @StartDate
	AND DateCreated < @EndDate
	AND (@DataSet IS NULL OR @DataSet = 4)

	UNION ALL

	-- Tab 5 - Members W34
	SELECT DISTINCT
	 CAST(NULL AS VARCHAR(50)) AS SSO
	,CAST(NULL AS VARCHAR(50)) AS TIN
	,CAST(NULL AS VARCHAR(MAX)) AS Action
	,CAST(NULL AS DATETIME) AS Created
	,CAST(NULL AS NVARCHAR(300)) AS PageName
	,CAST(NULL AS DATETIME) AS [DateTime]
	,H.MemberFirstName AS MemberFirstName
	,H.MemberLastName AS MemberLastName
	,MVDID
	,MemberID
	,CAST(NULL AS NVARCHAR(100)) AS LocationID
	,CAST(NULL AS NVARCHAR(100)) AS UserName
	,CAST(NULL AS NVARCHAR(4000)) AS AccessReason
	,CAST(NULL AS NVARCHAR(2000)) AS Criteria
	,CAST(NULL AS NVARCHAR(100)) AS ResultStatus
	,CAST(NULL AS INT) AS ResultCount
	,CAST(NULL AS DATETIME) AS AlertSendDate
	,CAST(NULL AS NVARCHAR(200)) AS ChiefComplaint
	,CAST(NULL AS NVARCHAR(2000)) AS EMSNote
	,CAST(NULL AS BIT) AS CancelNotification
	,CAST(NULL AS NVARCHAR(200)) AS CancelNotifyReason
	,CAST(NULL AS VARCHAR(50)) AS Status
	,CAST(NULL AS INT) AS UserFacilityID
	,CAST(NULL AS VARCHAR(MAX)) AS Note	
	,CAST(NULL AS DATETIME) AS DateCreated	
	,CAST(NULL AS VARCHAR(50)) AS CreatedBy	
	,CAST(NULL AS DATETIME) AS DateModified	
	,CAST(NULL AS VARCHAR(50)) AS ModifiedBy	
	,CAST(NULL AS VARCHAR(50)) AS CreatedByType	
	,CAST(NULL AS VARCHAR(50)) AS ModifiedByType	
	,CAST(NULL AS BIT) AS Active
	,H.IsTestDue	
	,H.TestID	
	,H.DoctorUserName	
	,H.CustID	
	,H.PCP_NPI	
	,H.PCP_TIN	
	,H.LOB	
	,H.SDA	
	,H.HasAsthma	
	,H.HasDiabetes	
	,H.RemindInDays	
	,H.ERVisitCount	
	,H.NoteCount	
	,'' AS MeasureNote
	FROM dbo.Final_HEDIS_Member_FULL H
	JOIN dbo.LookupHedis LH ON H.TestID = LH.TestID AND LH.Abbreviation = 'W34'
	WHERE H.PCP_TIN = @TIN
	AND H.CustID = @Cust_ID
	AND DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01') >=  @StartDate
	AND DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01') < @EndDate
	AND (@DataSet IS NULL OR @DataSet = 5)

	UNION ALL

	-- Tab 6 - Members AWC
	SELECT DISTINCT
	 CAST(NULL AS VARCHAR(50)) AS SSO
	,CAST(NULL AS VARCHAR(50)) AS TIN
	,CAST(NULL AS VARCHAR(MAX)) AS Action
	,CAST(NULL AS DATETIME) AS Created
	,CAST(NULL AS NVARCHAR(300)) AS PageName
	,CAST(NULL AS DATETIME) AS [DateTime]
	,H.MemberFirstName AS MemberFirstName
	,H.MemberLastName AS MemberLastName
	,MVDID
	,MemberID
	,CAST(NULL AS NVARCHAR(100)) AS LocationID
	,CAST(NULL AS NVARCHAR(100)) AS UserName
	,CAST(NULL AS NVARCHAR(4000)) AS AccessReason
	,CAST(NULL AS NVARCHAR(2000)) AS Criteria
	,CAST(NULL AS NVARCHAR(100)) AS ResultStatus
	,CAST(NULL AS INT) AS ResultCount
	,CAST(NULL AS DATETIME) AS AlertSendDate
	,CAST(NULL AS NVARCHAR(200)) AS ChiefComplaint
	,CAST(NULL AS NVARCHAR(2000)) AS EMSNote
	,CAST(NULL AS BIT) AS CancelNotification
	,CAST(NULL AS NVARCHAR(200)) AS CancelNotifyReason
	,CAST(NULL AS VARCHAR(50)) AS Status
	,CAST(NULL AS INT) AS UserFacilityID
	,CAST(NULL AS VARCHAR(MAX)) AS Note	
	,CAST(NULL AS DATETIME) AS DateCreated	
	,CAST(NULL AS VARCHAR(50)) AS CreatedBy	
	,CAST(NULL AS DATETIME) AS DateModified	
	,CAST(NULL AS VARCHAR(50)) AS ModifiedBy	
	,CAST(NULL AS VARCHAR(50)) AS CreatedByType	
	,CAST(NULL AS VARCHAR(50)) AS ModifiedByType	
	,CAST(NULL AS BIT) AS Active
	,H.IsTestDue	
	,H.TestID	
	,H.DoctorUserName	
	,H.CustID	
	,H.PCP_NPI	
	,H.PCP_TIN	
	,H.LOB	
	,H.SDA	
	,H.HasAsthma	
	,H.HasDiabetes	
	,H.RemindInDays	
	,H.ERVisitCount	
	,H.NoteCount	
	,'' AS MeasureNote
	FROM dbo.Final_HEDIS_Member_FULL H
	JOIN dbo.LookupHedis LH ON H.TestID = LH.TestID AND LH.Abbreviation = 'AWC'
	WHERE H.PCP_TIN = @TIN
	AND H.CustID = @Cust_ID
	AND DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01') >=  @StartDate
	AND DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01') < @EndDate
	AND (@DataSet IS NULL OR @DataSet = 6)

	UNION ALL

	-- Tab 7 - Members W15
	SELECT DISTINCT
	 CAST(NULL AS VARCHAR(50)) AS SSO
	,CAST(NULL AS VARCHAR(50)) AS TIN
	,CAST(NULL AS VARCHAR(MAX)) AS Action
	,CAST(NULL AS DATETIME) AS Created
	,CAST(NULL AS NVARCHAR(300)) AS PageName
	,CAST(NULL AS DATETIME) AS [DateTime]
	,H.MemberFirstName AS MemberFirstName
	,H.MemberLastName AS MemberLastName
	,MVDID
	,MemberID
	,CAST(NULL AS NVARCHAR(100)) AS LocationID
	,CAST(NULL AS NVARCHAR(100)) AS UserName
	,CAST(NULL AS NVARCHAR(4000)) AS AccessReason
	,CAST(NULL AS NVARCHAR(2000)) AS Criteria
	,CAST(NULL AS NVARCHAR(100)) AS ResultStatus
	,CAST(NULL AS INT) AS ResultCount
	,CAST(NULL AS DATETIME) AS AlertSendDate
	,CAST(NULL AS NVARCHAR(200)) AS ChiefComplaint
	,CAST(NULL AS NVARCHAR(2000)) AS EMSNote
	,CAST(NULL AS BIT) AS CancelNotification
	,CAST(NULL AS NVARCHAR(200)) AS CancelNotifyReason
	,CAST(NULL AS VARCHAR(50)) AS Status
	,CAST(NULL AS INT) AS UserFacilityID
	,CAST(NULL AS VARCHAR(MAX)) AS Note	
	,CAST(NULL AS DATETIME) AS DateCreated	
	,CAST(NULL AS VARCHAR(50)) AS CreatedBy	
	,CAST(NULL AS DATETIME) AS DateModified	
	,CAST(NULL AS VARCHAR(50)) AS ModifiedBy	
	,CAST(NULL AS VARCHAR(50)) AS CreatedByType	
	,CAST(NULL AS VARCHAR(50)) AS ModifiedByType	
	,CAST(NULL AS BIT) AS Active
	,H.IsTestDue	
	,H.TestID	
	,H.DoctorUserName	
	,H.CustID	
	,H.PCP_NPI	
	,H.PCP_TIN	
	,H.LOB	
	,H.SDA	
	,H.HasAsthma	
	,H.HasDiabetes	
	,H.RemindInDays	
	,H.ERVisitCount	
	,H.NoteCount	
	,'' AS MeasureNote
	FROM dbo.Final_HEDIS_Member_FULL H
	JOIN dbo.LookupHedis LH ON H.TestID = LH.TestID AND LH.Abbreviation = 'W15'
	WHERE H.PCP_TIN = @TIN
	AND H.CustID = @Cust_ID
	AND DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01') >=  @StartDate
	AND DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01') < @EndDate
	AND (@DataSet IS NULL OR @DataSet = 7)

END