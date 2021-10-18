/****** Object:  Procedure [dbo].[GetMonthlyMemberOverview]    Committed by VersionSQL https://www.versionsql.com ******/

/*
CREATEd by : Sunil Nokku
Date: 11/19/2020

EXEC GetMonthlyMemberOverview 'MyVitalDataUAT',
@CM_ORG_REGION = 'WALMART',
@CompanyKey = '11753',
@CompanyName = 'WALMART',
@FormOwner = 'kareed',
@MemberID = '17903656W01',
@p_start_date  = '20201201',
@p_end_date  = '20210129'

ModifiedDate		ModifiedBy			Description
1/15/2021			Sunil Nokku			Included Prepop values in this MMO Report instead of from MMO Form.
1/15/2021			Sunil Nokku			TFS 4244
1/15/2021			Sunil Nokku			TFS 4247
1/27/2021			Sunil Nokku			TFS 4244
1/27/2021			Sunil Nokku			TFS 4250
*/

CREATE PROCEDURE [dbo].[GetMonthlyMemberOverview](
		@DBNAME varchar(100),
		@CM_ORG_REGION nvarchar(max)=null,
		@CompanyKey Varchar(100)=null,
		@CompanyName nvarchar(max)=null,
		@FormOwner nvarchar(max)=null, 
		@MemberID nvarchar(max)=null,
		@p_start_date Datetime =null,
		@p_end_date Datetime =null)

AS
BEGIN

SET NOCOUNT ON;

	DECLARE @v_CM_ORG_REGION nvarchar(max) = null,
			@v_CompanyKey Varchar(100)=null,
			@v_CompanyName nvarchar(max)=null,
			@v_FormOwner nvarchar(max)=null, 
			@v_MemberID nvarchar(max)=null,
			@v_MVDID varchar(30)=null,
			@v_start_date Datetime =null,
			@v_end_date Datetime =null,
			@v_YTDDate datetime
	
	SET @v_CM_ORG_REGION = @CM_ORG_REGION
	SET @v_CompanyKey = @CompanyKey
	SET @v_CompanyName = @CompanyName
	SET @v_FormOwner = @FormOwner
	SET @v_MemberID = @MemberID
	SET @v_start_date = @p_start_date
	SET @v_end_date = DATEADD(HOUR,8,@p_end_date) --TFS 4247
	SET @v_YTDDate = DATEFROMPARTS(YEAR(GETDATE()), 1, 1) --First Day of Current Year
	--SET @v_YTDDate = '20201201' --Test

	DROP TABLE IF EXISTS #MMO_Form_List;
	DROP TABLE IF EXISTS #Contacts;
	DROP TABLE IF EXISTS #ContactDates
	DROP TABLE IF EXISTS #Consults;
	DROP TABLE IF EXISTS #IDTeams;
	DROP TABLE IF EXISTS #CMCases;
	DROP TABLE IF EXISTS #CCMCases;
	DROP TABLE IF EXISTS #MaternityCases;
	DROP TABLE IF EXISTS #SocialCases;
	DROP TABLE IF EXISTS #ClinicalCases;

--Get most recent MMO form in the given range	
	SELECT DISTINCT FIRST_VALUE(mmo.ID) OVER (PARTITION BY mmo.MVDID ORDER BY ID DESC) AS ID, 
	mmo.MVDID,
	fm.MemberID,
	fm.MemberFirstName,
	fm.MemberLastName		
	INTO #MMO_Form_List
	FROM abcbs_monthlymemberoverview_form mmo
	INNER JOIN FinalMember fm ON fm.MVDID = mmo.MVDID
	INNER JOIN dbo.LookupCompanyName C ON fm.CompanyKey=C.company_key
	WHERE fm.CMORGRegion IN (SELECT VALUE FROM dbo.SplitStringVal(@v_CM_ORG_REGION,','))
	AND fm.CompanyKey = @v_CompanyKey
	AND C.Company_Name = @v_CompanyName
	AND mmo.FormAuthor IN (SELECT VALUE FROM dbo.SplitStringVal(@v_FormOwner,','))
	AND fm.MemberID IN (SELECT VALUE FROM dbo.SplitStringVal(@v_MemberID,','))
	AND mmo.FormDate BETWEEN @v_start_date AND @v_end_date

	CREATE INDEX IX_ID ON #MMO_Form_List (ID)
	CREATE INDEX IX_MVDID ON #MMO_Form_List (MVDID)

