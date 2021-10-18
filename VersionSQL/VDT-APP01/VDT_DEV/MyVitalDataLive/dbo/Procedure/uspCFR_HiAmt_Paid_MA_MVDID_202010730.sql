/****** Object:  Procedure [dbo].[uspCFR_HiAmt_Paid_MA_MVDID_202010730]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HiAmt_Paid_MA_MVDID] 
AS
/*

	CustID:			16
	RuleID:			256
	ProductID:		2
	OwnerGroup:		171

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to use new merge process: return only the MVDIDs.
Scott		2021-05-24	Refactor to CTE and add Universal Exclusion for no benifit, hourly.
Scott		2021-07-08	Add query hints to prevent deadlock.

EXEC uspCFR_HiAmt_Paid_MA_MVDID  --(80/3:57)

This procedure may be called using the Merge procedure:

exec uspCFR_Merge @MVDProcedureName ='uspCFR_HiAmt_Paid_MA_MVDID', @CustID=16, @RuleID = 256, @ProductID=2, @OwnerGroup = 171

*/
BEGIN

	SET NOCOUNT ON;

DECLARE @MaxRolling12 varchar(6)

-- Capture most recent rolling 12 computed
SELECT @MaxRolling12 = MAX(MonthID) FROM ComputedMemberTotalPaidClaimsRollling12


	;WITH StandardExclusion AS
		(  -- active member management form (c) for specific program types
			SELECT MVDID, 'Active' AS Rsn 
			  FROM ABCBS_MemberManagement_Form MMF WITH (READUNCOMMITTED)
			 WHERE MMF.CaseProgram in ('case management', 'chronic condition management', 'maternity')
			   AND ISNULL(MMF.SectionCompleted,9) < 3
			 UNION -- denial in last 120 days (d) for specific program types
			SELECT DISTINCT MVDID, 'Refused' as Rsn 
			  FROM ABCBS_MemberManagement_Form MMF WITH (READUNCOMMITTED)
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
			 UNION -- UTR in last 120 days (e) for specific program types
			SELECT DISTINCT MVDID, 'UTR' AS Rsn 
			  FROM ABCBS_MemberManagement_Form MMF WITH (READUNCOMMITTED)
			 WHERE MMF.CaseProgram IN ('case management', 'chronic condition management', 'maternity')
			   AND (MMF.qNonViableReason1 = 'unable to reach member' 
				    OR MMF.q2ConsentNonViable = 'unable to reach member' 
				    OR MMF.qNoReason = 'unable to reach member'
				    OR MMF.q8 = 'unable to reach member'
			       )
			   AND DATEDIFF(day,MMF.FormDate, GETDATE()) < 121
			 UNION -- member expired
			SELECT DISTINCT MVDID, 'Expired' AS Rsn 
			  FROM ABCBS_MemberManagement_Form MMF WITH (READUNCOMMITTED)
			 WHERE (MMF.qNonViableReason1 = 'member expired' 
					OR MMF.q2ConsentNonViable = 'member expired' 
					OR MMF.qNoReason = 'member expired'
					OR MMF.q8 = 'member expired'
					OR MMF.q2CloseReason = 'member expired'
			       ) -- or valid date of death -- not captured on MMF
			 UNION -- contact in last 120 days
			SELECT DISTINCT MVDID, 'Contact' AS Rsn
  			  FROM ARBCBS_Contact_Form CF WITH (READUNCOMMITTED)
			 WHERE DATEDIFF(day,CF.q1ContactDate, GETDATE()) < 121
			   AND q4ContactType IN ('Member','Caregiver')
			   AND q7ContactSuccess = 'Yes'
			   AND q2program IN ('Case Management','Specialty Care','Maternity')
		),
		UniversalExclusion AS
		(
			SELECT DISTINCT fm.MVDID
			  FROM FinalMember fm WITH (READUNCOMMITTED)
			  JOIN Final.dbo.LookupGRP_CareFlowRule ue  WITH (READUNCOMMITTED) ON fm.CompanyKey = ue.Company_Key
			 WHERE (ue.Bill_Hourly_Ind = 'Y' OR ue.Exclude_Careflow_Ind = 'Y') 
		)
		-- member is active (a) has no case manager (b) no personal harm (i) high cost per group (AC2) 
		SELECT DISTINCT CCQ.MVDID
		  FROM ComputedCareQueue CCQ WITH (READUNCOMMITTED)
		  JOIN FinalMember FM  WITH (READUNCOMMITTED) ON FM.MVDID = CCQ.MVDID
		  JOIN FinalEligibility FE  WITH (READUNCOMMITTED) ON FE.MVDID = FM.MVDID and FE.MemberEffectiveDate <= GETDATE() AND ISNULL(FE.MemberTerminationDate,'9999-12-31') >= GETDATE() and IsNull(FE.FakeSpanInd,'N') = 'N' and IsNull(FE.SpanVoidInd,'N') = 'N'
	 LEFT JOIN ComputedMemberAlert CA  WITH (READUNCOMMITTED) ON CA.MVDID = CCQ.MVDID
	 LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 CP WITH (READUNCOMMITTED) ON CP.MVDID = CCQ.MVDID
		 WHERE CCQ.IsActive = 1 
		   AND ISNULL(FM.COBCD,'U') IN ('S','N','U')
		   AND ISNULL(FM.CompanyKey,'0000') != '1338'
		   AND FE.PlanIdentifier != 'H4213'
		   AND ISNULL(CCQ.CaseOwner,'--') = '--'
		   AND ISNULL(CA.PersonalHarm,0) = 0
		   AND ISNULL(CP.HighDollarClaim,0) = 1
		   AND CP.MonthID = @MaxRolling12
		   AND ISNULL(FM.GrpInitvCd,'n/a') != 'GRD'
		   AND CCQ.LOB='MA'
		   AND NOT EXISTS (SELECT 1 FROM StandardExclusion WHERE MVDID = CCQ.MVDID)
		   AND NOT EXISTS (SELECT 1 FROM UniversalExclusion WHERE MVDID = CCQ.MVDID)

END