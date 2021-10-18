/****** Object:  Procedure [dbo].[Set_FormAsthmaCarePlan]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:  <Author,,Name>
-- Create date: 5/06/2015
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_FormAsthmaCarePlan]
 @MVDID varchar(20),
 @CustID varchar(20),
 @StaffInterviewing varchar(50),
 @FormDate date,
 @Gender Char(1) ,
 @DateOfBirth datetime  ,
 @PLan varchar (50),
 @ProviderIDNumber varchar(20),

 		@IncreaseKnowledge varchar(500) =NULL ,
@IncreaseKnowledgeDate date =NULL ,
	@ImproveMgmt varchar(500) =NULL ,
@ImproveMgmtDate date =NULL ,
	@PreventERUtil varchar(500) =NULL ,
@PreventERUtilDate date =NULL ,
	@IncreaseComp varchar(500) =NULL ,
@IncreaseCompDate date =NULL ,


	@MemberVerbAsthmaPlan varchar(500) =NULL ,
@MemberVerbAsthmaPlanDate date =NULL ,
	@MemberIncreaseKnowledge varchar(500) =NULL ,
@MemberIncreaseKnowledgeDate date =NULL ,
	@MemberAsthmaEdu varchar(500) =NULL ,
@MemberAsthmaEduDate date =NULL ,
	@MemberVerb varchar(500) =NULL ,
@MemberVerbDate date =NULL ,

@MemVerbAsthmaMedication varchar(500) = null,
@MemVerbAsthmaMedicationdate date = null,

	@MeteredDose varchar(500) =NULL ,
@MeteredDoseDate date =NULL ,
	@Nebulizer varchar(500) =NULL ,
@NebulizerDate date =NULL ,
	@Inhaler varchar(500) =NULL ,
@InhalerDate date =NULL ,
	@Drugs varchar(500) =NULL ,
@DrugsDate date =NULL ,


	@Other varchar(500) =NULL ,
@OtherDate date =NULL ,
	@MemVerbSelfCare varchar(500) =NULL ,
@MemVerbSelfCareDate date =NULL ,
	@MemVerbCommRes varchar(500) =NULL ,
@MemVerbCommResDate date =NULL ,
	@MemVerbCare varchar(500) =NULL ,
@MemVerbCareDate date =NULL ,


	@MemberPeakFlow varchar(500) =NULL ,
@MemberPeakFlowDate date =NULL ,
	@MemberAnnualFlu varchar(500) =NULL ,
@MemberAnnualFluDate date =NULL ,
	@MemberAvoidTobacco varchar(500) =NULL ,
@MemberAvoidTobaccoDate date =NULL ,
	@AssessMemKnowledge varchar(500) =NULL ,
@AssessMemKnowledgeDate date =NULL ,


@AssessMemUnderstanding varchar(500) =NULL ,
	@PCPFollowup varchar(500) =NULL ,
	@AfterHours varchar(500) =NULL ,
	@ConvinientCare varchar(500) =NULL ,

@UrgentCare varchar(500) = null,

@ER varchar(500) =NULL ,
	@AssessPast varchar(500) =NULL ,
	@AssessMemAsthmaTrigger varchar(500) =NULL ,
	@AssessSelfCare varchar(500) =NULL ,

@AssessMedication varchar(500) =NULL ,
	@AssessPeakFlow varchar(500) =NULL ,
	@AssessImmunization varchar(500) =NULL ,
	@AssessTobacco varchar(500) =NULL ,

@ReferProvider varchar(500) =NULL ,
	@ReferTobacco varchar(500) =NULL ,
	@ReferCardiovascular varchar(500) =NULL ,
	@RemainIndoors varchar(500) =NULL ,

	
@WearingMask varchar(500) =NULL ,
	@DecreaseDustInHome varchar(500) =NULL ,
	@MaintainProgram varchar(500) =NULL ,
	@AvoidPersonRTI varchar(500) =NULL ,

@ControlStress varchar(500) =NULL ,
	@AvoidDehydration varchar(500) =NULL ,
	@AvoidCold varchar(500) =NULL ,
	@ReceiveImmunization varchar(500) =NULL ,


@TakeMedication varchar(500) =NULL ,
	@StopSmoking varchar(500) =NULL ,
	@HaveAsthmaActionPlan varchar(500) =NULL ,
	@DecreasePeakFlow varchar(500) =NULL ,

	
@IncreaseAgitation varchar(500) =NULL ,
	@AsthmaAttack varchar(500) =NULL ,
	@IncreaseMed varchar(500) =NULL ,
	@IncreaseAsthma varchar(500) =NULL ,

@DecreaseActivity varchar(500) =NULL ,
	@ElevatedTemp varchar(500) =NULL ,
	@CoughProd varchar(500) =NULL ,
	@ContinueCare varchar(500) =NULL ,

	@MemHealthCare varchar(500) =NULL	 ,
@CommWithMemFamily varchar(500) =NULL,
@CommToProvider varchar(500) =NULL ,



	@EstablishFreq varchar(500) =NULL ,
	@MemDischarged varchar(500) =NULL ,
	@MemDischargedReason varchar(500) =NULL ,
 @Result int = -1 output
AS
BEGIN
 SET NOCOUNT ON;

 declare @FormID int, @UserType varchar(10)

 INSERT INTO FormAsthmaCarePlan
	( 
	[MVDID]
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
					
	[Created],
	[CreatedBy],
	[ModifiedDate],
	[ModifiedBy],
	[FormType])
    VALUES
     (
		@MVDID,
		@CustID,
		@StaffInterviewing ,
		@FormDate,
		@Gender,
		Convert(varchar(10),@DateOfBirth,101),
		@PLan ,
		@ProviderIDNumber,

 		@IncreaseKnowledge,
@IncreaseKnowledgeDate,
	@ImproveMgmt,
@ImproveMgmtDate ,
	@PreventERUtil,
@PreventERUtilDate ,
	@IncreaseComp,
@IncreaseCompDate  ,


	@MemberVerbAsthmaPlan,
@MemberVerbAsthmaPlanDate  ,
	@MemberIncreaseKnowledge,
@MemberIncreaseKnowledgeDate ,
	@MemberAsthmaEdu,
@MemberAsthmaEduDate  ,
	@MemberVerb,
@MemberVerbDate  ,
@MemVerbAsthmaMedication,
@MemVerbAsthmaMedicationdate,


	@MeteredDose,
@MeteredDoseDate ,
	@Nebulizer,
@NebulizerDate ,
	@Inhaler,
@InhalerDate  ,
	@Drugs,
@DrugsDate  ,


	@Other,
@OtherDate ,
	@MemVerbSelfCare,
@MemVerbSelfCareDate ,
	@MemVerbCommRes,
@MemVerbCommResDate ,
	@MemVerbCare,
@MemVerbCareDate ,


	@MemberPeakFlow,
@MemberPeakFlowDate ,
	@MemberAnnualFlu,
@MemberAnnualFluDate,
	@MemberAvoidTobacco,
@MemberAvoidTobaccoDate,
	@AssessMemKnowledge,
@AssessMemKnowledgeDate ,


@AssessMemUnderstanding,
	@PCPFollowup,
	@AfterHours,
	@ConvinientCare,

@UrgentCare,
@ER,
	@AssessPast,
	@AssessMemAsthmaTrigger,
	@AssessSelfCare,

@AssessMedication,
	@AssessPeakFlow,
	@AssessImmunization,
	@AssessTobacco,

@ReferProvider,
	@ReferTobacco,
	@ReferCardiovascular,
	@RemainIndoors,

	
@WearingMask,
	@DecreaseDustInHome,
	@MaintainProgram,
	@AvoidPersonRTI,

@ControlStress,
	@AvoidDehydration,
	@AvoidCold,
	@ReceiveImmunization,


@TakeMedication,
	@StopSmoking,
	@HaveAsthmaActionPlan,
	@DecreasePeakFlow,

	
@IncreaseAgitation,
	@AsthmaAttack,
	@IncreaseMed,
	@IncreaseAsthma,

@DecreaseActivity,
	@ElevatedTemp,
	@CoughProd,
	@ContinueCare,

@MemHealthCare	 ,
@CommWithMemFamily,
@CommToProvider ,


	@EstablishFreq,
	@MemDischarged,
	@MemDischargedReason,
 
		@FormDate,
		@StaffInterviewing,
		GETDATE(),
		@StaffInterviewing,
		'ACP'
  )
     
    declare @insMemberID varchar(20), @noteText varchar(1000)
     
     select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
     select @noteText = 'Form Asthma Care Plan Saved. '

  if exists(select top 1 * from MDUser where Username =  @StaffInterviewing)
     begin
  set @UserType = 'MD'
 end
 else
 begin
  set @UserType = 'HP'  
 end
 select @FormID = @@IDENTITY

 insert into HPAlertNote (MVDID,Note,AlertStatusID,datecreated,createdby,CreatedByType,
  datemodified,modifiedby,ModifiedByType,SendToHP,SendToPCP,SendToNurture,SendToNone,LinkedFormType,LinkedFormID)
 values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'ACP',@FormID)

    
     set @Result = @FormID
END