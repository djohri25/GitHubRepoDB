/****** Object:  Procedure [dbo].[uspCFR_LoadExcludedMVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_LoadExcludedMVDID] 
AS
/*

note:  This is part of the exclusion mechanism for the CareFlow Rules.  Each careflow rule is mapped
       to a number of these exclusions and will pull these MVDIDs to exclude from the workflow queue.
	   This procedure is run daily before the careflow rules are executed.

WHO		WHEN		WHAT
Scott	2021-07-22	Created to load the CFR_ExcludedMVDID table with all of the exclusions.
Scott	2021-09-22  Add OpportunityLetter exclusion (30) to restrict multiple org letters for 120 days.

EXEC uspCFR_LoadExcludedMVDID --(41 sec)(4:47)

SELECT * FROM CFR_Exclusion
SELECT * FROM CFR_Rule_Exclusion
SELECT * FROM CFR_ExcludedMVDID

SELECT COUNT(*) FROM CFR_ExcludedMVDID WHERE ExclusionID = 4

*/
BEGIN
	SET NOCOUNT ON;

PRINT OBJECT_NAME(@@PROCID)

DROP INDEX IF EXISTS IX_CFRExcludedMVDID_MVDIDExclusionID ON CFR_ExcludedMVDID

TRUNCATE TABLE CFR_ExcludedMVDID

DECLARE @iRows AS int = 0

LoadStandardExclusions:
	--(1) Standard/ActiveMMF
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 1 ExclusionID
      FROM ABCBS_MemberManagement_Form MMF
	 WHERE MMF.CaseProgram in ('case management', 'chronic condition management', 'maternity')
	   AND ISNULL(MMF.SectionCompleted,9) < 3

	--(2) Standard/Refused
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 2 ExclusionID
	  FROM ABCBS_MemberManagement_Form MMF
	 WHERE MMF.CaseProgram IN ('case management', 'chronic condition management', 'maternity')
	   AND (MMF.qNonViableReason1 = 'member/family refused case management' 
	        OR MMF.q2ConsentNonViable = 'member/family refused case management' 
	        OR MMF.qNoReason = 'member/family refused case management'
	        OR MMF.q8 = 'member/family refused case management'
	        OR MMF.q2CloseReason = 'member/family refused case management'
	        OR MMF.qNonViableReason1 = 'no CM needs' 
	        OR MMF.q2ConsentNonViable = 'no CM needs' 
	        OR MMF.qNoReason = 'no CM needs'
	        OR MMF.q8 = 'no CM needs'
	       )
	   AND DATEDIFF(day,MMF.FormDate, GETDATE()) < 121

	--(3) Standard/UTR
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 3 ExclusionID
	  FROM ABCBS_MemberManagement_Form MMF
     WHERE MMF.CaseProgram IN ('case management', 'chronic condition management', 'maternity')
	   AND (MMF.qNonViableReason1 = 'unable to reach member' 
		    OR MMF.q2ConsentNonViable = 'unable to reach member' 
		    OR MMF.qNoReason = 'unable to reach member'
		    OR MMF.q8 = 'unable to reach member'
		    )
	   AND DATEDIFF(day,MMF.FormDate, GETDATE()) < 121
	
	--(4) Standard/Expired
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 4 ExclusionID
      FROM ABCBS_MemberManagement_Form MMF
     WHERE (MMF.qNonViableReason1 = 'member expired' 
  	        OR MMF.q2ConsentNonViable = 'member expired' 
			OR MMF.qNoReason = 'member expired'
			OR MMF.q8 = 'member expired'
			OR MMF.q2CloseReason = 'member expired'
		   )

	--(5) Standard/Contact120
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 5 ExclusionID
      FROM ARBCBS_Contact_Form CF
	 WHERE DATEDIFF(day,CF.q1ContactDate, GETDATE()) < 121
	   AND q4ContactType IN ('Member','Caregiver')
	   AND q7ContactSuccess = 'Yes'
	   --AND q2program IN ('Case Management','Specialty Care','Maternity')
	   AND q2Program IN ('Case Management','Specialty Care','Maternity')
	                     --'HEP','Social Work','Clinical Support','Non-Clinical Support')

