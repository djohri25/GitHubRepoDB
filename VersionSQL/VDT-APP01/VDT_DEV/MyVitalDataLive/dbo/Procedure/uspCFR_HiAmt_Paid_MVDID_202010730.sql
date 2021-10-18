/****** Object:  Procedure [dbo].[uspCFR_HiAmt_Paid_MVDID_202010730]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HiAmt_Paid_MVDID] 
AS
/*
    CustID:  16
    RuleID:  219
 ProductID:  2
OwnerGroup:  159

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	Created by refactor of original to call uspCFR_Merge
Scott	2020-11-21	Applied changes made to original
Scott   2021-04-20  Reformat to CTE form and add Universal Exclusion for no benefit, hourly.

EXEC uspCFR_HiAmt_Paid_MVDID   --21,602 /:24

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HiAmt_Paid_MVDID', @CustID = 16, @RuleID = 219, @ProductID = 2, @OwnerGroup= 159

*/

BEGIN
	SET NOCOUNT ON;

DECLARE @MaxRolling12 varchar(6)
DECLARE @RuleID int = 219

-- Capture most recent rolling 12 computed
SELECT @MaxRolling12 = MAX(MonthID) FROM ComputedMemberTotalPaidClaimsRollling12

	;WITH StandardExclusion AS
		(-- active member management form (c) for specific program types
			SELECT MVDID, 'Active' AS Rsn 
			  FROM ABCBS_MemberManagement_Form MMF
			 WHERE MMF.CaseProgram IN ('case management', 'chronic condition management', 'maternity')
			   AND ISNULL(MMF.SectionCompleted,9) < 3
			 UNION -- denial in last 120 days (d) for specific program types
			SELECT DISTINCT MVDID, 'Refused' AS Rsn 
			  FROM ABCBS_MemberManagement_Form MMF
			 WHERE MMF.CaseProgram in ('case management', 'chronic condition management', 'maternity')
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
			 UNION  -- UTR in last 120 days (e) for specific program types
			SELECT DISTINCT MVDID, 'UTR' AS Rsn 
			  FROM ABCBS_MemberManagement_Form MMF
			 WHERE MMF.CaseProgram IN ('case management', 'chronic condition management', 'maternity')
			   AND (MMF.qNonViableReason1 = 'unable to reach member' 
				    OR MMF.q2ConsentNonViable = 'unable to reach member' 
					OR MMF.qNoReason = 'unable to reach member'
					OR MMF.q8 = 'unable to reach member'
				   )
			   AND DateDiff(day,MMF.FormDate, GetDate()) < 121
			 UNION -- member expired
			SELECT DISTINCT MVDID, 'Expired' AS Rsn 
			  FROM ABCBS_MemberManagement_Form MMF
			 WHERE (MMF.qNonViableReason1 = 'member expired' 
				    OR MMF.q2ConsentNonViable = 'member expired' 
				    OR MMF.qNoReason = 'member expired'
				    OR MMF.q8 = 'member expired'
				    OR MMF.q2CloseReason = 'member expired'
			       )-- or valid date of death -- not captured on MMF
			 UNION 	-- contact in last 120 days
			SELECT DISTINCT MVDID , 'Contact' AS Rsn
			  FROM ARBCBS_Contact_Form CF
			 WHERE DATEDIFF(day,CF.q1ContactDate, GETDATE()) < 121
			   AND q4ContactType IN ('Member','Caregiver')
			   AND q7ContactSuccess = 'Yes'
			   AND q2program IN ('Case Management','Specialty Care','Maternity')
		),
		UniversalExclusion AS
		(
			SELECT DISTINCT fm.MVDID
			  FROM FinalMember fm
			  JOIN Final.dbo.LookupGRP_CareFlowRule ue ON fm.CompanyKey = ue.Company_Key
			 WHERE (ue.Bill_Hourly_Ind = 'Y' OR ue.Exclude_Careflow_Ind = 'Y') 
		)
			-- member is active (a), has no case manager (b), no personal harm (i), high cost per group (AC2)
			SELECT DISTINCT CCQ.MVDID
			  FROM ComputedCareQueue CCQ
			  JOIN FinalMember FM on FM.MVDID = CCQ.MVDID
		 LEFT JOIN ComputedMemberAlert CA on CA.MVDID = CCQ.MVDID
		 LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 CP on CP.MVDID = CCQ.MVDID
			 WHERE CCQ.IsActive = 1 
		       AND ISNULL(FM.COBCD,'U') in ('S','N','U')
			   AND ISNULL(FM.CompanyKey,'0000') != '1338'
			   AND ISNULL(CCQ.CaseOwner,'--') = '--'
			   AND ISNULL(CA.PersonalHarm,0) = 0
			   AND ISNULL(CP.HighDollarClaim,0) = 1
			   AND CP.MonthID = @MaxRolling12
			   AND FM.GrpInitvCd != 'GRD'
			   AND NOT EXISTS (SELECT 1 FROM StandardExclusion WHERE MVDID = CCQ.MVDID)
			   AND NOT EXISTS (SELECT 1 FROM UniversalExclusion WHERE MVDID = CCQ.MVDID)
END