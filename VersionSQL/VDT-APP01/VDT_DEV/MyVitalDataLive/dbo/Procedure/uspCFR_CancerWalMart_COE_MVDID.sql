/****** Object:  Procedure [dbo].[uspCFR_CancerWalMart_COE_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_CancerWalMart_COE_MVDID] 
AS
/*
    CustID:  16
    RuleID:  244
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	Created by refactor of original to call uspCFR_Merge
Scott	2020-11-21	Applied changes from original
Scott	2021-02-09	Added dbo.LookupCodeCondition to store over 600 codes for procs and diags.
Scott	2021-02-10  Refactor to use cte for performance and readability.
Scott	2021-04-14	Add Universal Exclusions for no benefit and hourly.
Scott   2021-06-15  Added COE column to LookupCodeCondition.
Scott	2021-06-15  Modified from CancerWalMart to use new COE diagnosis codes. 

EXEC uspCFR_CancerWalMart_COE_MVDID   -- (4:54/134)  (3:38/134) (:54/588)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_CancerWalMart_MVDID', @CustID = 16, @RuleID = 244, @ProductID = 2, @OwnerGroup= 168

SELECT * FROM LookupCodeTypeCondition WHERE COE = 1 ORDER BY Code

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 244  -- for Walmart and target Specialty CM group 162 *** THIS VALUE MAY BE DIFFERENT BETWEEN UAT AND LIVE

	DROP TABLE IF EXISTS #Exclusions

	;WITH cteExcluded AS
		(
		SELECT MVDID, 'Active' AS Rsn 
		  FROM ABCBS_MemberManagement_Form MMF
		 WHERE MMF.CaseProgram IN ('case management', 'chronic condition management', 'maternity')
		   AND ISNULL(MMF.SectionCompleted,9) < 3
		 UNION
		SELECT DISTINCT MVDID, 'Refused' AS Rsn -- denial in last 120 days (d) -- for specific program types
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
		 UNION
		SELECT DISTINCT MVDID, 'Expired' AS Rsn -- member expired
		  FROM ABCBS_MemberManagement_Form MMF
		 WHERE (MMF.qNonViableReason1 = 'member expired' 
				OR MMF.q2ConsentNonViable = 'member expired' 
				OR MMF.qNoReason = 'member expired'
				OR MMF.q8 = 'member expired'
				OR MMF.q2CloseReason = 'member expired'
			   )
		 UNION -- or valid date of death -- not captured on MMF
		SELECT DISTINCT MVDID ,'Contact' AS Rsn -- contact in last 120 days
		  FROM ARBCBS_Contact_Form CF
		 WHERE DateDiff(day,CF.q1ContactDate, GetDate()) < 121
		   AND q4ContactType IN ('Member','Caregiver')
		   AND q7ContactSuccess = 'Yes'
		   AND q2program IN ('Case Management','Specialty Care','Maternity')
		)
		SELECT MVDID, Rsn 
		  INTO #Exclusions
		  FROM cteExcluded

	CREATE INDEX ix_MVDID_Exclusions ON #Exclusions (MVDID)

;WITH UniversalExclusion AS
		(
			SELECT DISTINCT fm.MVDID
			  FROM FinalMember fm
			  JOIN Final.dbo.LookupGRP_CareFlowRule ue ON fm.CompanyKey = ue.Company_Key
			 WHERE (ue.Bill_Hourly_Ind = 'Y' OR ue.Exclude_Careflow_Ind = 'Y') 
		)
		SELECT DISTINCT H.MVDID -- ,l.Code ,HC.CodeValue
		  FROM FinalClaimsHeaderCode (READUNCOMMITTED) HC		
		  JOIN FinalClaimsHeader (READUNCOMMITTED) H ON H.ClaimNumber = HC.ClaimNumber
		  JOIN ComputedCareQueue (READUNCOMMITTED) CCQ ON CCQ.MVDID = H.MVDID
	 LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA ON CA.MVDID = CCQ.MVDID
		  JOIN FinalMember (READUNCOMMITTED) FM ON FM.MVDID = CCQ.MVDID
		  JOIN LookupCodeTypeCondition l
			ON HC.CodeType = l.CodeType  
		   AND ISNULL(HC.ICDVersion,'0') = ISNULL(l.ICDVersion,'0')  
		   AND HC.CodeValue LIKE (l.Code + '%')   
		   AND l.COE = 1
		 WHERE CCQ.IsActive = 1 
		   AND ISNULL(FM.CompanyKey,'0000') != '1338'
		   AND ISNULL(CCQ.CaseOwner,'--') = '--'
		   AND ISNULL(CA.PersonalHarm,0) = 0
  		   AND H.StatementFromDate >= DATEADD(day,-60,GetDate()) -- Reported in last 60 days
		   AND FM.CmOrgRegion = 'WALMART'
		   AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
		   AND ISNULL(FM.COBCD,'U') IN ('S','N','U')
  		   --and H.PaidDate > = DATEADD(MONTH,-1,@R12Date+'01')     -- Paid in the last 30 days
		   AND NOT EXISTS (SELECT 1 FROM #Exclusions WHERE MVDID = H.MVDID)
		   AND NOT EXISTS (SELECT 1 FROM UniversalExclusion WHERE MVDID = H.MVDID)

END