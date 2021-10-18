/****** Object:  Procedure [dbo].[uspCFR_CancerNonWalmart_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_CancerNonWalmart_MVDID] 
AS
/*
    CustID:  16
    RuleID:  245
 ProductID:  2
OwnerGroup:  161

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	Created by refactor of original to call uspCFR_Merge
Scott	2020-11-21	Applied changes from original
Scott	2021-02-09	Added dbo.LookupCodeCondition to store over 600 codes for procs and diags.
Scott	2021-02-10  Refactor to use cte for performance and readability.
Scott	2021-04-14  Add Universal Exclusion for no benefit and hourly.
Scott	2021-07-15	Add ID column and NonCOE Column to LookupCodeTypeCondition and add new codes for NonCOE.
Scott	2021-07-15	Moved Exclusions to temp table.
Scott	2021-07-15	Modified to use NonWalmart column and LIKE in the where clause.
				
EXEC uspCFR_CancerNonWalmart_MVDID_20210728		--(314/:54)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_CancerNonWalmart_MVDID', @CustID = 16, @RuleID = 245, @ProductID = 2, @OwnerGroup= 161

SELECT * FROM LookupCodeTypeCondition WHERE NonCOE = 1 ORDER BY Code

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 245  -- for non-Walmart and target Specialty CM group 165 *** THIS VALUE MAY BE DIFFERENT BETWEEN UAT AND LIVE

	DROP TABLE IF EXISTS #Exclusions

	;WITH cteExcluded AS
		(SELECT DISTINCT MVDID, 'Active' AS Rsn 
	       FROM ABCBS_MemberManagement_Form MMF
	      WHERE MMF.CaseProgram in ('case management', 'chronic condition management', 'maternity')
	        AND ISNULL(MMF.SectionCompleted,9) < 3
	      UNION
 		 SELECT DISTINCT MVDID, 'Refused' AS Rsn -- denial in last 120 days (d) for specific program types
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
		 SELECT DISTINCT MVDID, 'Expired' AS Rsn -- member expired or valid date of death -- not captured on MMF
	       FROM ABCBS_MemberManagement_Form MMF
	      WHERE (MMF.qNonViableReason1 = 'member expired' 
	             OR MMF.q2ConsentNonViable = 'member expired' 
	             OR MMF.qNoReason = 'member expired'
	             OR MMF.q8 = 'member expired'
	             OR MMF.q2CloseReason = 'member expired'
	            ) 
	      UNION
	     SELECT DISTINCT MVDID , 'Contact' AS Rsn -- contact in last 120 days
	       FROM ARBCBS_Contact_Form CF
	      WHERE DATEDIFF(day,CF.q1ContactDate, GETDATE()) < 121
	        AND q4ContactType IN ('Member','Caregiver')
	        AND q7ContactSuccess = 'Yes'
	        AND q2program IN ('Case Management','Specialty Care','Maternity')
		)
		SELECT MVDID, Rsn
		  INTO #Exclusions
		  FROM cteExcluded
		
	;WITH UniversalExclusion AS
		(
			SELECT DISTINCT fm.MVDID
			  FROM FinalMember fm
			  JOIN Final.dbo.LookupGRP_CareFlowRule ue ON fm.CompanyKey = ue.Company_Key
			 WHERE (ue.Bill_Hourly_Ind = 'Y' OR ue.Exclude_Careflow_Ind = 'Y') 
		)
		 SELECT DISTINCT H.MVDID --l.Code, HC.CodeValue
	       FROM FinalClaimsHeaderCode HC WITH (READUNCOMMITTED)		
	       JOIN FinalClaimsHeader H WITH (READUNCOMMITTED) on H.ClaimNumber = HC.ClaimNumber
	       JOIN ComputedCareQueue CCQ WITH (READUNCOMMITTED) ON CCQ.MVDID = H.MVDID
      LEFT JOIN ComputedMemberAlert CA WITH (READUNCOMMITTED) ON CA.MVDID = CCQ.MVDID
	       JOIN FinalMember FM WITH (READUNCOMMITTED) ON FM.MVDID = CCQ.MVDID
		   JOIN LookupCodeTypeCondition l WITH (READUNCOMMITTED) 
	         ON HC.CodeType = l.CodeType   
	        AND ISNULL(l.ICDVersion,'0') = HC.ICDVersion
	        AND HC.CodeValue LIKE (l.Code + '%')  
	        AND l.NonWalmart = 1
	      WHERE CCQ.IsActive = 1 
	        AND ISNULL(FM.CompanyKey,'0000') != '1338'
	        AND ISNULL(CCQ.CaseOwner,'--') = '--'
	        AND ISNULL(CA.PersonalHarm,0) = 0
	        AND FM.CmOrgRegion != 'WALMART'
  	        AND H.StatementFromDate >= DATEADD(day,-60,GetDate()) -- Reported in last 60 days
	        AND ISNULL(FM.COBCD,'U') IN ('S','N','U')
	        AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
			AND NOT EXISTS (SELECT * FROM #Exclusions WHERE MVDID = H.MVDID)
			AND NOT EXISTS (SELECT 1 FROM UniversalExclusion WHERE MVDID = H.MVDID)

END