--Get most recent Prepopulated values
	CREATE TABLE #PrepopValues ( 
		MVDID  [varchar](30) NOT NULL,                         
		MemberID  varchar(30) NULL,        
		PolicyEffectiveDate  [date] NULL,
		PolicyTerminationDate  [date] NULL,
		qGroup  [varchar](max) NULL,                                                                                             
		SubscriberRelationship  [varchar](max) NULL,                                                                              
		qFormAuthor  [varchar](max) NULL,                                                                                        
		ClaimsDollarsPaidToDate  [varchar](max) NULL,                                                                                                                                                                                                                                        
		PredictedHighCostClaimant  [varchar](max) NULL,
		RiskLevel  [varchar](max) NULL,
		RiskScore  [varchar](max) NULL, 
		LastMedicationReconciliationDate  [datetime] NULL,
		MedicationList  [varchar](max) NULL,                                                                                                                                                                                                                                                 
		IncompleteCPGoals   [varchar](max) NULL) 
	
	INSERT INTO #PrepopValues
	SELECT * 
	FROM (
		SELECT DISTINCT
		m.MVDID,
		m.MemberID,
		(	SELECT 
			MAX(MemberEffectiveDate)  
			FROM FinalEligibility 
			WHERE mvdid = m.MVDID
			GROUP BY mvdid	) AS PolicyEffectiveDate,
		(	SELECT 
			MAX(MemberTerminationDate) 
			FROM FinalEligibility 
			WHERE mvdid = m.MVDID
			GROUP BY mvdid	) AS PolicyTerminationDate,
		ccq.CompanyName AS qGroup,
		CASE WHEN r.mbr_rel_val3_name = 'SUBSCRIBER' 
			THEN 'EE' ELSE r.mbr_rel_val3_name
			END AS SubscriberRelationship,
		mmo.FormAuthor AS qFormAuthor,
		STUFF((
				SELECT DISTINCT ','+ convert(varchar,sum(ch.TotalPaidAmount)) 
				FROM FinalClaimsHeader ch (READUNCOMMITTED)
				WHERE ch.mvdid=m.MVDID 
				AND convert(date,ch.statementfromdate) between @v_YTDDate and Getdate()
				FOR XML PATH('')),1,1,'') AS ClaimsDollarsPaidToDate,
		(	SELECT DISTINCT
			FIRST_VALUE (CASE WHEN t.is_top10pct_predicted =1 and t.is_recurring =1 
							THEN 'Yes' ELSE 'No' END ) 
							OVER (PARTITION BY t.PartyKey ORDER BY t.Prediction_Date DESC)
			FROM tags_for_high_risk_members t
			INNER JOIN finalmember fm on fm.partykey = t.partykey
			WHERE fm.MVDID = m.MVDID	) AS PredictedHighCostClaimant,

		CASE WHEN ccq.RiskGroupID BETWEEN 1 AND 4 THEN 'Low'
			WHEN ccq.RiskGroupID BETWEEN 5 AND 7 THEN 'Medium'
			WHEN ccq.RiskGroupID BETWEEN 8 AND 10 THEN 'High'
			END AS 'RiskLevel',
		ccq.RiskGroupID AS 'RiskScore',
		(	SELECT DISTINCT TOP 1 mr.ReconDateTime 
			FROM dbo.MainMedRec mr (READUNCOMMITTED)
			where mr.mvdid=m.MVDID
			ORDER BY mr.ReconDateTime DESC	 ) AS LastMedicationReconciliationDate,
		stuff((
				SELECT DISTINCT ',' + cast((mr.NDC) as varchar(max))
				FROM dbo.MainMedRec mr 
				where mr.mvdid=m.MVDID
				and mr.ReconDateTime = (select top 1 ReconDateTime FROM dbo.MainMedRec mr 
										where mr.mvdid=m.MVDID order by ReconDateTime desc )
				FOR XML PATH('')
				), 1, 1, '') AS MedicationList,
		stuff((
				SELECT DISTINCT ', ' + cast(LTRIM(RTRIM(REPLACE(REPLACE(CPP.problemfreetext,CHAR(13),''),CHAR(10),''))) as varchar(max))
				FROM dbo.MainCarePlanMemberIndex CPI
				LEFT OUTER JOIN dbo.MainCarePlanMemberProblems CPP 
				ON CPP.[CarePlanID] = CPI.[CarePlanID]
				LEFT OUTER JOIN dbo.MainCarePlanMemberGoals CPG 
				ON CPG.[GoalNum] = CPP.[problemNum]
				WHERE cpi.mvdid=m.MVDID
				AND ISNULL(CPI.cpInactiveDate,'')=''
				AND completedate is null
				FOR XML PATH('')
				), 1, 1, ''	) AS IncompleteCPGoals
		FROM
		FinalMember m (READUNCOMMITTED)
		INNER JOIN #MMO_Form_List l ON l.MVDID = m.MVDID
		LEFT JOIN FinalClaimsHeader ch (READUNCOMMITTED) ON m.MVDID = ch. MVDID
		LEFT JOIN LookupMemberRelationship r (READUNCOMMITTED)
		ON 
		CASE WHEN LEN(r.[data_source_val]) < 2 
			THEN CONCAT('0',r.[data_source_val]) 
			ELSE r.[data_source_val] END = m.[Relationship]
		AND r.[data_source] = m.[datasource]
		AND r.mbr_rel_val3_name NOT LIKE 'UNKNOWN%'
		AND r.mbr_rel_val3_name NOT LIKE 'INVALID%'
		LEFT JOIN ComputedCareQueue ccq (READUNCOMMITTED) ON ccq.MVDID = m.MVDID
		LEFT JOIN MainMedRec mr (READUNCOMMITTED) ON mr.MVDID = m.MVDID
		LEFT JOIN ABCBS_MonthlyMemberOverview_Form mmo (READUNCOMMITTED) ON mmo.MVDID = m.MVDID
		LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 cmtp (READUNCOMMITTED) ON cmtp.MVDID = m.MVDID
		GROUP BY m.MVDID,m.MemberID,
		ccq.CompanyName,r.mbr_rel_val3_name,mmo.FormAuthor,
		ccq.RiskGroupID,mr.ReconDateTime,mr.SessionID,mr.ID,mr.NDC,cmtp.HighDollarClaim
		) a
		
	CREATE INDEX IX_Prepop_MVDID ON #PrepopValues (MVDID)

