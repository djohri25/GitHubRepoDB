/****** Object:  Procedure [dbo].[Get_FormAsthmaCarePlan]    Committed by VersionSQL https://www.versionsql.com ******/

-- =======================================================
-- Author:		<Author,,Name> FormAsthmaCarePlan
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- ========================================================

-- exec [Get_FormAsthmaCarePlan] 'WW099040', 13

CREATE PROCEDURE [dbo].[Get_FormAsthmaCarePlan]
@MVDID varchar(20), @CustID VARCHAR (20)=NULL

AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1[ID]
      ,F.[MVDID]
      ,F.[CustID]
      ,F.[StaffInterviewing]
      ,F.[FormDate]
      ,F.[Gender]
      ,F.[DateOfBirth]
      ,F.[PLan]
      ,F.[ProviderIDNumber],

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
[CommToProvider],





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
  WHERE    MVDID = @MVDID AND CustID = @CustID
  order by f.ID desc
END