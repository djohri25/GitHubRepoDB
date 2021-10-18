/****** Object:  Procedure [dbo].[Get_FormObesityCarePlanByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		BDW
-- Create date: 4/27/2016
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormObesityCarePlanByID]
@ID varchar(20)
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
	  ,[AchieveWeightReduction]
	  ,[AchieveWeightReductionDate]
	  ,[IncreaseComp]
	  ,[IncreaseCompDate]
	  ,[MemberVerbObesityPlan]
	  ,[MemberVerbObesityPlanDate]
      ,[MemberVerbMeasures]
      ,[MemberVerbMeasuresDate]   
      ,[MemberVerbDiet]
      ,[MemberVerbDietDate]
      ,[MemberVerbMeds]
      ,[MemberVerbMedsDate]
      ,[MemVerbSelfCare]
      ,[MemVerbSelfCareDate]
      ,[MemVerbCommRes]
      ,[MemVerbCommResDate]      
	  ,[MemberAvoidTobacco]
      ,[MemberAvoidTobaccoDate]
      ,[MemberAnnualFlu]
      ,[MemberAnnualFluDate]
	  ,[AssessMemKnowledge]
      ,[AssessMemUnderstanding]
      ,[PCPFollowup]
      ,[AfterHours]
      ,[ConvinientCare]
      ,[UrgentCare]
      ,[ER]
      ,[AssessSelfCare]
      ,[AssessDiet]
	  ,[ReferProgram]
      ,[ReferDieticians]
      ,[ReferCommSupport]
      ,[AssessMedComp]
	  ,[AssessImmunization]
      ,[AssessTobacco]
      ,[ReferProvider]
      ,[ReferTobacco]
      ,[ReferCardiovascular]
      ,[CommToProvider]
      ,[CommWithMemFamily]
      ,[CollWithTeam]	
	  ,[chkGG1]
      ,[chkGG2]
      ,[chkGG3]
      ,[chkGG4]
      ,[chkGG5]
      ,[chkGG6]
      ,[chkGG7]   
      ,[chkBDG1]
      ,[chkBDG2]
      ,[chkBDG3]
      ,[chkBDG4]
      ,[chkBDG5]
      ,[chkBDG6]
      ,[chkBDG7]
      ,[chkBDG8]
      ,[chkBDG9]
      ,[chkBDG10]  
      ,[chkPCP1]
      ,[chkPCP2]
      ,[chkPCP3]
      ,[chkPCP4]
      ,[chkPCP5]
      ,[chkPCP6] 
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
  FROM [FormObesityCarePlan] F
  Left JOIN MainPersonalDetails d ON d.ICENUMBER = F.MVDID
  LEFT JOIN MainInsurance m ON m.ICENUMBER = F.MVDID 
  where F.ID = @ID
  order by f.FormDate desc
END