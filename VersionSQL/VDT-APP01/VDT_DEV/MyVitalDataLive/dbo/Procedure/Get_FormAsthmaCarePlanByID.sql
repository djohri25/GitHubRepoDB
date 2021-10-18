/****** Object:  Procedure [dbo].[Get_FormAsthmaCarePlanByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name> [Get_FormAsthmaCarePlanByID]
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================[Get_FormAsthmaCarePlanByID]
CREATE PROCEDURE [dbo].[Get_FormAsthmaCarePlanByID]
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
   ,

	
		[IncreaseKnowledge],
[IncreaseKnowledgeDate],
	[ImproveMgmt],
[ImproveMgmtDate],
	[PreventERUtil],
[PreventERUtilDate],
	[IncreaseComp],
[IncreaseCompDate],


	[MemberVerbAsthmaPlan],
[MemberVerbAsthmaPlanDate],
	[MemberIncreaseKnowledge],
[MemberIncreaseKnowledgeDate],
	[MemberAsthmaEdu],
[MemberAsthmaEduDate],
	[MemberVerb],
[MemberVerbDate],

[MemVerbAsthmaMedication],
[MemVerbAsthmaMedicationDate],

	[MeteredDose],
[MeteredDoseDate],
	[Nebulizer],
[NebulizerDate],
	[Inhaler],
[InhalerDate],
	[Drugs],
[DrugsDate],


	[Other],
[OtherDate],
	[MemVerbSelfCare],
[MemVerbSelfCareDate],
	[MemVerbCommRes],
[MemVerbCommResDate],
	[MemVerbCare],
[MemVerbCareDate],


	[MemberPeakFlow],
[MemberPeakFlowDate],
	[MemberAnnualFlu],
[MemberAnnualFluDate],
	[MemberAvoidTobacco],
[MemberAvoidTobaccoDate],
	[AssessMemKnowledge],
[AssessMemKnowledgeDate],


[AssessMemUnderstanding],
	[PCPFollowup],
	[AfterHours],
	[ConvinientCare],
[UrgentCare],

[ER],
	[AssessPast],
	[AssessMemAsthmaTrigger],
	[AssessSelfCare],

[AssessMedication],
	[AssessPeakFlow],
	[AssessImmunization],
	[AssessTobacco],

[ReferProvider],
	[ReferTobacco],
	[ReferCardiovascular],
	[RemainIndoors],

	
[WearingMask],
	[DecreaseDustInHome],
	[MaintainProgram],
	[AvoidPersonRTI],

[ControlStress],
	[AvoidDehydration],
	[AvoidCold],
	[ReceiveImmunization],


[TakeMedication],
	[StopSmoking],
	[HaveAsthmaActionPlan],
	[DecreasePeakFlow],

	
[IncreaseAgitation],
	[AsthmaAttack],
	[IncreaseMed],
	[IncreaseAsthma],

[DecreaseActivity],
	[ElevatedTemp],
	[CoughProd],
	[ContinueCare],

		[MemHealthCare]	 ,
[CommWithMemFamily],
[CommToProvider] ,





	[EstablishFreq],
	[MemDischarged],
	[MemDischargedReason],
					
	f.[Created],
	f.[CreatedBy],
	f.[ModifiedDate],
	f.[ModifiedBy],
		d.FirstName,
		d.LastName
  FROM [FormAsthmaCarePlan] F
  Left JOIN MainPersonalDetails d ON d.ICENUMBER = F.MVDID
  LEFT JOIN MainInsurance m ON m.ICENUMBER = F.MVDID 
  where F.ID = @ID
  order by f.FormDate desc
END