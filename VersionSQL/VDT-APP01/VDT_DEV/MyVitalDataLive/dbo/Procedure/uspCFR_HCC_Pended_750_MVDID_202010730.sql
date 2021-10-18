/****** Object:  Procedure [dbo].[uspCFR_HCC_Pended_750_MVDID_202010730]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HCC_Pended_750_MVDID] 
AS
/*
			***Depends on CFR 220

	CustID:			16
	RuleID:			274
	ProductID:		2
	OwnerGroup:		168

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to use new merge process: return only the MVDIDs.

exec uspCFR_HCC_Pended_750_MVDID

This procedure may be called using the Merge procedure:

exec uspCFR_Merge @MVDProcedureName ='uspCFR_HCC_Pended_750_MVDID', @CustID=16, @RuleID = 274, @ProductID=2, @OwnerGroup = 168

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaxRolling12 varchar(6)
	DECLARE @RuleId int = 274
	DECLARE @OwnerGroup int = 168 -- review group -- ultimately 145

	-- Capture most recent rolling 12 computed
	SELECT @MaxRolling12 = MAX(MonthID) FROM ComputedMemberTotalPendedClaimsRollling12

	;WITH UniversalExclusion AS
		(
			SELECT DISTINCT fm.MVDID
			  FROM FinalMember fm
			  JOIN Final.dbo.LookupGRP_CareFlowRule ue ON fm.CompanyKey = ue.Company_Key
			 WHERE (ue.Bill_Hourly_Ind = 'Y' OR ue.Exclude_Careflow_Ind = 'Y') 
		)
		SELECT CF.MVDID 
		  FROM CareFlowTask CF
		  JOIN ComputedMemberTotalPendedClaimsRollling12 CCR on CCR.MVDID = CF.MVDID and MonthID = @MaxRolling12
		 WHERE CF.RuleId = 220
		   AND CCR.TotalPaidAmount >= 750000
		   AND NOT EXISTS (SELECT 1 FROM UniversalExclusion WHERE MVDID = CF.MVDID)

END