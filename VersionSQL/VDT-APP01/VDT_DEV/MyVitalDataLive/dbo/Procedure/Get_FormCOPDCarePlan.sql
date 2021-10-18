/****** Object:  Procedure [dbo].[Get_FormCOPDCarePlan]    Committed by VersionSQL https://www.versionsql.com ******/

-- =======================================================
-- Author:		BDW 
-- Create date: 4/15/2016
-- Description:	
-- EXEC [Get_FormCOPDCarePlan] 'AA007171', '13'
-- ========================================================

CREATE PROCEDURE [dbo].[Get_FormCOPDCarePlan]
@MVDID varchar(20), @CustID VARCHAR(20)=NULL
AS
BEGIN
	SET NOCOUNT ON;

SELECT top 1[ID]
      ,[MVDID]
      ,[CustID]
      ,[StaffInterviewing]
      ,[FormDate]
      ,[Gender]
      ,[DateOfBirth]
      ,[PLan]
      ,[ProviderIDNumber]
      ,[IncreaseKnowledge]
      ,[IncreaseKnowledgeDate]         
	  ,[ImproveMgmt]
      ,[ImproveMgmtDate]
      ,[PreventERUtil]
      ,[PreventERUtilDate]
      ,[IncreaseComp]
      ,[IncreaseCompDate]
      ,[STG1]
      ,[STG1Date]
      ,[STG2]
      ,[STG2Date]
      ,[STG3]
      ,[STG3Date]
      ,[STG4]
      ,[STG4Date]
      ,[STG5]
      ,[STG5Date]
      ,[STG6]
      ,[STG6Date]
      ,[STG7]
      ,[STG7Date]
      ,[STG8]
      ,[STG8Date]
      ,[AssessMemKnowledge]
      ,[AssessMemUnderstanding]
      ,[PCPFollowup]
      ,[AfterHours]
      ,[ConvinientCare]
      ,[UrgentCare]
      ,[ER]
      ,[AssessSelfCare]
      ,[AssessLog]
      ,[AssessDiet]
      ,[AssessMedication]
      ,[AssessImmunization]
      ,[AssessTobacco]
      ,[ReferProvider]
      ,[ReferTobacco]
      ,[ReferCardiovascular]
      ,[CommToProvider]
      ,[CommWithMemFamily]
      ,[CollWithTeam]
      ,[ME1]
      ,[ME2]
      ,[ME3]
      ,[ME4]
      ,[ME5]
      ,[ME6]
      ,[ME7]
      ,[ME8]
      ,[ME9]
      ,[ME10]
      ,[ME11]
      ,[UR1]
      ,[UR2]
	  ,[UR3]
      ,[UR4]
      ,[UR5]
      ,[UR6]
      ,[UR7]
      ,[UR8]
	  ,[ContinueCare]
      ,[EstablishFreq]
      ,[MemDischarged]
      ,[MemDischargedReason]
      ,f.[Created]
      ,f.[CreatedBy]
      ,f.[ModifiedDate]
      ,f.[ModifiedBy]
	  ,d.FirstName
	  ,d.LastName
  FROM [FormCOPDCarePlan] F
  Left JOIN MainPersonalDetails d ON d.ICENUMBER = F.MVDID
  LEFT JOIN MainInsurance m ON m.ICENUMBER = F.MVDID 
  WHERE    MVDID = @MVDID AND CustID = @CustID
  order by f.ID desc
END