LoadCompanyExclusions:
  --(6) Company/Walmart
  --(7) Company/Tyson 
  --(8) Company/ASE 
  --(9) Company/PSE		
  ;WITH CompanyExclusion AS
		(
		SELECT MVDID, 
		       CASE WHEN CN.Company_Name LIKE 'Walmart%' THEN 6
			        WHEN Company_Name LIKE 'Tyson%' THEN 7
					WHEN Company_Name LIKE 'ASE%' THEN 8
                    WHEN Company_Name LIKE 'PSE%' THEN 9
				END AS ExclusionID
		  FROM FinalMember FM
		  JOIN LookupCompanyName CN ON FM.CompanyKey = CN.Company_Key
		 WHERE (Company_Name LIKE 'WALMART%'
				OR Company_Name LIKE 'TYSON%'
				OR Company_Name LIKE 'ASE%'
				OR Company_Name LIKE 'PSE%'
			   ) 
		)
        INSERT INTO CFR_ExcludedMVDID
		SELECT MVDID, ExclusionID
		  FROM CompanyExclusion

LoadUniversalExclusions:

	-- (10) Universal/Hourly
		INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
		SELECT DISTINCT fm.MVDID, 10
			FROM FinalMember fm
			JOIN Final.dbo.LookupGRP_CareFlowRule ue ON fm.CompanyKey = ue.Company_Key
			WHERE ue.Bill_Hourly_Ind = 'Y' 

	-- (11) Universal/NoBenefit			 
		INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
		SELECT DISTINCT fm.MVDID, 11
			FROM FinalMember fm
			JOIN Final.dbo.LookupGRP_CareFlowRule ue ON fm.CompanyKey = ue.Company_Key
			WHERE ue.Exclude_Careflow_Ind = 'Y'

LoadNonViableExclusions:
	--(12) NonViable/Refusal
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 12 ExclusionID
	  FROM ABCBS_MemberManagement_Form 
	 WHERE CaseProgram IN ('Case Management', 'Chronic Condition Management', 'Maternity')
	   AND qNonViableReason1 IN ('Member/Family Refused Case Management','No CM Needs')

	--(13) NonViable/UTR
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 13 ExclusionID
	  FROM ABCBS_MemberManagement_Form 
	 WHERE CaseProgram IN ('Case Management', 'Chronic Condition Management', 'Maternity')
	   AND qNonViableReason1 = 'Unable to Reach Member'

	--(14) NonViable/Expired
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 14 ExclusionID
	  FROM ABCBS_MemberManagement_Form 
	 WHERE CaseProgram IN ('Case Management', 'Chronic Condition Management', 'Maternity')
	   AND qNonViableReason1 = 'Member Expired'

	--(15) NonViable/Ineligible 
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 15 ExclusionID
	  FROM ABCBS_MemberManagement_Form 
	 WHERE CaseProgram IN ('Case Management', 'Chronic Condition Management', 'Maternity')
	   AND qNonViableReason1 = 'Member Ineligible for Policy Benefits/Policy Termed'

	--(16) NonViable/NonTrigger
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 16 ExclusionID
	  FROM ABCBS_MemberManagement_Form 
	 WHERE CaseProgram IN ('Case Management', 'Chronic Condition Management', 'Maternity')
	   AND qNonViableReason1 = 'Non-Trigger Diagnosis'

	--(17) NonViable/OtherIns
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 17 ExclusionID
	  FROM ABCBS_MemberManagement_Form 
	 WHERE CaseProgram IN ('Case Management', 'Chronic Condition Management', 'Maternity')
	   AND qNonViableReason1 = 'Other Insurance Primary'

	--(18) NonViable/ProDecision
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 18 ExclusionID
	  FROM ABCBS_MemberManagement_Form 
	 WHERE CaseProgram IN ('Case Management', 'Chronic Condition Management', 'Maternity')
	   AND qNonViableReason1 = 'Professional Decision'
 
	--(19) NonViable/WorkersComp
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 19 ExclusionID
	  FROM ABCBS_MemberManagement_Form 
	 WHERE CaseProgram IN ('Case Management', 'Chronic Condition Management', 'Maternity')
	   AND qNonViableReason1 = 'Workers Compensation/Work Related Injury'
 
 LoadGrandRoundsExclusion:
   --(20) GrandRounds/GRD
   --Members are included if they are != 'GRD'
   --They are excluded if they are 'GRD' unless they are Tyson.
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT fm.MVDID, 20
	  FROM FinalMember FM
	  JOIN LookupCompanyName CN ON FM.CompanyKey = CN.Company_Key
	 WHERE GrpInitvCd = 'GRD'
	   AND CN.Company_Name != 'Tyson'
 
 LoadPrimaryInsurance:
	--(21) PrimaryInsurance / COBCD
	--Members are included if they are (NULL,S,N,U)  They are NOT IN (NULL,S,N,U)
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT MVDID, 21 
	  FROM FinalMember FM 
	 WHERE ISNULL(FM.COBCD,'U') NOT IN ('S','N','U')

 LoadCaseExclusion:
 	--(22) Case/Manager30
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT MVDID, 22 AS ExclusionID
	  FROM Final_MemberOwner
	 WHERE ISNULL(IsDeactivated,0) = 0 
	   AND OwnerType = 'Primary'

   --(23) Case/Referral30
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT MVDID, 23 AS ExclusionID
	  FROM ABCBS_MemberManagement_Form 
	 WHERE DATEDIFF(dd,FormDate,GETDATE()) < 31 
	   AND ISNULL(ReferralID,'') != '' 
	   --AND DATEDIFF(dd,ReferralDate,GETDATE()) < 30 
	   AND CaseProgram IN ('Case Management', 'Chronic Condition Management', 'Maternity')

	--(24) Case/Closed30	
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT MVDID, 24 AS ExclusionID
 	  FROM ABCBS_MemberManagement_Form MMF
     WHERE qCloseCase = 'Yes'
	   AND DATEDIFF(dd,q1CaseCloseDate,GETDATE()) <= 30
	   AND CaseProgram IN ('Case Management', 'Chronic Condition Management', 'Maternity')

