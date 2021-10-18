/****** Object:  Procedure [dbo].[uspPopulateMonthlyMemberOverview]    Committed by VersionSQL https://www.versionsql.com ******/

/* =============================================
Author:	Deepank Johri
Create date: 11-02-2020
Description:	Populate Monthly Member Overview Form with a comma seperated list
Example: EXEC dbo.uspPopulateMonthlyMemberOverview @StartDate='1900-01-01',@MVDID='1623283534B288581F0D'

Modifications
Date				Name					Comments	
11/16/2020		Sunil Nokku				Avoid null CaseID
11/20/2020		Sunil,Deepank,Jose		Group Case related data into json value
11/30/2020		Sunil Nokku				Get YTD date
12/02/2020		Sunil Nokku				Modified PredictedHighCostClaimant
12/02/2020		Deepank Johri			Modified LastMedicationReconciliationDate,MedicationList
12/02/2020      Deepank Johri			Modified to return default values for all MVDID's 
12/02/2020      Deepank Johri			Modified to consider Active Consult/Interdisciplinary forms
12/02/2020      Deepank Johri			Modified PredictiedHighCostClaimant to consider latest prediction from DataScience Team
12/03/2020 		Sunil Nokku		Removed IsLocked condition when getting CaseInfo as there is no IsLocked column.
12/03/2020		Sunil Nokku				Modified CaseInfo logic to include CaseCloseDate condition
12/04/2020		Sunil Nokku				Modified FormAuthor to include Name
12/04/2020		Sunil Nokku				Modified Relationship 
12/21/2020		Sunil Nokku				Add qFormAuthor and qFormAuthorFullName
12/21/2020		Sunil Nokku				Modified VendorProgramReferrals
12/22/2020		Sunil Nokku				Modified MedicationList
12/29/2020		Sunil Nokku				TFS 4212
01/05/2021		Sunil Nokku				Fix EffDate and TermDate
01/05/2021		Sunil Nokku				Modified to pickup Active Consult forms
01/12/2021		Sunil Nokku				TFS 4243
20210525		Jose					Added hint (readuncommitted) to mising places
============================================= */
CREATE PROCEDURE [dbo].[uspPopulateMonthlyMemberOverview]
@StartDate date = null
,@MVDID varchar(30)
AS
BEGIN

SET NOCOUNT ON;

--exec uspPopulateMonthlyMemberOverview @MVDID=N'16D398311439F973CDDD'

----For testing purposes
--DECLARE 
--	@StartDate date = null,
--	@MVDID varchar(30) = '16D398311439F973CDDD'

DECLARE @v_StartDate datetime

SET @v_StartDate = DATEFROMPARTS(YEAR(GETDATE()), 1, 1) --First Day of Current Year
--SELECT @v_StartDate

