/****** Object:  Procedure [dbo].[uspCFR_Homelessness_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE uspCFR_Homelessness_MVDID
AS
/*
		Homelessness

    CustID:  16
    RuleID:  306
 ProductID:  2
OwnerGroup:  168 Rules Review

WHO		WHEN		WHAT
Scott	2021-10-14	Created.  TFS 6168.

EXEC uspCFR_Homelessness_MVDID --(6153/:52)

INSERT INTO HPWorkflowRule (Cust_ID, Name, Description, Body, Action_ID, Action_Days, Active, CreatedDate, Query, AdminUseOnly, [Group])
VALUES (16,'Homelessness','Members diagnosed with Homelessness and Social Environment.','uspCFR_Homelessness',-1,0,1,'2021-10-14','SP',1,'CF Review')
SELECT * FROM HPWorkflowRule

EXEC uspCFR_MapRuleExclusion @RuleID = 306, @Action = 'ADD'

*/
BEGIN
SET NOCOUNT ON

Exclusions:

--a.  Member Expired    --granular exclusion 4 expired and 14 (non viable expired)
--b.  Member Terminated --granular 26 ineligible
--c.  Grand Rounds (Except Tyson) -- granular 20 GRD except tyson
--d.  Currently assigned to a social worker -- Custom had to add social work
--e.  SW Referral with Case Program Social Work within 30 days.  -- Custom  had to add social work 
--f.  Case Closure of CaseProgram SocialWork within 90 days  --Custom
--g.  Denial of Services within 120 days --Custom 
--h.  UTR within 120 days-- Custom 

	--Granular Exclusion Code
		  DROP TABLE IF EXISTS #ExcludedMVDID
		CREATE TABLE #ExcludedMVDID (MVDID varchar(30))

		INSERT INTO #ExcludedMVDID (MVDID)
		SELECT DISTINCT em.MVDID
		  FROM CFR_Rule_Exclusion re
		  JOIN HPWorkFlowRule wfr ON wfr.Rule_ID = re.RuleID
		  JOIN CFR_ExcludedMVDID em ON em.ExclusionID = re.ExclusionID
		  JOIN CFR_Exclusion e ON em.ExclusionID = e.ID
		 WHERE wfr.Body = OBJECT_NAME(@@PROCID)

		;With CustomExclusion AS
			(--Referral to Social Work in 30 days	
			SELECT DISTINCT MVDID, 'Referral to SW in 30' ExclusionName
			  FROM ABCBS_MemberManagement_Form (READUNCOMMITTED)
		  	 WHERE DATEDIFF(dd,FormDate,GETDATE()) < 31 
	           AND ISNULL(ReferralID,'') != '' 
	           AND DATEDIFF(dd,ReferralDate,GETDATE()) <= 30 
			   AND CaseProgram IN ('Social Work')
             UNION --Social Work Case Closed in last 90 days
		   	SELECT DISTINCT MVDID, 'SW Case Closed in 90' ExclusionName
 	          FROM ABCBS_MemberManagement_Form (READUNCOMMITTED)
             WHERE qCloseCase = 'Yes'
	           AND DATEDIFF(dd,q1CaseCloseDate,GETDATE()) <= 90
			   AND CaseProgram IN ('Social Work')
			 UNION --Case assigned to a social worker
			SELECT DISTINCT MVDID, 'Assigned to Social Worker' ExclusionName  
			  FROM ABCBS_MemberManagement_Form  (READUNCOMMITTED)
			 WHERE ISNULL(q1CaseOwner,'') <> '' 
			   AND CaseProgram = 'Social Work'
			   AND q1CaseCloseDate IS NULL
             UNION  --NonViable/ineligible or termed
	        SELECT DISTINCT MVDID, 'Ineligible or termed' ExclusionName
	          FROM ABCBS_MemberManagement_Form  (READUNCOMMITTED)
	         WHERE CaseProgram IN ('Case Management', 'Chronic Condition Management', 'Maternity', 'Social Work')
	           AND qNonViableReason1 = 'Member Ineligible for Policy Benefits/Policy Termed'
             UNION -- NonViable/Refusal
	        SELECT DISTINCT MVDID, 'NonViable/Refusal in 120' ExclusionName
	          FROM ABCBS_MemberManagement_Form  (READUNCOMMITTED)
	         WHERE CaseProgram IN ('Case Management', 'Chronic Condition Management', 'Maternity', 'Social Work')
	           AND qNonViableReason1 IN ('Member/Family Refused Case Management','No CM Needs')
			   AND DATEDIFF(dd,LastModifiedDate, GETDATE()) <= 120 
			 UNION  -- NonViable/UTR
	        SELECT DISTINCT MVDID, 'NonViable/UTR in 120' ExclusionName
	          FROM ABCBS_MemberManagement_Form  (READUNCOMMITTED)
	         WHERE CaseProgram IN ('Case Management', 'Chronic Condition Management', 'Maternity', 'Social Work')
	          AND qNonViableReason1 = 'Unable to Reach Member'
			  AND DATEDIFF(dd,LastModifiedDate, GETDATE()) <= 120 
			)
			INSERT INTO #ExcludedMVDID (MVDID)
			SELECT MVDID 
			  FROM CustomExclusion

	CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)
	
		   SELECT DISTINCT H.MVDID
			 FROM FinalMember FM 
			 JOIN FinalClaimsHeader H ON FM.MVDID = H.MVDID
			 JOIN FinalClaimsHeaderCode HC ON H.ClaimNumber = HC.ClaimNumber
			WHERE ISNULL(FM.CompanyKey,'0000') != '1338'
			  AND hc.CodeType = 'DIAG'
			  AND (hc.CodeValue LIKE 'Z59%' OR hc.CodeValue = 'Z608')
			  AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = H.MVDID)

END