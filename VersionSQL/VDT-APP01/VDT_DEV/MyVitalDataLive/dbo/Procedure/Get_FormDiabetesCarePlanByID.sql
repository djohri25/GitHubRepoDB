/****** Object:  Procedure [dbo].[Get_FormDiabetesCarePlanByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		BDW
-- Create date: 4/15/2016
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormDiabetesCarePlanByID]
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
	  ,[ImproveMgmt]
	  ,[ImproveMgmtDate]
	  ,[PreventERUtil]
 	  ,[PreventERUtilDate]
	  ,[IncreaseComp]
	  ,[IncreaseCompDate]
	  ,[MemberVerbDiabetesPlan]
	  ,[MemberVerbDiabetesPlanDate]
      ,[MemberVerbHypoHyper]
      ,[MemberVerbHypoHyperDate]
      ,[MemberMaintBlood]
      ,[MemberMaintBloodDate]
      ,[MemberVerbDiet]
      ,[MemberVerbDietDate]
      ,[MemberVerbMeds]
      ,[MemberVerbMedsDate]
      ,[MemVerbSelfCare]
      ,[MemVerbSelfCareDate]
      ,[MemVerbCommRes]
      ,[MemVerbCommResDate]
      ,[MemberVerbFoot]
      ,[MemberVerbFootDate]
      ,[MemberAnnualEye]
      ,[MemberAnnualEyeDate]
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
      ,[AssessBlood]
      ,[AssessHgA1c]
      ,[AssessDiet]
      ,[AssessMedComp]
      ,[AssessFootNailSkin]
      ,[AssessFoot]
      ,[AssessEye]
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
      ,[chkGG8]
      ,[chkGG9]
      ,[chkGG10]
      ,[chkGG11]
      ,[chkGG12]
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
      ,[chkGGS1]
      ,[chkGGS2]
      ,[chkGGS3]
      ,[chkGGS4]
      ,[chkGGS5]
      ,[chkGGS6]
      ,[chkIns1]
      ,[chkIns2]
      ,[chkIns3]
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
  FROM [FormDiabetesCarePlan] F
  Left JOIN MainPersonalDetails d ON d.ICENUMBER = F.MVDID
  LEFT JOIN MainInsurance m ON m.ICENUMBER = F.MVDID 
  where F.ID = @ID
  order by f.FormDate desc
END