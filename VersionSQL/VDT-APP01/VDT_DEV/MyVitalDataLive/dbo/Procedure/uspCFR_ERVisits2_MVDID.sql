/****** Object:  Procedure [dbo].[uspCFR_ERVisits2_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_ERVisits2_MVDID] 
AS
/*

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	Created by refactor of original to call uspCFR_Merge
Scott	2021-09-07	Add query hints for Computed Care Queue
EXEC uspCFR_ERVisits_New2

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_ERVisits_New2', @CustID = 16, @RuleID = 200, @ProductID = 2, @OwnerGroup= 159

*/
BEGIN
	SET NOCOUNT ON;

declare @r12date varchar(6)

select @r12date = max(monthid) from ComputedMemberTotalPaidClaimsRollling12

--insert into CareFlowTask (  [MVDID]  ,[RuleId]  ,[CreatedDate]  ,[CreatedBy]  ,[ProductId]  ,[CustomerId]  ,[StatusId]  ,[OwnerGroup]  ,[ExpirationDate]  )  
	SELECT MVDID
	    --   ,200
		   --,GETDATE()
		   --,'WORKFLOW'
		   --,2
		   --,16
		   --,278
		   --,159
		   --,'99991231'  
	 FROM (
   SELECT FM.MVDID, COUNT(visitdate) as cnt
	 FROM FinalMember FM
	 LEFT OUTER JOIN ComputedMemberEncounterHistory (READUNCOMMITTED) EC on EC.MVDID = FM.MVDID   
	 LEFT OUTER JOIN ComputedCareQueue (READUNCOMMITTED) CCQ on CCQ.MVDID = FM.MVDID
	 LEFT OUTER JOIN ComputedMemberTotalPaidClaimsRollling12 (READUNCOMMITTED) r12 on r12.MVDID = FM.MVDID
	WHERE CCQ.Isactive = 1 
	  AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
	  AND ISNULL(FM.COBCD,'U') in ('S','N','U')
	  AND ISNULL(FM.CompanyKey,'0000') != '1338'
	  AND EC.VisitType = 'ER' 
	  AND EC.VisitDate > DATEADD(YEAR,-1,GetDate()) 
	  AND FM.CustID = 16 
	  AND r12.MonthID=@r12date 
	  AND r12.HighDollarClaim=1
	GROUP BY FM.MVDID) ME
	WHERE cnt > 3

END