--Contacts
	SELECT MVDID, 
		SUM(a.InboundSuccessfulCount) AS TotalInboundSuccessfulCount, 
		SUM(a.OutboundSuccessfulCount) AS TotalOutboundSuccessfulCount,
		SUM(a.InboundUnSuccessfulCount) AS TotalInboundUnSuccessfulCount, 
		SUM(a.OutboundUnSuccessfulCount) AS TotalOutboundUnSuccessfulCount, 
		SUM(a.VPR) AS VendorProgramReferrals
	INTO #Contacts
	FROM
		(SELECT con.MVDID,
				CASE WHEN q3contacttype = 'Inbound' AND q7ContactSuccess = 'Yes' 
					THEN 1 ELSE 0 END AS InboundSuccessfulCount,
				CASE WHEN q3contacttype = 'Outbound' AND q7ContactSuccess = 'Yes' 
					THEN 1 ELSE 0 END AS OutboundSuccessfulCount,
				CASE WHEN q3contacttype = 'Inbound' AND q7ContactSuccess = 'No' 
					THEN 1 ELSE 0 END AS InboundUnSuccessfulCount,
				CASE WHEN q3contacttype = 'Outbound' AND q7ContactSuccess = 'No' 
					THEN 1 ELSE 0 END AS OutboundUnSuccessfulCount,
				CASE WHEN q9vendorsdiscussed= 'Yes' AND q7ContactSuccess = 'Yes'			
					THEN 1 ELSE 0 END AS VPR
		FROM ARBCBS_Contact_Form con
		INNER JOIN #MMO_Form_List l ON l.MVDID = con.MVDID
		WHERE (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
		AND q1ContactDate BETWEEN @v_YTDDate AND GETDATE() ) a
	GROUP BY a.MVDID

	CREATE INDEX IX_Contacts_MVDID ON #Contacts (MVDID)

--ContactDates
--CONVERT( varchar, cf.q1ContactDate, 121 )
	SELECT DISTINCT
	cd.MVDID,
	STUFF((
				SELECT CONCAT( ', ', FORMAT( cf.q1ContactDate, 'MM/dd/yyyy hh:mm tt' ) )
				FROM(
						SELECT DISTINCT MVDID, q1ContactDate
						FROM ARBCBS_Contact_Form
						WHERE q3contacttype = 'Inbound'
						AND q7ContactSuccess = 'Yes' 
						AND (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
						AND q1ContactDate BETWEEN @v_YTDDate AND GETDATE()) cf
				WHERE
				cf.MVDID = cd.MVDID
				AND ISNULL( cf.q1ContactDate, '' ) != ''
				ORDER BY cf.q1ContactDate
				FOR XML PATH ('')
			)
			,1,1,'') InboundSuccessfulDates,
	STUFF((
				SELECT CONCAT( ', ', FORMAT( cf.q1ContactDate, 'MM/dd/yyyy hh:mm tt' ) )
				FROM(
						SELECT DISTINCT MVDID, q1ContactDate
						FROM ARBCBS_Contact_Form
						WHERE q3contacttype = 'Outbound'
						AND q7ContactSuccess = 'Yes' 
						AND (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
						AND q1ContactDate BETWEEN @v_YTDDate AND GETDATE()) cf
				WHERE
				cf.MVDID = cd.MVDID
				AND ISNULL( cf.q1ContactDate, '' ) != ''
				ORDER BY cf.q1ContactDate
				FOR XML PATH ('')
			)
			,1,1,'') OutboundSuccessfulDates,
	STUFF((
				SELECT CONCAT( ', ', FORMAT( cf.q1ContactDate, 'MM/dd/yyyy hh:mm tt' ) )
				FROM(
						SELECT DISTINCT MVDID, q1ContactDate
						FROM ARBCBS_Contact_Form
						WHERE q3contacttype = 'Inbound'
						AND q7ContactSuccess = 'No' 
						AND (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
						AND q1ContactDate BETWEEN @v_YTDDate AND GETDATE()) cf
				WHERE
				cf.MVDID = cd.MVDID
				AND ISNULL( cf.q1ContactDate, '' ) != ''
				ORDER BY cf.q1ContactDate
				FOR XML PATH ('')
			)
		 ,1,1,'') InboundUnsuccessfulDates,
	STUFF((
				SELECT CONCAT( ', ', FORMAT( cf.q1ContactDate, 'MM/dd/yyyy hh:mm tt' ) )
				FROM(
						SELECT DISTINCT MVDID, q1ContactDate
						FROM ARBCBS_Contact_Form
						WHERE q3contacttype = 'Outbound'
						AND q7ContactSuccess = 'No' 
						AND (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
						AND q1ContactDate BETWEEN @v_YTDDate AND GETDATE()) cf
				WHERE
				cf.MVDID = cd.MVDID
				AND ISNULL( cf.q1ContactDate, '' ) != ''
				ORDER BY cf.q1ContactDate
				FOR XML PATH ('')
			)
		 ,1,1,'') OutboundUnsuccessfulDates
	INTO #ContactDates
	FROM ARBCBS_Contact_Form cd
	INNER JOIN #MMO_Form_List l ON l.MVDID = cd.MVDID
	WHERE (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
	AND q1ContactDate BETWEEN @v_YTDDate AND GETDATE()

	CREATE INDEX IX_ContactDates_MVDID ON #ContactDates (MVDID)

--Consults
	SELECT b.MVDID, 
		SUM(b.MedicalDirector) AS MedicalDirectorConsultation,
		SUM(b.Pharmacist) AS PharmacistConsultation,
		SUM(b.SocialWorker) AS SocialWorkerConsultation,
		SUM(b.Dietitian) AS DietitianConsultation,
		SUM(b.SpecialtyCM) AS SpecialtyCMConsultation,  
		SUM(b.CaseManagement) AS CaseManagementConsultation
	INTO #Consults
	FROM
		(SELECT cons.MVDID,
				CASE WHEN q20ConsultType = 'Medical Director' 
					THEN 1 ELSE 0 END AS MedicalDirector,
				CASE WHEN q20ConsultType = 'Pharmacist' 
					THEN 1 ELSE 0 END AS Pharmacist,
				CASE WHEN q20ConsultType = 'Social Worker' 
					THEN 1 ELSE 0 END AS SocialWorker,
				CASE WHEN q20ConsultType = 'Dietitian' 
					THEN 1 ELSE 0 END AS Dietitian,
				CASE WHEN q20ConsultType = 'Specialty CM' 
					THEN 1 ELSE 0 END AS SpecialtyCM,
				CASE WHEN q20ConsultType = 'Case Management' 
					THEN 1 ELSE 0 END AS CaseManagement
		FROM Consult_Form cons
		INNER JOIN #MMO_Form_List l ON l.MVDID = cons.MVDID
		WHERE q1ConsultDate between @v_YTDDate and GETDATE()  
		AND SectionCompleted = 1) b
	GROUP BY b.MVDID

	CREATE INDEX IX_Consults_MVDID ON #Consults (MVDID)

--Interdisciplinary Teams
	SELECT c.MVDID,
		SUM(c.IDTMeeting) AS IDTMeeting,
		SUM(c.CMRounds) AS CMRounds,
		SUM(c.CourtesyReview) AS CourtesyReview,
		SUM(c.MDFollowUp) AS MDFollowUp,
		SUM(c.PrePay) AS PrePay,
		SUM(c.Appeals) AS Appeals,
		SUM(c.OnSiteVisit) AS OnSiteVisit,
		SUM(c.PeerToPeer) AS PeerToPeer,
		SUM(c.GenMemQuestion) AS GenMemQuestion,
		SUM(c.PharmacistCMRounds) AS PharmacistCMRounds,
		SUM(c.PharmacistReferral) AS PharmacistReferral,
		SUM(c.Intervention) AS Intervention
	INTO #IDTeams
	FROM
		(SELECT idf.MVDID,
			   CASE WHEN qdiscipline = 'Medical Director' AND qMeetingType = 'Interdisciplinary Team Meeting' 
					THEN 1 ELSE 0 END AS IDTMeeting,
			   CASE WHEN qdiscipline = 'Medical Director' AND qMeetingType = 'Care Management Rounds' 
					THEN 1 ELSE 0 END AS CMRounds,
			   CASE WHEN qdiscipline = 'Medical Director' AND qMeetingType = 'Courtesy Review' 
					THEN 1 ELSE 0 END AS CourtesyReview,
			   CASE WHEN qdiscipline = 'Medical Director' AND qMeetingType = 'Medical Director Follow-Up' 
					THEN 1 ELSE 0 END AS MDFollowUp,
			   CASE WHEN qdiscipline = 'Medical Director' AND qMeetingType = 'Prepay' 
					THEN 1 ELSE 0 END AS PrePay,
			   CASE WHEN qdiscipline = 'Medical Director' AND qMeetingType = 'Appeals' 
					THEN 1 ELSE 0 END AS Appeals,
			   CASE WHEN qdiscipline = 'Medical Director' AND qMeetingType = 'Onsite Visit' 
					THEN 1 ELSE 0 END AS OnSiteVisit,
			   CASE WHEN qdiscipline = 'Medical Director' AND qMeetingType = 'Peer to Peer' 
					THEN 1 ELSE 0 END AS PeerToPeer,
			   CASE WHEN qdiscipline = 'Pharmacy' AND qContactType = 'General Member Question' 
					THEN 1 ELSE 0 END AS GenMemQuestion,
			   CASE WHEN qdiscipline = 'Pharmacy' AND qContactType = 'Care Management Rounds' 
					THEN 1 ELSE 0 END AS PharmacistCMRounds,
			   CASE WHEN qdiscipline = 'Pharmacy' AND qContactType = 'Pharmacist Referral' 
					THEN 1 ELSE 0 END AS PharmacistReferral,
			   CASE WHEN qdiscipline = 'Social Work' 
					THEN 1 ELSE 0 END AS Intervention
		FROM ABCBS_InterdisciplinaryTeam_Form idf
		INNER JOIN #MMO_Form_List l ON l.MVDID = idf.MVDID
		INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
		ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
		AND hpan_cf.LinkedFormID = idf.ID
		AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
		WHERE idf.MVDID = l.MVDID
		AND idf.FormDate BETWEEN @v_YTDDate AND GETDATE() ) c
	GROUP by c.MVDID

	CREATE INDEX IX_IDTeams_MVDID ON #IDTeams (MVDID)

--CaseManagement Cases
	SELECT mmf.MVDID AS MVDID,
			mmf.CaseID AS CMCaseID, 
			mmf.q1casecreatedate AS CMDateIdentified, 
			mmf.caseprogram AS CMCaseProgram, 
			mmf.referralreason AS CMReferralReason, 
			mmf.referralsource AS CMReferralSource
	INTO #CMCases
	FROM abcbs_membermanagement_form mmf (readuncommitted)
	INNER JOIN #MMO_Form_List l ON l.MVDID = mmf.MVDID
	WHERE LEN(mmf.CaseID) > 1 -- Added to avoid null CaseID
	AND mmf.sectioncompleted < =3
	AND ISNULL(qCloseCase,'') <> 'Yes'
	AND ISNULL(CAST(q1CaseCloseDate AS varchar(100)),'') <> '1900-01-01 00:00:00.000'
	AND mmf.CaseProgram = 'Case Management'

	CREATE INDEX IX_CMCases_MVDID ON #CMCases (MVDID)

--ChronicConditionCaseManagement Cases
	SELECT mmf.MVDID AS MVDID,
			mmf.CaseID AS ChronicCaseID, 
			mmf.q1casecreatedate AS ChronicCondDateIdentified, 
			mmf.caseprogram AS ChronicCaseProgram, 
			mmf.referralreason AS ChronicCondReferralReason, 
			mmf.referralsource AS ChronicCondReferralSource
	INTO #CCMCases
	FROM abcbs_membermanagement_form mmf (readuncommitted)
	INNER JOIN #MMO_Form_List l ON l.MVDID = mmf.MVDID
	WHERE LEN(mmf.CaseID) > 1 -- Added to avoid null CaseID
	AND mmf.sectioncompleted < =3
	AND ISNULL(qCloseCase,'') <> 'Yes'
	AND ISNULL(CAST(q1CaseCloseDate AS varchar(100)),'') <> '1900-01-01 00:00:00.000'
	AND mmf.CaseProgram = 'Chronic Condition Management'

	CREATE INDEX IX_CCMCases_MVDID ON #CCMCases (MVDID)

--Maternity Cases
	SELECT mmf.MVDID AS MVDID,
			mmf.CaseID AS MaternityCaseID, 
			mmf.q1casecreatedate AS MaternityDateIdentified, 
			mmf.caseprogram AS MaternityCaseProgram, 
			mmf.referralreason AS MaternityReferralReason, 
			mmf.referralsource AS MaternityReferralSource
	INTO #MaternityCases
	FROM abcbs_membermanagement_form mmf (readuncommitted)
	INNER JOIN #MMO_Form_List l ON l.MVDID = mmf.MVDID
	WHERE LEN(mmf.CaseID) > 1 -- Added to avoid null CaseID
	AND mmf.sectioncompleted < =3
	AND ISNULL(qCloseCase,'') <> 'Yes'
	AND ISNULL(CAST(q1CaseCloseDate AS varchar(100)),'') <> '1900-01-01 00:00:00.000'
	AND mmf.CaseProgram = 'Maternity'

	CREATE INDEX IX_MaternityCases_MVDID ON #MaternityCases (MVDID)

--SocialWork Cases
	SELECT mmf.MVDID AS MVDID,
			mmf.CaseID AS SWCaseID, 
			mmf.q1casecreatedate AS SWDateIdentified, 
			mmf.caseprogram AS SWCaseProgram, 
			mmf.referralreason AS SWReferralReason, 
			mmf.referralsource AS SWReferralSource
	INTO #SocialCases
	FROM abcbs_membermanagement_form mmf (readuncommitted)
	INNER JOIN #MMO_Form_List l ON l.MVDID = mmf.MVDID
	WHERE LEN(mmf.CaseID) > 1 -- Added to avoid null CaseID
	AND mmf.sectioncompleted < =3
	AND ISNULL(qCloseCase,'') <> 'Yes'
	AND ISNULL(CAST(q1CaseCloseDate AS varchar(100)),'') <> '1900-01-01 00:00:00.000'
				AND mmf.CaseProgram = 'Social Work'

	CREATE INDEX IX_SocialCases_MVDID ON #SocialCases (MVDID)

--ClinicalSupport Cases
	SELECT mmf.MVDID AS MVDID,
			mmf.CaseID AS ClinicalCaseID, 
			mmf.q1casecreatedate AS ClinicalSupportDateIdentified, 
			mmf.caseprogram AS ClinicalCaseProgram, 
			mmf.referralreason AS ClinicalSupportReferralReason, 
			mmf.referralsource AS ClinicalSupportReferralSource
	INTO #ClinicalCases
	FROM abcbs_membermanagement_form mmf (readuncommitted)
	INNER JOIN #MMO_Form_List l ON l.MVDID = mmf.MVDID
	WHERE LEN(mmf.CaseID) > 1 -- Added to avoid null CaseID
	AND mmf.sectioncompleted < =3
	AND ISNULL(qCloseCase,'') <> 'Yes'
	AND ISNULL(CAST(q1CaseCloseDate AS varchar(100)),'') <> '1900-01-01 00:00:00.000'
	AND mmf.CaseProgram = 'Clinical Support'

	CREATE INDEX IX_ClinicalCases_MVDID ON #ClinicalCases (MVDID)

	CREATE TABLE #Final_MMO_Result(
		[ID] [bigint] NULL,
		[MVDID] [varchar](30) NOT NULL,
		MemberID varchar(30) NULL,
		MemberFirstName varchar(50) NULL,
		MemberLastName varchar(50) NULL,
		[FormDate] [datetime] NOT NULL,
		[FormAuthor] [varchar](100) NOT NULL,
		[CMCaseID] [varchar](100) NULL,
		[MaternityCaseID] [varchar](100) NULL,
		[ClinicalCaseID] [varchar](100) NULL,
		[ChronicCaseID] [varchar](100) NULL,
		[SWCaseID] [varchar](100) NULL,
		[Version] [varchar](max) NULL,
		[PolicyEffectiveDate] [date] NULL,
		[PolicyTerminationDate] [date] NULL,
		[DateOfDeath] [date] NULL,
		[qGroup] [varchar](max) NULL,
		[SubscriberRelationship] [varchar](max) NULL,
		[qFormAuthor] [varchar](max) NULL,
		[ClaimsDollarsPaidToDate] [varchar](max) NULL,
		[PredictedHighCostClaimant] [varchar](max) NULL,
		[AnticipateHighCostClaimant] [varchar](max) NULL,
		CMCaseProgram [varchar](max) NULL,
		[CMDateIdentified] [datetime] NULL,
		[CMReferralSource] [varchar](max) NULL,
		[CMReferralReason] [varchar](max) NULL,
		MaternityCaseProgram [varchar](max) NULL,
		[MaternityDateIdentified] [datetime] NULL,
		[MaternityReferralSource] [varchar](max) NULL,
		[MaternityReferralReason] [varchar](max) NULL,
		ClinicalCaseProgram [varchar](max) NULL,
		[ClinicalSupportDateIdentified] [datetime] NULL,
		[ClinicalSupportReferralSource] [varchar](max) NULL,
		[ClinicalSupportReferralReason] [varchar](max) NULL,
		ChronicCaseProgram [varchar](max) NULL,
		[ChronicCondDateIdentified] [datetime] NULL,
		[ChronicCondReferralSource] [varchar](max) NULL,
		[ChronicCondReferralReason] [varchar](max) NULL,
		SWCaseProgram [varchar](max) NULL,
		[SWDateIdentified] [datetime] NULL,
		[SWReferralSource] [varchar](max) NULL,
		[SWReferralReason] [varchar](max) NULL,
		[ReferralCriteria] [varchar](max) NULL,
		[RiskLevel] [varchar](max) NULL,
		[RiskScore] [varchar](max) NULL,
		[PrimaryDiagDesc] [varchar](max) NULL,
		[DiagnosisEstablishedDate] [datetime] NULL,
		[BriefHistory] [varchar](max) NULL,
		[TreatmentPlan] [varchar](max) NULL,
		[AnticipatedTreatmentPlan] [varchar](max) NULL,
		[FacilityType] [varchar](max) NULL,
		[TreatmentLocation] [varchar](max) NULL,
		[Network] [varchar](max) NULL,
		[EducationalMaterials] [varchar](max) NULL,
		[TotalInboundSuccessfulCount] INT NULL,
		[TotalOutboundSuccessfulCount] INT NULL,
		[TotalInboundUnSuccessfulCount] INT NULL,
		[TotalOutboundUnSuccessfulCount] INT NULL,
		[GrandTotalContact] INT NULL,
		[InboundSuccessfulDates] [varchar](max) NULL,
		[OutboundSuccessfulDates] [varchar](max) NULL,
		[InboundUnSuccessfulDates] [varchar](max) NULL,
		[OutboundUnSuccessfulDates] [varchar](max) NULL,
		[ClinicalIndicators] [varchar](max) NULL,
		[EvidenceBasedGuidelines] [varchar](max) NULL,
		[MedicationReconciliationDate] [datetime] NULL,
		[MedicationLists] [varchar](max) NULL,
		[DepressionScreningResults] [varchar](max) NULL,
		[DepressionScreeningCompleted] [varchar](max) NULL,
		[IncompleteCPGoals] [varchar](max) NULL,
		[TreatingPhysicians] [varchar](max) NULL,
		[MedicalDirectorConsultation] INT NULL,
		[PharmacistConsultation] INT NULL,
		[SocialWorkerConsultation] INT NULL,
		[DietitianConsultation] INT NULL,
		[SpecialtyCMConsultation] INT NULL,
		[CaseManagementConsultation] INT NULL,
		[TotalConsultations] INT NULL,
		[IDTMeeting] INT NULL,
		[CMRounds] INT NULL,
		[CourtesyReview] INT NULL,
		[MDFollowUp] INT NULL,
		[PrePay] INT NULL,
		[Appeals] INT NULL,
		[OnSiteVisit] INT NULL,
		[PeerToPeer] INT NULL,
		[TotalMDActivity] INT NULL,
		[GenMemQuestion] INT NULL,
		[PharmacistCMRounds] INT NULL,
		[PharmacistReferral] INT NULL,
		[TotalPharmacistActivity] INT NULL,
		[Intervention] INT NULL,
		[WorkStatus] [varchar](max) NULL,
		[VendorProgramReferrals] [varchar](max) NULL,
		[Impact] [varchar](max) NULL,
		[Utilization] [varchar](max) NULL,
		[SpecialistTypes] [varchar](max) NULL,
		[IsLocked] [varchar](max) NULL,
		[LastModifiedDate] [datetime] NULL
		) 
	
	INSERT INTO #Final_MMO_Result(
		[ID],
		[MVDID],
		MemberID,
		MemberFirstName,
		MemberLastName,
		[FormDate] ,
		[FormAuthor] ,
		[CMCaseID] ,
		[MaternityCaseID] ,
		[ClinicalCaseID] ,
		[ChronicCaseID] ,
		[SWCaseID] ,
		[Version] ,
		[PolicyEffectiveDate] ,
		[PolicyTerminationDate] ,
		[DateOfDeath] ,
		[qGroup] ,
		[SubscriberRelationship] ,
		[qFormAuthor] ,
		[ClaimsDollarsPaidToDate] ,
		[PredictedHighCostClaimant] ,
		[AnticipateHighCostClaimant] ,
		CMCaseProgram ,
		[CMDateIdentified] ,
		[CMReferralSource] ,
		[CMReferralReason] ,
		MaternityCaseProgram ,
		[MaternityDateIdentified] ,
		[MaternityReferralSource] ,
		[MaternityReferralReason] ,
		ClinicalCaseProgram ,
		[ClinicalSupportDateIdentified] ,
		[ClinicalSupportReferralSource],
		[ClinicalSupportReferralReason] ,
		ChronicCaseProgram ,
		[ChronicCondDateIdentified] ,
		[ChronicCondReferralSource] ,
		[ChronicCondReferralReason] ,
		SWCaseProgram ,
		[SWDateIdentified] ,
		[SWReferralSource] ,
		[SWReferralReason] ,
		[ReferralCriteria] ,
		[RiskLevel] ,
		[RiskScore] ,
		[PrimaryDiagDesc] ,
		[DiagnosisEstablishedDate] ,
		[BriefHistory] ,
		[TreatmentPlan] ,
		[AnticipatedTreatmentPlan] ,
		[FacilityType] ,
		[TreatmentLocation] ,
		[Network] ,
		[EducationalMaterials] ,
		[TotalInboundSuccessfulCount] ,
		[TotalOutboundSuccessfulCount] ,
		[TotalInboundUnSuccessfulCount]  ,
		[TotalOutboundUnSuccessfulCount]  ,
		[GrandTotalContact]  ,
		[InboundSuccessfulDates] ,
		[OutboundSuccessfulDates] ,
		[InboundUnSuccessfulDates] ,
		[OutboundUnSuccessfulDates] ,
		[ClinicalIndicators] ,
		[EvidenceBasedGuidelines] ,
		[MedicationReconciliationDate] ,
		[MedicationLists] ,
		[DepressionScreningResults] ,
		[DepressionScreeningCompleted] ,
		[IncompleteCPGoals] ,
		[TreatingPhysicians] ,
		[MedicalDirectorConsultation]  ,
		[PharmacistConsultation]  ,
		[SocialWorkerConsultation]  ,
		[DietitianConsultation]  ,
		[SpecialtyCMConsultation]  ,
		[CaseManagementConsultation]  ,
		[TotalConsultations]  ,
		[IDTMeeting]  ,
		[CMRounds]  ,
		[CourtesyReview]  ,
		[MDFollowUp]  ,
		[PrePay]  ,
		[Appeals]  ,
		[OnSiteVisit]  ,
		[PeerToPeer]  ,
		[TotalMDActivity]  ,
		[GenMemQuestion]  ,
		[PharmacistCMRounds]  ,
		[PharmacistReferral]  ,
		[TotalPharmacistActivity]  ,
		[Intervention]  ,
		[WorkStatus] ,
		[VendorProgramReferrals] ,
		[Impact] ,
		[Utilization] ,
		[SpecialistTypes] ,
		[IsLocked] ,
		[LastModifiedDate] 
	)

--Format the resultset to support SSRS
	SELECT  mmo.ID
		  ,mmo.MVDID
		  ,l.MemberID
		  ,l.MemberFirstName
		  ,l.MemberLastName
		  ,mmo.[FormDate]
		  ,mmo.[FormAuthor]
		  ,cm.CMCaseID
		  ,mat.MaternityCaseID
		  ,cli.ClinicalCaseID
		  ,ccm.ChronicCaseID
		  ,soc.SWCaseID
		  ,mmo.[Version]
		  ,p.[PolicyEffectiveDate]
		  ,p.[PolicyTerminationDate]
		  ,mmo.[DateOfDeath]
		  ,LTRIM(RTRIM(p.[qGroup])) AS qGroup
		  ,p.[SubscriberRelationship]
		  ,p.[qFormAuthor]
		  ,p.[ClaimsDollarsPaidToDate]
		  ,p.[PredictedHighCostClaimant]
		  ,mmo.[AnticipateHighCostClaimant]
		  ,cm.CMCaseProgram
		  ,cm.[CMDateIdentified]
		  ,cm.[CMReferralSource]
		  ,cm.[CMReferralReason]
		  ,mat.MaternityCaseProgram
		  ,mat.[MaternityDateIdentified]
		  ,mat.[MaternityReferralSource]
		  ,mat.[MaternityReferralReason]
		  ,cli.ClinicalCaseProgram
		  ,cli.[ClinicalSupportDateIdentified]
		  ,cli.[ClinicalSupportReferralSource]
		  ,cli.[ClinicalSupportReferralReason]
		  ,ccm.ChronicCaseProgram
		  ,ccm.[ChronicCondDateIdentified]
		  ,ccm.[ChronicCondReferralSource]
		  ,ccm.[ChronicCondReferralReason]
		  ,soc.SWCaseProgram
		  ,soc.[SWDateIdentified]
		  ,soc.[SWReferralSource]
		  ,soc.[SWReferralReason]
		  ,Replace(Replace(Replace(mmo.ReferralCriteria,'[',''),']',''),'"','') AS ReferralCriteria
		  ,p.[RiskLevel]
		  ,p.[RiskScore]
		  ,mmo.[PrimaryDiagDesc]
		  ,mmo.[DiagnosisEstablishedDate]
		  ,mmo.[BriefHistory]
		  ,mmo.[TreatmentPlan]
		  ,mmo.[AnticipatedTreatmentPlan]
		  ,mmo.[FacilityType]
		  ,mmo.[TreatmentLocation]
		  ,Replace(Replace(Replace(mmo.Network,'[',''),']',''),'"','') AS Network
		  ,Replace(Replace(Replace(mmo.EducationalMaterials,'[',''),']',''),'"','') AS EducationalMaterials
		  ,ISNULL(con.[TotalInboundSuccessfulCount],0) AS [TotalInboundSuccessfulCount]
		  ,ISNULL(con.[TotalOutboundSuccessfulCount],0) AS [TotalOutboundSuccessfulCount]
		  ,ISNULL(con.[TotalInboundUnSuccessfulCount],0) AS [TotalInboundUnSuccessfulCount]
		  ,ISNULL(con.[TotalOutboundUnSuccessfulCount],0) AS [TotalOutboundUnSuccessfulCount]
		  ,0 AS [GrandTotalContact]
		  ,cd.[InboundSuccessfulDates]
		  ,cd.[OutboundSuccessfulDates]
		  ,cd.[InboundUnSuccessfulDates]
		  ,cd.[OutboundUnSuccessfulDates]
		  ,Replace(Replace(Replace(mmo.ClinicalIndicators,'[',''),']',''),'"','') AS ClinicalIndicators
		  ,Replace(Replace(Replace(mmo.EvidenceBasedGuidelines,'[',''),']',''),'"','') AS EvidenceBasedGuidelines
		  ,p.[LastMedicationReconciliationDate]
		  ,p.[MedicationList]
		  ,mmo.[DepressionScreningResults]
		  ,mmo.[DepressionScreeningCompleted]
		  ,ISNULL(p.[IncompleteCPGoals],'NA') AS [IncompleteCPGoals]
		  ,mmo.[TreatingPhysicians]
		  ,ISNULL(cons.[MedicalDirectorConsultation],0) AS [MedicalDirectorConsultation]
		  ,ISNULL(cons.[PharmacistConsultation],0) AS [PharmacistConsultation]
		  ,ISNULL(cons.[SocialWorkerConsultation],0) AS [SocialWorkerConsultation]
		  ,ISNULL(cons.[DietitianConsultation],0) AS [DietitianConsultation]
		  ,ISNULL(cons.[SpecialtyCMConsultation],0) AS [SpecialtyCMConsultation]
		  ,ISNULL(cons.[CaseManagementConsultation],0) AS [CaseManagementConsultation]
		  ,0 AS  [TotalConsultations]
		  ,ISNULL(idt.[IDTMeeting],0) AS [IDTMeeting]
		  ,ISNULL(idt.[CMRounds],0) AS [CMRounds]
		  ,ISNULL(idt.[CourtesyReview],0) AS [CourtesyReview]
		  ,ISNULL(idt.[MDFollowUp],0) AS [MDFollowUp]
		  ,ISNULL(idt.[PrePay],0) AS [PrePay]
		  ,ISNULL(idt.[Appeals],0) AS [Appeals]
		  ,ISNULL(idt.[OnSiteVisit],0) AS [OnSiteVisit]
		  ,ISNULL(idt.[PeerToPeer],0) AS [PeerToPeer]
		  ,0 AS [TotalMDActivity]
		  ,ISNULL(idt.[GenMemQuestion],0) AS [GenMemQuestion]
		  ,ISNULL(idt.[PharmacistCMRounds],0) AS [PharmacistCMRounds]
		  ,ISNULL(idt.[PharmacistReferral],0) AS [PharmacistReferral]
		  ,0 AS [TotalPharmacistActivity]
		  ,ISNULL(idt.[Intervention],0) AS [Intervention]
		  ,mmo.[WorkStatus]
		  ,con.[VendorProgramReferrals]
		  ,mmo.[Impact]
		  ,Replace(Replace(Replace(Replace(mmo.Utilization,'[',''),']',''),'"',''),CHAR(13)+CHAR(10),'') AS Utilization
		  ,mmo.[SpecialistTypes]
		  ,mmo.[IsLocked] 
		  ,[LastModifiedDate] 
	FROM ABCBS_MonthlyMemberOverview_Form mmo
	INNER JOIN #MMO_Form_List l ON l.ID = mmo.ID 
	INNER JOIN #PrepopValues p ON p.MVDID = l.MVDID
	LEFT JOIN #Contacts con ON con.MVDID = l.MVDID
	LEFT JOIN #ContactDates cd ON cd.MVDID = l.MVDID
	LEFT JOIN #Consults cons ON cons.MVDID = l.MVDID
	LEFT JOIN #IDTeams idt ON idt.MVDID = l.MVDID
	LEFT JOIN #CMCases cm ON cm.MVDID = l.MVDID
	LEFT JOIN #CCMCases ccm ON ccm.MVDID = l.MVDID
	LEFT JOIN #MaternityCases mat ON mat.MVDID = l.MVDID
	LEFT JOIN #ClinicalCases cli ON cli.MVDID = l.MVDID
	LEFT JOIN #SocialCases soc ON soc.MVDID = l.MVDID

--Sort the resultset	
	SELECT  ID
		  ,MVDID
		  ,MemberID
		  ,MemberFirstName
		  ,MemberLastName
		  ,[FormDate]
		  ,[FormAuthor]
		  ,CMCaseID
		  ,MaternityCaseID
		  ,ClinicalCaseID
		  ,ChronicCaseID
		  ,SWCaseID
		  ,[Version]
		  ,[PolicyEffectiveDate]
		  ,PolicyTerminationDate
		  ,[DateOfDeath]
		  ,[qGroup]
		  ,[SubscriberRelationship]
		  ,[qFormAuthor]
		  ,[ClaimsDollarsPaidToDate]
		  ,[PredictedHighCostClaimant]
		  ,[AnticipateHighCostClaimant]
		  ,CMCaseProgram
		  ,[CMDateIdentified]
		  ,[CMReferralSource]
		  ,[CMReferralReason]
		  ,MaternityCaseProgram
		  ,[MaternityDateIdentified]
		  ,[MaternityReferralSource]
		  ,[MaternityReferralReason]
		  ,ClinicalCaseProgram
		  ,[ClinicalSupportDateIdentified]
		  ,[ClinicalSupportReferralSource]
		  ,[ClinicalSupportReferralReason]
		  ,ChronicCaseProgram
		  ,[ChronicCondDateIdentified]
		  ,[ChronicCondReferralSource]
		  ,[ChronicCondReferralReason]
		  ,SWCaseProgram
		  ,[SWDateIdentified]
		  ,[SWReferralSource]
		  ,[SWReferralReason]
		  ,[ReferralCriteria]
		  ,[RiskLevel]
		  ,[RiskScore]
		  ,[PrimaryDiagDesc]
		  ,[DiagnosisEstablishedDate]
		  ,[BriefHistory]
		  ,[TreatmentPlan]
		  ,[AnticipatedTreatmentPlan]
		  ,[FacilityType]
		  ,[TreatmentLocation]
		  ,[Network]
		  ,[EducationalMaterials]
		  ,[TotalInboundSuccessfulCount]
		  ,[TotalOutboundSuccessfulCount]
		  ,[TotalInboundUnSuccessfulCount]
		  ,[TotalOutboundUnSuccessfulCount]
		  ,[GrandTotalContact]
		  ,[InboundSuccessfulDates]
		  ,[OutboundSuccessfulDates]
		  ,[InboundUnSuccessfulDates]
		  ,[OutboundUnSuccessfulDates]
		  ,[ClinicalIndicators]
		  ,[EvidenceBasedGuidelines]
		  ,[MedicationReconciliationDate]
		  ,[MedicationLists]
		  ,[DepressionScreningResults]
		  ,[DepressionScreeningCompleted]
		  ,[IncompleteCPGoals]
		  ,[TreatingPhysicians]
		  ,[MedicalDirectorConsultation]
		  ,[PharmacistConsultation]
		  ,[SocialWorkerConsultation]
		  ,[DietitianConsultation]
		  ,[SpecialtyCMConsultation]
		  ,[CaseManagementConsultation]
		  ,[TotalConsultations]
		  ,[IDTMeeting]
		  ,[CMRounds]
		  ,[CourtesyReview]
		  ,[MDFollowUp]
		  ,[PrePay]
		  ,[Appeals]
		  ,[OnSiteVisit]
		  ,[PeerToPeer]
		  ,[TotalMDActivity]
		  ,[GenMemQuestion]
		  ,[PharmacistCMRounds]
		  ,[PharmacistReferral]
		  ,[TotalPharmacistActivity]
		  ,[Intervention]
		  ,[WorkStatus]
		  ,[VendorProgramReferrals]
		  ,[Impact]
		  ,[Utilization]
		  ,[SpecialistTypes]
		  ,[IsLocked] 
		  ,[LastModifiedDate] 
	FROM #Final_MMO_Result
	ORDER BY MemberLastName, MemberFirstName asc
END

/****** Object:  StoredProcedure [dbo].[uspPopulateMonthlyMemberOverview]    Script Date: 2/5/2021 5:19:51 PM ******/
SET ANSI_NULLS ON