/****** Object:  Procedure [dbo].[uspCFR_Execute]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Execute] 
AS
/*
	Please add comments on changes to this procedure or new careflow rules.

Changes:

WHO				WHEN		WHAT
Sunil Nokku		08/25/2020	Add query to capture Elapsed time.
Sunil Nokku     08/28/2020  Add DataScience Import tables SP.
Scott			2020-11-19	Audit and prepare for transistion to new MERGE procedures
Scott			2020-11-21	Move to Merge procedure.  Disable DELETE CareFlowTask as this is now accomplished in the MERGE.
Scott			2020-11-23  Update JobHistory with new procedure names 
Mike			2020-12-02	Update CFR 245 to point at group 161 instead of 168 per client
Unknown			2021-01-04	MA Eligibility is currently turned off because of eligibility file issues. 254,255,256,262,263,264,265,266,267
Scott			2021-02-05	Enable MA Eligibility CFR's
Scott			2021-02-09	Move 223 to group 161
Scott			2021-02-09	Updated Cancer Walmart (244/162) and Cancer Non Walmart (245/161) 
Scott			2021-05-06	Added 8 High Cost 4 rules with Company Exclusions (4X) Owner Group 159
Scott			2021-08-23	Disabled Rules (206,219,220,241,242,247) per TFS # 5895.  Records moved from CareFlowTask to History.

EXEC uspCFR_Execute 

SELECT * FROM CFR_JobHistory_Merge WHERE RuleID = 224 ORDER BY StartTime DESC

*/
BEGIN
	SET NOCOUNT ON;

exec [dbo].[uspInsertDataScienceTags]
exec dbo.uspCFR_LoadExcludedMVDID

exec uspCFR_Merge @MVDProcedureName = 'uspCFR_ERVisits_MVDID', @CustID = 16, @RuleID = 200, @ProductID = 2, @OwnerGroup= 159   

exec uspCFR_Merge @MVDProcedureName = 'uspCFR_ERVisits12Mo_MA_MVDID', @CustID=16, @RuleID = 255, @ProductID=2, @OwnerGroup = 171     --MA eligbility
-- exec uspCFR_Merge @MVDProcedureName = 'uspCFR_Cancer_MVDID', @CustID = 16, @RuleID = 209, @ProductID=2, @OwnerGroup = 149 -- disabled; see TFS 4659
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_CancerNonWalmart_MVDID', @CustID = 16, @RuleID = 245, @ProductID = 2, @OwnerGroup= 161
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_CancerWalMart_MVDID', @CustID = 16, @RuleID = 244, @ProductID = 2, @OwnerGroup= 162
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HospitalRecurringVisits_MVDID', @CustID = 16, @RuleID = 208, @ProductID = 2, @OwnerGroup= 161
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HospitalRecurringVisits_MA_MVDID', @CustID = 16, @RuleID = 254, @ProductID = 2, @OwnerGroup= 171   --MA eligbility

exec uspCFR_ERVisit_Strat_Master --(268,269,270)
exec uspCFR_ERVisit_Strat90_Master --(271,272,273)

-- NDBH Auto referral
-- exec uspCFR_Merge @MVDProcedureName = 'uspCFR_NDBH1', @CustID = 16, @RuleID = 296, @ProductID = 2, @OwnerGroup= 168  --ticket 6098
-- exec uspCFR_Merge @MVDProcedureName = 'uspCFR_NDBH2', @CustID = 16, @RuleID = 297, @ProductID = 2, @OwnerGroup= 168  --ticket 6097
-- exec uspCFR_Merge @MVDProcedureName = 'uspCFR_NDBH3', @CustID = 16, @RuleID = 298, @ProductID = 2, @OwnerGroup= 168  --ticket 6058