SELECT * 
FROM (
	SELECT DISTINCT
		m.MVDID,
		m.MemberID,
		(SELECT 
			MAX(MemberEffectiveDate)  
			FROM FinalEligibility (readuncommitted)
			WHERE mvdid = m.MVDID
			GROUP BY mvdid) AS PolicyEffectiveDate,
		(SELECT 
			MAX(MemberTerminationDate) 
			FROM FinalEligibility (readuncommitted) 
			WHERE mvdid = m.MVDID
			GROUP BY mvdid) AS PolicyTerminationDate,
		--FIRST_VALUE (e.MemberEffectiveDate) OVER (PARTITION BY e.MVDID ORDER BY e.RecordID DESC) AS PolicyEffectiveDate,
		--FIRST_VALUE (e.MemberTerminationDate) OVER (PARTITION BY e.MVDID ORDER BY e.RecordID DESC) AS PolicyTerminationDate,
		ccq.CompanyName AS qGroup,
		case when r.mbr_rel_val3_name = 'SUBSCRIBER' THEN 'EE'
			ELSE r.mbr_rel_val3_name
			END AS SubscriberRelationship,
		mmo.FormAuthor AS qFormAuthor,
		CASE WHEN CONCAT(u.FirstName,' ',u.LastName)=' ' THEN u.UserName 
			ELSE CONCAT(u.FirstName,' ',u.LastName) 
			END as qFormAuthorFullName,
		STUFF((
			SELECT DISTINCT ','+ convert(varchar,sum(ch.TotalPaidAmount)) 
			FROM FinalClaimsHeader ch (READUNCOMMITTED)
			WHERE 
				ch.mvdid=m.MVDID 
				AND convert(date,ch.statementfromdate) between @v_StartDate and Getdate()
			FOR XML PATH('')),1,1,'') AS ClaimsDollarsPaidToDate,
		(SELECT DISTINCT
			--distinct t.partykey, t.is_top10pct_predicted, t.is_recurring, fm.mvdid, 
			--CASE WHEN t.is_top10pct_predicted =1 and t.is_recurring =1 THEN 'Yes' ELSE 'No' END 
			FIRST_VALUE (CASE WHEN t.is_top10pct_predicted =1 and t.is_recurring =1 THEN 'Yes' ELSE 'No' END ) OVER (
				PARTITION BY t.PartyKey 
				ORDER BY t.Prediction_Date DESC)
			FROM tags_for_high_risk_members t  (readuncommitted)
				INNER JOIN finalmember fm (readuncommitted) on fm.partykey = t.partykey
			WHERE fm.MVDID = m.MVDID) AS PredictedHighCostClaimant,
		--CASE WHEN cmtp.HighDollarClaim = 1 THEN 'Yes' WHEN cmtp.HighDollarClaim = 0 THEN 'No' END AS PredictedHighCostClaimant,
		(SELECT mmf.CaseID, mmf.q1casecreatedate AS CaseCreatedDate, mmf.caseprogram, mmf.referralreason, mmf.referralsource
			FROM abcbs_membermanagement_form mmf  (readuncommitted)
			WHERE 
				mmf.mvdid=m.MVDID 
				AND LEN(mmf.CaseID) > 1 -- Added to avoid null CaseID
				AND mmf.sectioncompleted < =3
				AND ISNULL(qCloseCase,'') <> 'Yes'
				AND ISNULL(CAST(q1CaseCloseDate AS varchar(100)),'') <> '1900-01-01 00:00:00.000'
				--AND islocked = 'No'
				for json auto) AS CaseJson,
		CASE WHEN ccq.RiskGroupID BETWEEN 1 AND 4 THEN 'Low'
			WHEN ccq.RiskGroupID BETWEEN 5 AND 7 THEN 'Medium'
			WHEN ccq.RiskGroupID BETWEEN 8 AND 10 THEN 'High'
			END AS 'RiskLevel',
			ccq.RiskGroupID AS 'RiskScore',
		(SELECT DISTINCT TOP 1 mr.ReconDateTime 
			FROM dbo.MainMedRec mr (READUNCOMMITTED)
			where mr.mvdid=m.MVDID
			ORDER BY mr.ReconDateTime DESC) AS LastMedicationReconciliationDate,
	--stuff((
	--    SELECT DISTINCT CAST(',' AS varchar(max)) + CONVERT(varchar(30) , FIRST_VALUE (mr.ReconDateTime) OVER (PARTITION BY mr.SessionID ORDER BY mr.ID DESC),20)
	--    FROM dbo.MainMedRec mr
	--    where mr.mvdid=m.MVDID
	--    FOR XML PATH('')
	--    ), 1, 1, '') AS LastMedicationReconciliationDate,
	--stuff((
	--    SELECT DISTINCT ',' + cast(FIRST_VALUE (mr.NDC) OVER (PARTITION BY mr.ReconDateTime  ORDER BY mr.ReconDateTime DESC) as varchar(max))
	--    FROM dbo.MainMedRec mr 
	--    where mr.mvdid=m.MVDID
	--    FOR XML PATH('')
	--    ), 1, 1, '') AS MedicationList,

		stuff((
			SELECT DISTINCT ',' + cast((mr.NDC) as varchar(max))
			FROM dbo.MainMedRec mr (readuncommitted) 
			where 
				mr.mvdid=m.MVDID
				and mr.ReconDateTime = (
					select top 1 ReconDateTime 
					FROM dbo.MainMedRec mr (readuncommitted) 
					where mr.mvdid=m.MVDID 
					order by ReconDateTime desc )
			FOR XML PATH('')), 1, 1, '') AS MedicationList,
		stuff((
			SELECT DISTINCT ', ' + cast(CPP.problemfreetext as varchar(max))
			FROM dbo.MainCarePlanMemberIndex CPI (readuncommitted)
				LEFT OUTER JOIN dbo.MainCarePlanMemberProblems CPP (readuncommitted) ON CPP.[CarePlanID] = CPI.[CarePlanID]
				LEFT OUTER JOIN dbo.MainCarePlanMemberGoals CPG (readuncommitted) ON CPG.[GoalNum] = CPP.[problemNum]
			where 
				cpi.mvdid=m.MVDID
				and completedate is null
			FOR XML PATH('')), 1, 1, '') AS IncompleteCPGoals
	FROM
		--FinalEligibilityETL e (READUNCOMMITTED)
		--LEFT JOIN 
		FinalMember m (READUNCOMMITTED)
		--ON m.MVDID = e. MVDID
		LEFT JOIN FinalClaimsHeader ch (READUNCOMMITTED)
			ON m.MVDID = ch. MVDID
		LEFT JOIN LookupMemberRelationship r (READUNCOMMITTED)
			ON 
				--r.[data_source_val] = m.[Relationship]
				CASE WHEN LEN(r.[data_source_val]) < 2 
					THEN CONCAT('0',r.[data_source_val]) 
					ELSE r.[data_source_val] END = m.[Relationship]
					AND r.[data_source] = m.[datasource]
					AND r.mbr_rel_val3_name NOT LIKE 'UNKNOWN%'
					AND r.mbr_rel_val3_name NOT LIKE 'INVALID%'
		LEFT JOIN ComputedCareQueue ccq (READUNCOMMITTED)
			ON ccq.MVDID = m.MVDID
		LEFT JOIN MainMedRec mr (READUNCOMMITTED)
			ON mr.MVDID = m.MVDID
		LEFT JOIN abcbs_membermanagement_form mmf (READUNCOMMITTED)
			ON mmf.MVDID = m.MVDID
		LEFT JOIN ABCBS_MonthlyMemberOverview_Form mmo (READUNCOMMITTED)
			ON mmo.MVDID = m.MVDID
		LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 cmtp (READUNCOMMITTED)
			ON cmtp.MVDID = m.MVDID
		LEFT JOIN AspNetUsers u (readuncommitted) 
			ON u.UserName = mmo.qFormAuthor
	WHERE
		m.MVDID = @MVDID
	GROUP BY 
		m.MVDID,
		m.MemberID,
	--e.MemberEffectiveDate,e.MemberTerminationDate,e.MVDID,e.RecordID,
		ccq.CompanyName,
		r.mbr_rel_val3_name,
		mmo.FormAuthor,
		ccq.RiskGroupID,
		mr.ReconDateTime,
		mr.SessionID,
		mr.ID,
		mr.NDC,
		mmf.q1CaseCreateDate,
		mmf.ReferralSource,
		mmf.ReferralReason,
		cmtp.HighDollarClaim,
		u.UserName,
		u.FirstName,
		u.LastName
	) a