LoadComorbid:

	 --(25) CoMorbid/Comorbid
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 25 as ExclusionID
  	  FROM [dbo].[ElixMemberRisk] EX
	 WHERE EX.GroupID in (1,2,5,9,19) 

EligibleExclusion:
    --(26) Admin/Eligibility
    --Members are not currently eligibile
	--all members
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT MVDID, 26 ExclusionID 
	  FROM FinalEligibility 
	EXCEPT  --eligible members
	SELECT MVDID, 26 ExclusionID FROM FinalEligibility 
	 WHERE GETDATE() BETWEEN MemberEffectiveDate AND MemberTerminationDate

NewExpandedContact:
	--(27) Standard/Contact120
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 27 ExclusionID
      FROM ARBCBS_Contact_Form CF
	 WHERE DATEDIFF(day,CF.q1ContactDate, GETDATE()) < 121
	   AND q4ContactType IN ('Member','Caregiver')
	   AND q7ContactSuccess = 'Yes'
	   AND q2program IN ('Case Management','Specialty Care','Maternity','HEP','Social Work','Clinical Support','Non-Clinical Support')

SUDCancer:
	--(28) SUD/Cancer
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT DISTINCT MVDID, 28 ExxclusionID
  	  FROM [dbo].[ElixMemberRisk] EX
	 WHERE EX.GroupID = 19

SUDNewDirections:
	--(29) SUD/NewDirections
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
    SELECT DISTINCT MVDID, 29 ExclusionID 
	  FROM ABCBS_ReferraltoNewDirections_Form NDBH
	 WHERE DATEDIFF(day,NDBH.FormDate, GETDATE()) < 91

OpportunityLetters:
	--(30) HighCost/Opportunity  --these members will not receive another letter for 120 days.
	;WITH OpportunityMembers AS
	(SELECT DISTINCT MVDID, MAX(CreatedDate) CreatedDate 
       FROM LetterMembers 
      WHERE LetterType IN (3,4) 
        AND LetterFlag = 'SB'
      GROUP BY MVDID 
	)
	INSERT INTO CFR_ExcludedMVDID (MVDID, ExclusionID)
	SELECT MVDID, 30 ExclusionID 
	  FROM OpportunityMembers
	 WHERE DATEDIFF(dd,CreatedDate,GETDATE()) <= 120

BuildIndex:

	CREATE INDEX IX_CFRExcludedMVDID_MVDIDExclusionID ON CFR_ExcludedMVDID (MVDID,ExclusionID)

END