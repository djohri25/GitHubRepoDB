/****** Object:  Procedure [dbo].[uspCFR_ERVisit_Strat90_Master]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_ERVisit_Strat90_Master] 
AS
/*
	CustID:			16
	RuleID:			271,272,273
	ProductID:		2
	OwnerGroup:		168

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to use new merge process
Mike G		2020-12-08	Per client, redirect rules 272 and 273 to Clinical support (159)
Scott		2021-10-21	Retired 271 to dbo.uspLetterERVisitQueue

EXEC uspCFR_ERVisit_Strat_MVDID

This procedure will call the following three careflow rules

--EXEC uspCFR_Merge @MVDProcedureName 'uspCFR_ERVisit_Strat_271_MVDID', @CustID=16, @RuleID = 271, ProductID=2,@OwnerGroup = 159
EXEC uspCFR_Merge @MVDProcedureName 'uspCFR_ERVisit_Strat_272_MVDID', @CustID=16, @RuleID = 272, ProductID=2,@OwnerGroup = 159
EXEC uspCFR_Merge @MVDProcedureName 'uspCFR_ERVisit_Strat_273_MVDID', @CustID=16, @RuleID = 273, ProductID=2,@OwnerGroup = 159

EXEC uspMerge

SELECT MVDID, COUNT(*) Qty FROM CareFlowTask WHERE RuleID = 270 GROUP BY MVDID HAVING COUNT(*) > 1

*/

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @RuleID int
	DECLARE @OwnerGroup int = 168

CreateLocalTempTable:
	--the local temp table will persist between the calls of three stored procedures
	   DROP TABLE IF EXISTS CFR_Strat90_Tmp
	
		select mvdid, count(distinct claimnumber) as cnt
		into CFR_Strat90_Tmp
		from FinalClaimsHeader
		where IsNull(EmergencyIndicator,0) = 1
		and datediff(day,StatementFromDate, GetDate()) < 91
		and IsNull(AdjustmentCode,'O') != 'A'
		group by MVDID

	-- ER visit count between 1 and 4
	set @RuleID = 271
	set @OwnerGroup = 168

	--DELETE from CareFlowTask where RuleId = @RuleID and StatusId =278  -- clear out any existing entries that have not been acted on


CareFlowRule271:
--This CFR has been retired as a CFR
--EXEC uspCFR_Merge @MVDProcedureName ='uspCFR_ERVisit_Strat90_271_MVDID', @CustID=16, @RuleID = 271, @ProductID=2,@OwnerGroup = 168

CareFlowRule272:	

EXEC uspCFR_Merge @MVDProcedureName ='uspCFR_ERVisit_Strat90_272_MVDID', @CustID=16, @RuleID = 272, @ProductID=2,@OwnerGroup = 159

CareFlowRule273:

EXEC uspCFR_Merge @MVDProcedureName ='uspCFR_ERVisit_Strat90_273_MVDID', @CustID=16, @RuleID = 273, @ProductID=2,@OwnerGroup = 159


END