OUTER APPLY (
	SELECT DISTINCT * 
	FROM (
		SELECT 
			STUFF((SELECT DISTINCT  ','+  (CASE WHEN cf.q3contacttype = 'Inbound' AND cf.q7ContactSuccess = 'Yes' THEN CAST(COUNT(1) AS VARCHAR)END) AS TotalInboundSuccessfulCount
				FROM ARBCBS_Contact_Form cf (readuncommitted)
				WHERE 
					cf.MVDID=a.MVDID 
					and (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
					and q1ContactDate between @v_StartDate and GETDATE()  
				GROUP BY 
					cf.q3contacttype,
					cf.q7ContactSuccess
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS TotalInboundSuccessfulCount,
			STUFF((SELECT DISTINCT  ','+  (CASE WHEN cf.q3contacttype = 'Outbound' AND cf.q7ContactSuccess = 'Yes' THEN CAST(COUNT(1) AS VARCHAR)END) AS TotalOutboundSuccessfulCount
				FROM ARBCBS_Contact_Form cf (readuncommitted)
				WHERE 
					cf.MVDID=a.MVDID 
					and (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
					and q1ContactDate between @v_StartDate and GETDATE()          
				GROUP BY 
					cf.q3contacttype,
					cf.q7ContactSuccess
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS TotalOutboundSuccessfulCount,
			STUFF((SELECT DISTINCT  ','+  (CASE WHEN cf.q3contacttype = 'Inbound' AND cf.q7ContactSuccess = 'No' THEN CAST(COUNT(1) AS VARCHAR)END) AS TotalInboundUnSuccessfulCount
				FROM ARBCBS_Contact_Form cf (readuncommitted)
				WHERE 
					cf.MVDID=a.MVDID 
					and (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
					and q1ContactDate between @v_StartDate and GETDATE()
				GROUP BY 
					cf.q3contacttype,
					cf.q7ContactSuccess
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS TotalInboundUnSuccessfulCount,  
			STUFF((SELECT DISTINCT ','+  (CASE WHEN cf.q3contacttype = 'Outbound' AND cf.q7ContactSuccess = 'No' THEN CAST(COUNT(1) AS VARCHAR)END) AS TotalOutboundUnSuccessfulCount
				FROM ARBCBS_Contact_Form cf (readuncommitted)
				WHERE 
					cf.MVDID=a.MVDID 
					and (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
					and q1ContactDate between @v_StartDate and GETDATE() 
				GROUP BY 
					cf.q3contacttype,
					cf.q7ContactSuccess
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS TotalOutboundUnSuccessfulCount,
			GrandTotalContact = (
				SELECT Sum(isnull(cast(1 as int),0)) as Total
				FROM ARBCBS_Contact_Form cf (READUNCOMMITTED)
				WHERE 
					MVDID = a.MVDID  
					AND q1ContactDate BETWEEN @v_StartDate and GETDATE()
					AND (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
					AND cf.q3contacttype IN ('Inbound', 'Outbound') AND cf.q7ContactSuccess IN ('Yes','No'))  
		FROM ARBCBS_Contact_Form cf (READUNCOMMITTED)
		WHERE 
			cf.MVDID = a.MVDID 
			AND (cf.q4contacttype = 'Member' OR cf.q4contacttype = 'Caregiver')
			AND cf.q1ContactDate BETWEEN @v_StartDate and GETDATE()
		GROUP BY 
			cf.q3contacttype,
			cf.q7ContactSuccess
		) b
	) m
OUTER APPLY (
	SELECT DISTINCT * 
	FROM (
		SELECT 
			STUFF((SELECT DISTINCT  ','+  (CASE WHEN q3contacttype = 'Inbound' AND q7ContactSuccess = 'Yes' THEN convert(varchar(50),acf.q1ContactDate,101) END) 
				FROM ARBCBS_Contact_Form acf (readuncommitted)
				WHERE 
					acf.MVDID=a.MVDID 
					and (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
					and q1ContactDate between @v_StartDate and GETDATE()               
					FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS InboundSuccessfulDates,
			STUFF((SELECT DISTINCT  ','+  (CASE WHEN q3contacttype = 'Outbound' AND q7ContactSuccess = 'Yes' THEN convert(varchar(50),acf.q1ContactDate,101) END)
				FROM ARBCBS_Contact_Form acf (readuncommitted)
				WHERE 
					acf.MVDID=a.MVDID  
					and (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
					and q1ContactDate between @v_StartDate and GETDATE()               
					FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS OutboundSuccessfulDates,
			STUFF((SELECT DISTINCT  ','+  (CASE WHEN q3contacttype = 'Inbound' AND q7ContactSuccess = 'No' THEN convert(varchar(50),acf.q1ContactDate,101) END)
				FROM ARBCBS_Contact_Form acf (readuncommitted)
				WHERE 
					acf.MVDID=a.MVDID 
					and (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
					and q1ContactDate between @v_StartDate and GETDATE()               
					FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS InboundUnSuccessfulDates,
			STUFF((SELECT DISTINCT ','+  (CASE WHEN q3contacttype = 'Outbound' AND q7ContactSuccess = 'No' THEN convert(varchar(50),acf.q1ContactDate,101) END)
				FROM ARBCBS_Contact_Form acf  (readuncommitted)
				WHERE 
					acf.MVDID=a.MVDID  
					and (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
					and q1ContactDate between @v_StartDate and GETDATE()               
					FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS OutboundUnSuccessfulDates
		)c
	) n
OUTER APPLY (
--SELECT DISTINCT * FROM (
--SELECT STUFF((SELECT DISTINCT  ',' + CAST(count(q110VendorsDiscussed1)AS VARCHAR) as totalvpr
--               FROM ARBCBS_Contact_Form cd
--               WHERE cd.MVDID=a.MVDID 
--               and (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
--               and q9vendorsdiscussed= 'Yes' and q7ContactSuccess = 'Yes'
--               and q1ContactDate between @v_StartDate and GETDATE()  
--               GROUP BY cd.q3contacttype,cd.q7ContactSuccess
--               FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS 'VendorProgramReferrals'
--        FROM ARBCBS_Contact_Form cf (READUNCOMMITTED)
--        WHERE cf.MVDID = a.MVDID AND (cf.q4contacttype = 'Member' OR cf.q4contacttype = 'Caregiver')
--        AND cf.q1ContactDate BETWEEN @v_StartDate and GETDATE()
--        GROUP BY cf.q3contacttype,cf.q7ContactSuccess
	SELECT DISTINCT * 
	FROM (
		SELECT 
			STUFF((SELECT DISTINCT  ',' + CAST(COUNT(1)AS VARCHAR) as totalvpr
				FROM ARBCBS_Contact_Form cd (readuncommitted)
				WHERE 
					cd.MVDID = a.MVDID 
					and (q4contacttype = 'Member' OR q4contacttype = 'Caregiver')
					and q9vendorsdiscussed= 'Yes' and q7ContactSuccess = 'Yes'
					and q1ContactDate between @v_StartDate and GETDATE()  
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS 'VendorProgramReferrals'
		FROM ARBCBS_Contact_Form cf (READUNCOMMITTED)
		WHERE 
			cf.MVDID = a.MVDID 
			AND (cf.q4contacttype = 'Member' OR cf.q4contacttype = 'Caregiver')
			AND cf.q1ContactDate BETWEEN @v_StartDate and GETDATE()
		) d
	) f
OUTER APPLY (
	SELECT DISTINCT * 
	FROM (
		SELECT 
			STUFF((SELECT ','+  (CASE WHEN cf.q20ConsultType = 'Medical Director' THEN CAST(COUNT(1) AS VARCHAR)END) AS MedicalDirectorConsultation
				FROM Consult_Form cf (readuncommitted)
				WHERE 
					cf.MVDID=a.MVDID  
					AND cf.q1ConsultDate between @v_StartDate and GETDATE()  
					AND cf.SectionCompleted = 1
				GROUP BY 
					cf.q20ConsultType
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS MedicalDirectorConsultation,
			STUFF((SELECT ','+  (CASE WHEN cf.q20ConsultType = 'Pharmacist' THEN CAST(COUNT(1) AS VARCHAR)END) AS PharmacistConsultation
				FROM Consult_Form cf (readuncommitted)
				WHERE 
					cf.MVDID=a.MVDID 
					AND cf.q1ConsultDate between @v_StartDate and GETDATE()  
				GROUP BY 
					cf.q20ConsultType
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS PharmacistConsultation,
			STUFF((SELECT ','+  (CASE WHEN cf.q20ConsultType = 'Social Worker' THEN CAST(COUNT(1) AS VARCHAR)END) AS SocialWorkerConsultation
				FROM Consult_Form cf (readuncommitted)
				WHERE 
					cf.MVDID=a.MVDID 
					AND cf.q1ConsultDate between @v_StartDate and GETDATE()  
					AND SectionCompleted = 1
				GROUP BY 
					cf.q20ConsultType
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS SocialWorkerConsultation,
			STUFF((SELECT ','+  (CASE WHEN cf.q20ConsultType = 'Dietitian' THEN CAST(COUNT(1) AS VARCHAR)END) AS DietitianConsultation
				FROM Consult_Form cf (readuncommitted)
				WHERE 
					cf.MVDID=a.MVDID 
					AND cf.q1ConsultDate between @v_StartDate and GETDATE()  
					AND SectionCompleted = 1
				GROUP BY 
					cf.q20ConsultType
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS DietitianConsultation,
			STUFF((SELECT ','+  (CASE WHEN cf.q20ConsultType = 'Specialty CM' THEN CAST(COUNT(1) AS VARCHAR)END) AS SpecialtyCMConsultation
				FROM Consult_Form cf (readuncommitted)
				WHERE 
					cf.MVDID=a.MVDID  
					AND cf.q1ConsultDate between @v_StartDate and GETDATE()  
					AND SectionCompleted = 1
				GROUP BY 
					cf.q20ConsultType
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS SpecialtyCMConsultation,
			STUFF((SELECT ','+  (CASE WHEN cf.q20ConsultType = 'Case Management' THEN CAST(COUNT(1) AS VARCHAR)END) AS CaseManagementConsultation
				FROM Consult_Form cf (readuncommitted)
				WHERE 
					cf.MVDID=a.MVDID 
					AND cf.q1ConsultDate between @v_StartDate and GETDATE()  
					AND SectionCompleted = 1
				GROUP BY 
					cf.q20ConsultType
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS CaseManagementConsultation,
			TotalConsultation = (
				SELECT
					Sum(isnull(cast(1 as int),0)) as Total
				FROM Consult_Form cf (READUNCOMMITTED) 
				WHERE 
					cf.MVDID = a.MVDID 
					AND q1ConsultDate BETWEEN @v_StartDate and GETDATE()
					AND SectionCompleted = 1
					AND q20ConsultType IN ('Medical Director','Pharmacist','Social Worker','Dietitian','Specialty','Case Management')
					--GROUP BY cf.ID  /*	TFS 4212	*/
				)          
		FROM Consult_Form cf (READUNCOMMITTED)
		WHERE 
			cf.MVDID = a.MVDID 
			AND cf.q1ConsultDate BETWEEN @v_StartDate and GETDATE()
			AND SectionCompleted = 1
		GROUP BY 
			cf.q20ConsultType
		)g
	) h
OUTER APPLY (
	SELECT DISTINCT * 
	FROM (
		SELECT 
			STUFF((SELECT ','+  (CASE WHEN idf.qdiscipline = 'Medical Director' AND qMeetingType = 'Interdisciplinary Team Meeting' THEN CAST(COUNT(1) AS VARCHAR)END) AS IDTMeeting
				FROM ABCBS_InterdisciplinaryTeam_Form idf (readuncommitted)
					INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
						ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
							AND hpan_cf.LinkedFormID = idf.ID
							AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
				WHERE 
					idf.MVDID=a.MVDID  
					and idf.FormDate between @v_StartDate and GETDATE()  
				GROUP BY 
					idf.qdiscipline,idf.qMeetingType
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS IDTMeeting,
			STUFF((SELECT ','+  (CASE WHEN idf.qdiscipline = 'Medical Director' AND qMeetingType = 'Care Management Rounds' THEN CAST(COUNT(1) AS VARCHAR)END) AS CMRounds
				FROM ABCBS_InterdisciplinaryTeam_Form idf (readuncommitted)
					INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
						ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
							AND hpan_cf.LinkedFormID = idf.ID
							AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
				WHERE 
					idf.MVDID=a.MVDID 
					and idf.FormDate between @v_StartDate and GETDATE()  
				GROUP BY 
					idf.qdiscipline,idf.qMeetingType
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS CMRounds,
			STUFF((SELECT ','+  (CASE WHEN idf.qdiscipline = 'Medical Director' AND qMeetingType = 'Courtesy Review' THEN CAST(COUNT(1) AS VARCHAR)END) AS CourtesyReview
				FROM ABCBS_InterdisciplinaryTeam_Form idf (readuncommitted)
					INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
						ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
							AND hpan_cf.LinkedFormID = idf.ID
							AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
				WHERE 
					idf.MVDID=a.MVDID  
					and idf.FormDate between @v_StartDate and GETDATE()  
				GROUP BY 
					idf.qdiscipline,
					idf.qMeetingType
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS CourtesyReview,
			STUFF((SELECT ','+  (CASE WHEN idf.qdiscipline = 'Medical Director' AND qMeetingType = 'Medical Director Follow-Up' THEN CAST(COUNT(1) AS VARCHAR)END) AS MDFollowUp
					FROM ABCBS_InterdisciplinaryTeam_Form idf (readuncommitted)
						INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
							ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
								AND hpan_cf.LinkedFormID = idf.ID
								AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
					WHERE 
						idf.MVDID=a.MVDID  
						and idf.FormDate between @v_StartDate and GETDATE()  
					GROUP BY 
						idf.qdiscipline,
						idf.qMeetingType
					FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS MDFollowUp,
			STUFF((SELECT ','+  (CASE WHEN idf.qdiscipline = 'Medical Director' AND qMeetingType = 'Prepay' THEN CAST(COUNT(1) AS VARCHAR)END) AS PrePay
					FROM ABCBS_InterdisciplinaryTeam_Form idf (readuncommitted)
						INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
							ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
								AND hpan_cf.LinkedFormID = idf.ID
								AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
					WHERE 
						idf.MVDID=a.MVDID
						and idf.FormDate between @v_StartDate and GETDATE()  
					GROUP BY 
						idf.qdiscipline,
						idf.qMeetingType
					FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS PrePay,
			STUFF((SELECT ','+  (CASE WHEN idf.qdiscipline = 'Medical Director' AND qMeetingType = 'Appeals' THEN CAST(COUNT(1) AS VARCHAR)END) AS Appeals
					FROM ABCBS_InterdisciplinaryTeam_Form idf (readuncommitted)
						INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
							ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
								AND hpan_cf.LinkedFormID = idf.ID
								AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
					WHERE 
						idf.MVDID=a.MVDID 
						and idf.FormDate between @v_StartDate and GETDATE()  
					GROUP BY 
						idf.qdiscipline,
						idf.qMeetingType
					FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS Appeals,
			STUFF((SELECT ','+  (CASE WHEN idf.qdiscipline = 'Medical Director' AND qMeetingType = 'Onsite Visit' THEN CAST(COUNT(1) AS VARCHAR)END) AS OnSiteVisit
					FROM ABCBS_InterdisciplinaryTeam_Form idf (readuncommitted)
						INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
							ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
								AND hpan_cf.LinkedFormID = idf.ID
								AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
					WHERE 
						idf.MVDID=a.MVDID  
						and idf.FormDate between @v_StartDate and GETDATE()  
					GROUP BY 
						idf.qdiscipline,
						idf.qMeetingType
					FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS OnSiteVisit,
			STUFF((SELECT ','+  (CASE WHEN idf.qdiscipline = 'Medical Director' AND qMeetingType = 'Peer to Peer' THEN CAST(COUNT(1) AS VARCHAR)END) AS PeerToPeer
					FROM ABCBS_InterdisciplinaryTeam_Form idf (readuncommitted)
						INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
							ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
								AND hpan_cf.LinkedFormID = idf.ID
								AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
					WHERE 
						idf.MVDID=a.MVDID
						and idf.FormDate between @v_StartDate and GETDATE()  
					GROUP BY 
						idf.qdiscipline,
						idf.qMeetingType
					FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS PeerToPeer,
			TotalMDActivity = (
				SELECT Sum(isnull(cast(1 as int),0)) as Total
				FROM ABCBS_InterdisciplinaryTeam_Form idf (READUNCOMMITTED)
					INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
						ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
							AND hpan_cf.LinkedFormID = idf.ID
							AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
				WHERE 
					idf.MVDID = a.MVDID  
					AND FormDate BETWEEN @v_StartDate and GETDATE()
					AND qdiscipline = 'Medical Director' AND 
					qMeetingType IN ('Interdisciplinary Team Meeting','Care Management Rounds','Courtesy Review','Medical Director Follow-Up','Prepay','Appeals','Onsite Visit','Peer to Peer')
					)
		FROM ABCBS_InterdisciplinaryTeam_Form idf (READUNCOMMITTED)
			INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
				ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
					AND hpan_cf.LinkedFormID = idf.ID
					AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
		WHERE 
			idf.MVDID = a.MVDID
			AND idf.FormDate BETWEEN @v_StartDate and GETDATE()
		GROUP BY 
			idf.qdiscipline,
			idf.qMeetingType
		) i
	) j
OUTER APPLY (
	SELECT DISTINCT * 
	FROM (
		SELECT 
			STUFF((SELECT ','+  (CASE WHEN idf.qdiscipline = 'Pharmacy' AND qContactType = 'General Member Question' THEN CAST(COUNT(1) AS VARCHAR)END) AS GenMemQuestion
				FROM ABCBS_InterdisciplinaryTeam_Form idf (readuncommitted)
					INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
						ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
							AND hpan_cf.LinkedFormID = idf.ID
							AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
				WHERE 
					idf.MVDID=a.MVDID  
					and idf.FormDate between @v_StartDate and GETDATE()  
				GROUP BY 
					idf.qdiscipline,
					idf.qContactType
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS GenMemQuestion,
			STUFF((SELECT ','+  (CASE WHEN idf.qdiscipline = 'Pharmacy' AND qContactType = 'Care Management Rounds' THEN CAST(COUNT(1) AS VARCHAR)END) AS PharmacistCMRounds
				FROM ABCBS_InterdisciplinaryTeam_Form idf (readuncommitted)
					INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
						ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
							AND hpan_cf.LinkedFormID = idf.ID
							AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
				WHERE 
					idf.MVDID=a.MVDID  
					and idf.FormDate between @v_StartDate and GETDATE()  
				GROUP BY 
					idf.qdiscipline,
					idf.qContactType
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS PharmacistCMRounds,
			STUFF((SELECT ','+  (CASE WHEN idf.qdiscipline = 'Pharmacy' AND qContactType = 'Pharmacist Referral' THEN CAST(COUNT(1) AS VARCHAR)END) AS PharmacistReferral
				FROM ABCBS_InterdisciplinaryTeam_Form idf (readuncommitted)
					INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
						ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
							AND hpan_cf.LinkedFormID = idf.ID
							AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
				WHERE 
					idf.MVDID=a.MVDID  
					and idf.FormDate between @v_StartDate and GETDATE()  
				GROUP BY 
					idf.qdiscipline,
					idf.qContactType
				FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS PharmacistReferral,
			TotalPharmacistActivity = (
				SELECT
					Sum(isnull(cast(1 as int),0)) as Total
				FROM ABCBS_InterdisciplinaryTeam_Form idf (READUNCOMMITTED)
					INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
						ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
							AND hpan_cf.LinkedFormID = idf.ID
							AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
				WHERE 
					idf.MVDID = a.MVDID  
					AND FormDate BETWEEN @v_StartDate and GETDATE()
					AND qdiscipline = 'Pharmacy' AND 
					qContactType IN ('General Member Question','Care Management Rounds','Pharmacist Referral')
				)          
		FROM ABCBS_InterdisciplinaryTeam_Form idf (READUNCOMMITTED)
			INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
				ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
					AND hpan_cf.LinkedFormID = idf.ID
					AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
		WHERE 
			idf.MVDID = a.MVDID  
			AND idf.FormDate BETWEEN @v_StartDate and GETDATE()
		GROUP BY 
			idf.qdiscipline,
			idf.qContactType
		) k
	)l
OUTER APPLY (
	SELECT DISTINCT * 
	FROM (
		SELECT 
			STUFF((SELECT ','+  (CASE WHEN idf.qdiscipline = 'Social Work' THEN CAST(COUNT(1) AS VARCHAR)END) AS Intervention
			FROM ABCBS_InterdisciplinaryTeam_Form idf (readuncommitted)
					INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
						ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
							AND hpan_cf.LinkedFormID = idf.ID
							AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
		WHERE 
			idf.MVDID=a.MVDID  
			and idf.FormDate between @v_StartDate and GETDATE()  
		GROUP BY 
			idf.qdiscipline,
			idf.qContactType
		FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS Intervention        
		FROM ABCBS_InterdisciplinaryTeam_Form idf (READUNCOMMITTED)
			INNER JOIN HPAlertNote hpan_cf (READUNCOMMITTED)
				ON hpan_cf.LinkedFormType = 'ABCBS_InterdisciplinaryTeam'
					AND hpan_cf.LinkedFormID = idf.ID
					AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
		WHERE 
			idf.MVDID = a.MVDID  
			AND idf.FormDate BETWEEN @v_StartDate and GETDATE()
		GROUP BY 
			idf.qdiscipline,
			idf.qContactType
		) m
	) o

END