exec uspCFR_Merge @MVDProcedureName = 'uspCFR_Maternity_MVDID', @CustID = 16, @RuleID = 204, @ProductID = 2, @OwnerGroup= 156
--exec uspCFR_Merge @MVDProcedureName = 'uspCFR_Metformin_MVDID', @CustID = 16, @RuleID = 206, @ProductID = 2, @OwnerGroup= 168  --ticket 5895
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_Renal_MVDID', @CustID = 16, @RuleID = 205, @ProductID = 2, @OwnerGroup= 162
--exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HiAmt_Paid_MVDID', @CustID = 16, @RuleID = 219, @ProductID = 2, @OwnerGroup= 159  --ticket 5895
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HiAmt_Paid_MA_MVDID', @CustID=16, @RuleID = 256, @ProductID=2, @OwnerGroup = 171   --MA eligbility
--exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HiAmt_Pended_MVDID', @CustID = 16, @RuleID = 220, @ProductID = 2, @OwnerGroup= 149 --ticket 5895
--exec uspCFR_Merge @MVDProcedureName = 'uspCFR_Covid19_Lab_MVDID', @CustID = 16, @RuleID = 242, @ProductID = 2, @OwnerGroup= 159  --ticket 5895
--exec uspCFR_Merge @MVDProcedureName = 'uspCFR_Covid19_10Day_MVDID', @CustID = 16, @RuleID = 241, @ProductID = 2, @OwnerGroup= 159  --ticket 5895
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_DiabetesRenal_MVDID', @CustID = 16, @RuleID = 217, @ProductID = 2, @OwnerGroup= 161
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_Ortho_MVDID', @CustID = 16, @RuleID = 215, @ProductID = 2, @OwnerGroup= 161
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_PTB_MVDID', @CustID = 16, @RuleID = 216, @ProductID = 2, @OwnerGroup= 155
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_PTB_IN_CM_MVDID', @CustID = 16, @RuleID = 222, @ProductID = 2, @OwnerGroup= 155
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_SUDandDepression_MVDID', @CustID = 16, @RuleID = 214, @ProductID = 2, @OwnerGroup= 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_SUDandDepression1_MVDID', @CustID = 16, @RuleID = 281, @ProductID = 2, @OwnerGroup= 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_SUDandDepression2_MVDID', @CustID = 16, @RuleID = 282, @ProductID = 2, @OwnerGroup= 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_top10RxMedRatio_MVDID', @CustID = 16, @RuleID = 218, @ProductID = 2, @OwnerGroup= 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_top10HiRxMedRatio_MVDID', @CustID = 16, @RuleID = 221, @ProductID = 2, @OwnerGroup= 153
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_Depression_MVDID', @CustID = 16, @RuleID = 213, @ProductID = 2, @OwnerGroup= 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_Depression1_MVDID', @CustID = 16, @RuleID = 279, @ProductID = 2, @OwnerGroup= 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_Depression2_MVDID', @CustID = 16, @RuleID = 280, @ProductID = 2, @OwnerGroup= 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HCC_Paid_30_MVDID', @CustID=16, @RuleID = 261, @ProductID=2,@OwnerGroup = 169
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HCC_Paid_50_MVDID', @CustID=16, @RuleID = 260, @ProductID=2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HCC_Paid_100_MVDID', @CustID=16, @RuleID = 259, @ProductID=2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HCC_Paid_250_MVDID', @CustID=16, @RuleID = 258, @ProductID=2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HCC_Paid_750_MVDID', @CustID=16, @RuleID = 257, @ProductID=2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HCC_Pended_30_MVDID', @CustID=16, @RuleID = 278, @ProductID=2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HCC_Pended_50_MVDID', @CustID=16, @RuleID = 277, @ProductID=2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HCC_Pended_100_MVDID', @CustID=16, @RuleID = 276, @ProductID=2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HCC_Pended_250_MVDID', @CustID=16, @RuleID = 275, @ProductID=2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HCC_Pended_750_MVDID', @CustID=16, @RuleID = 274, @ProductID=2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CHF_7_MVDID', @CustID = 16, @RuleID = 223, @ProductID = 2, @OwnerGroup= 161
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CHF_4_MVDID', @CustID = 16, @RuleID = 224, @ProductID = 2, @OwnerGroup= 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CHF_LO_MVDID', @CustID = 16, @RuleID = 225, @ProductID = 2, @OwnerGroup= 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_COPD_7_MVDID', @CustID = 16, @RuleID = 226, @ProductID = 2, @OwnerGroup = 161
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_COPD_4_MVDID', @CustID = 16, @RuleID = 227, @ProductID = 2, @OwnerGroup = 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_COPD_LO_MVDID', @CustID = 16, @RuleID = 228, @ProductID = 2, @OwnerGroup = 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_HTN_7_MVDID', @CustID = 16, @RuleID = 229, @ProductID = 2, @OwnerGroup = 161
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_HTN_4_MVDID', @CustID = 16, @RuleID = 230, @ProductID = 2, @OwnerGroup = 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_HTN_LO_MVDID', @CustID = 16, @RuleID = 231, @ProductID = 2, @OwnerGroup = 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_DIA_7_MVDID', @CustID = 16, @RuleID = 232, @ProductID = 2, @OwnerGroup = 161
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_DIA_4_MVDID', @CustID = 16, @RuleID = 233, @ProductID = 2, @OwnerGroup = 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_DIA_LO_MVDID', @CustID = 16, @RuleID = 234, @ProductID = 2, @OwnerGroup = 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CAN_7_MVDID', @CustID = 16, @RuleID = 235, @ProductID = 2, @OwnerGroup = 161
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CAN_4_MVDID', @CustID = 16, @RuleID = 236, @ProductID = 2, @OwnerGroup = 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CAN_LO_MVDID', @CustID = 16, @RuleID = 237, @ProductID = 2, @OwnerGroup = 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_NEU_7_MVDID', @CustID = 16, @RuleID = 238, @ProductID = 2, @OwnerGroup = 161
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_NEU_4_MVDID', @CustID = 16, @RuleID = 239, @ProductID = 2, @OwnerGroup = 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_NEU_LO_MVDID', @CustID = 16, @RuleID = 240, @ProductID = 2, @OwnerGroup = 168

exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_AMR_7_MVDID', @CustID = 16, @RuleID = 248, @ProductID = 2, @OwnerGroup = 161
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_AMR_4_MVDID', @CustID = 16, @RuleID = 249, @ProductID = 2, @OwnerGroup = 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_AMR_LO_MVDID', @CustID = 16, @RuleID = 250, @ProductID = 2, @OwnerGroup = 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CAD_7_MVDID', @CustID = 16, @RuleID = 251, @ProductID = 2, @OwnerGroup = 161
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CAD_4_MVDID', @CustID = 16, @RuleID = 252, @ProductID = 2, @OwnerGroup = 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CAD_LO_MVDID', @CustID = 16, @RuleID = 253, @ProductID = 2, @OwnerGroup = 168
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_A03_MA_MVDID', @CustID = 16, @RuleID = 283, @ProductID = 2, @OwnerGroup = 171

exec [dbo].[uspCFR_Various_MA_Master]	--262,263,264,265,266,267  --MA Eligibility

--new
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_COPD_4X_MVDID', @CustID = 16, @RuleID = 284, @ProductID = 2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_HTN_4X_MVDID', @CustID = 16, @RuleID = 285, @ProductID = 2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_DIA_4X_MVDID', @CustID = 16, @RuleID = 286, @ProductID = 2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CAN_4X_MVDID', @CustID = 16, @RuleID = 287, @ProductID = 2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_NEU_4X_MVDID', @CustID = 16, @RuleID = 288, @ProductID = 2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_AMR_4X_MVDID', @CustID = 16, @RuleID = 289, @ProductID = 2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CAD_4X_MVDID', @CustID = 16, @RuleID = 290, @ProductID = 2, @OwnerGroup = 159
exec uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CHF_4X_MVDID', @CustID = 16, @RuleID = 291, @ProductID = 2, @OwnerGroup = 159

END