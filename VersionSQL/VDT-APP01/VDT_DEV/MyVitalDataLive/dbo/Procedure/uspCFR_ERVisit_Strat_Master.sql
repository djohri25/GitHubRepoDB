/****** Object:  Procedure [dbo].[uspCFR_ERVisit_Strat_Master]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_ERVisit_Strat_Master] 
AS
/*
	CustID:			16
	RuleID:			268,269,270
	ProductID:		2
	OwnerGroup:		168

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to process three careflow rules to use new merge process

EXEC uspCFR_ERVisit_Strat_MVDID

This procedure will call the following three careflow rules

EXEC uspCFR_Merge @MVDProcedureName ='uspCFR_ERVisit_Strat_MVDID', @CustID=16, @RuleID = 268, @ProductID=2,@OwnerGroup = 168
EXEC uspCFR_Merge @MVDProcedureName ='uspCFR_ERVisit_Strat_MVDID', @CustID=16, @RuleID = 269, @ProductID=2,@OwnerGroup = 170
EXEC uspCFR_Merge @MVDProcedureName ='uspCFR_ERVisit_Strat_MVDID', @CustID=16, @RuleID = 270, @ProductID=2,@OwnerGroup = 170

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int
	DECLARE @OwnerGroup int

CreateLocalTempTable:

		--the local temp table will persist between the calls of three stored procedures

	      DROP TABLE IF EXISTS CFR_Strat_Tmp

		 CREATE TABLE dbo.CFR_Strat_Tmp (MVDID varchar(30), Cnt int)

         INSERT INTO dbo.CFR_Strat_Tmp (MVDID, Cnt)
		 SELECT MVDID, COUNT(DISTINCT claimnumber) AS cnt
		   FROM FinalClaimsHeader
		  WHERE ISNULL(EmergencyIndicator,0) = 1
			AND DATEDIFF(day,StatementFromDate, GETDATE()) < 365
			AND ISNULL(AdjustmentCode,'O') != 'A'
		  GROUP BY MVDID

CareFlowRule268:

	EXEC uspCFR_Merge @MVDProcedureName ='uspCFR_ERVisit_Strat268_MVDID', @CustID=16, @RuleID = 268, @ProductID=2, @OwnerGroup = 168

CareFlowRule269:
	
	EXEC uspCFR_Merge @MVDProcedureName ='uspCFR_ERVisit_Strat269_MVDID', @CustID=16, @RuleID = 269, @ProductID=2,@OwnerGroup = 170

CareFlowRule270:

	EXEC uspCFR_Merge @MVDProcedureName ='uspCFR_ERVisit_Strat270_MVDID', @CustID=16, @RuleID = 270, @ProductID=2,@OwnerGroup = 170

ProcedureEnd:

	DROP TABLE IF EXISTS CFR_Strat_Tmp

END