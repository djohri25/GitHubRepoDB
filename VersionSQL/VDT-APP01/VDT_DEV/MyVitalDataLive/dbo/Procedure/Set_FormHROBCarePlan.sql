/****** Object:  Procedure [dbo].[Set_FormHROBCarePlan]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		BDW
-- Create date: 4/15/2016
-- Description: 
-- =============================================

-- exec [Set_FormHROBCarePlan] 'GW439227','1','Staff', '4/19/2016', 'M', '4/19/1962', 'IT Test Plan 1', '992795739299'
-- select * from FormHROBCarePlan

CREATE PROCEDURE [dbo].[Set_FormHROBCarePlan]
@MVDID varchar(20),
@CustID varchar(20),
@StaffInterviewing varchar(60),
@FormDate date,
@Gender Char(1) ,
@DateOfBirth datetime,
@PLan varchar (50),
@ProviderIDNumber varchar(20),
@IncreaseKnowledge varchar(500)=NULL,
@IncreaseKnowledgeDate date=NULL,
@IncreaseComp varchar(500)=NULL,
@IncreaseCompDate date=NULL,
@SuccessOutcome varchar(500)=NULL,
@SuccessOutcomeDate date=NULL,
@MemberVerbPlan varchar(500)=NULL,
@MemberVerbPlanDate date=NULL,
@MemberVerbCompl varchar(500)=NULL,
@MemberVerbComplDate date=NULL,
@MemberVerbMeds varchar(500)=NULL,
@MemberVerbMedsDate date=NULL,
@MemVerbSelfCare varchar(500)=NULL,
@MemVerbSelfCareDate date=NULL,
@MemVerbCommRes varchar(500)=NULL,
@MemVerbCommResDate date=NULL,
@MemberAvoidTobacco varchar(500)=NULL,
@MemberAvoidTobaccoDate date=NULL,
@MemberAvoidAlcohol varchar(500)=NULL,
@MemberAvoidAlcoholDate date=NULL,
@MemberAvoidDrugs varchar(500)=NULL,
@MemberAvoidDrugsDate date=NULL,
@MemberAnnualFlu varchar(500)=NULL,
@MemberAnnualFluDate date=NULL,
@MemberTDAP varchar(500)=NULL,
@MemberTDAPDate date=NULL,
@AssessMemKnowledge varchar(500)=NULL,
@AssessMemUnderstanding varchar(500)=NULL,
@PCPFollowup varchar(500)=NULL,
@AfterHours varchar(500)=NULL,
@ConvinientCare varchar(500)=NULL,
@UrgentCare varchar(500)=NULL,
@ER varchar(500)=NULL,
@AssessSelfCare varchar(500)=NULL,
@AssessDiet varchar(500)=NULL,
@ReferWIC varchar(500)=NULL,
@ReferCommSupport varchar(500)=NULL,
@AssessMedComp varchar(500)=NULL,
@Assess17P varchar(500)=NULL,
@AssessTobacco varchar(500)=NULL,
@ReferTobacco varchar(500)=NULL,
@ReferProvider varchar(500)=NULL,
@AssessAlcoholDrugs varchar(500)=NULL,
@ReferBHP varchar(500)=NULL,
@CommToProvider varchar(500)=NULL,
@CommWithMemFamily varchar(500)=NULL,
@CollWithTeam varchar(500)=NULL,			 
@chkGG1 varchar(500)=NULL,
@chkGG2 varchar(500)=NULL,
@chkGG3 varchar(500)=NULL,
@chkGG4 varchar(500)=NULL,
@chkGG5 varchar(500)=NULL,
@chkGG6 varchar(500)=NULL,
@chkBDG1 varchar(500)=NULL,
@chkBDG2 varchar(500)=NULL,
@chkBDG3 varchar(500)=NULL,
@chkBDG4 varchar(500)=NULL,
@chkBDG5 varchar(500)=NULL,
@chkBDG6 varchar(500)=NULL,
@chkBDG7 varchar(500)=NULL,
@chkBDG8 varchar(500)=NULL,
@chkBDG9 varchar(500)=NULL,
@chkBDG10 varchar(500)=NULL,
@chkPCP1 varchar(500)=NULL,
@chkPCP2 varchar(500)=NULL,
@chkPCP3 varchar(500)=NULL,
@chkPCP4 varchar(500)=NULL,
@chkPCP5 varchar(500)=NULL,
@chkPCP6 varchar(500)=NULL,
@chkPCP7 varchar(500)=NULL,
@chkPCP8 varchar(500)=NULL,
@chkPCP9 varchar(500)=NULL,
@chkPCP10 varchar(500)=NULL,
@chkPCP11 varchar(500)=NULL,
@chkPCP12 varchar(500)=NULL,
@chkPCP13 varchar(500)=NULL,
@chkPCP14 varchar(500)=NULL,
@chkPCP15 varchar(500)=NULL,
@ContinueCare varchar(500)=NULL,
@EstablishFreq varchar(500)=NULL,
@MemDischarged varchar(500)=NULL,
@MemDischargedReason varchar(500)=NULL,

@Result int = -1 output
AS
BEGIN
 SET NOCOUNT ON;

 declare @FormID int, @UserType varchar(10)

 INSERT INTO FormHROBCarePlan
	(  MVDID
	  ,CustID
	  ,StaffInterviewing
	  ,FormDate
	  ,Gender
	  ,DateOfBirth
	  ,[PLan]
	  ,ProviderIDNumber
	  ,[IncreaseKnowledge]
	  ,[IncreaseKnowledgeDate]
	  ,[IncreaseComp]
	  ,[IncreaseCompDate]
	  ,[SuccessOutcome]
	  ,[SuccessOutcomeDate]
	  ,[MemberVerbPlan]
	  ,[MemberVerbPlanDate]
	  ,[MemberVerbCompl]
	  ,[MemberVerbComplDate]
      ,[MemberVerbMeds]
      ,[MemberVerbMedsDate]
      ,[MemVerbSelfCare]
      ,[MemVerbSelfCareDate]
      ,[MemVerbCommRes]
      ,[MemVerbCommResDate]
	  ,[MemberAvoidTobacco]
	  ,[MemberAvoidTobaccoDate]
	  ,[MemberAvoidAlcohol]
	  ,[MemberAvoidAlcoholDate]
	  ,[MemberAvoidDrugs]
	  ,[MemberAvoidDrugsDate]
	  ,[MemberAnnualFlu]
	  ,[MemberAnnualFluDate]
	  ,[MemberTDAP]
	  ,[MemberTDAPDate]
	  ,[AssessMemKnowledge]
      ,[AssessMemUnderstanding]
      ,[PCPFollowup]
      ,[AfterHours]
      ,[ConvinientCare]
      ,[UrgentCare]
      ,[ER]
      ,[AssessSelfCare]
      ,[AssessDiet]
	  ,[ReferWIC]
	  ,[ReferCommSupport]
      ,[AssessMedComp]
      ,[Assess17P]
      ,[AssessTobacco]
      ,[ReferTobacco]	  
      ,[ReferProvider]
	  ,[AssessAlcoholDrugs]
	  ,[ReferBHP]
      ,[CommToProvider]
      ,[CommWithMemFamily]
      ,[CollWithTeam]
	  ,[chkGG1]
      ,[chkGG2]
      ,[chkGG3]
      ,[chkGG4]
      ,[chkGG5]
      ,[chkGG6]    
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
	  ,[chkPCP7]
	  ,[chkPCP8]
	  ,[chkPCP9]
	  ,[chkPCP10]
	  ,[chkPCP11]
	  ,[chkPCP12]
	  ,[chkPCP13]
	  ,[chkPCP14]
	  ,[chkPCP15]
	  ,[ContinueCare]
	  ,[EstablishFreq]
	  ,[MemDischarged]
	  ,[MemDischargedReason]		
	  ,Created
	  ,CreatedBy
	  ,ModifiedDate
	  ,ModifiedBy
	  ,FormType)
    VALUES
     (
	    @MVDID, 
		@CustID,  
		@StaffInterviewing,
		@FormDate,
		@Gender,
		@DateOfBirth,
		@PLan,
		@ProviderIDNumber,  
		@IncreaseKnowledge,  
		@IncreaseKnowledgeDate,  
		@IncreaseComp, 
		@IncreaseCompDate,  
		@SuccessOutcome,  
		@SuccessOutcomeDate,  
		@MemberVerbPlan,  
		@MemberVerbPlanDate,  
		@MemberVerbCompl,  
		@MemberVerbComplDate,  
		@MemberVerbMeds,  
		@MemberVerbMedsDate,
		@MemVerbSelfCare,  
		@MemVerbSelfCareDate,  
		@MemVerbCommRes,  
		@MemVerbCommResDate,  
		@MemberAvoidTobacco,  
		@MemberAvoidTobaccoDate,  
		@MemberAvoidAlcohol,  
		@MemberAvoidAlcoholDate,  
		@MemberAvoidDrugs,  
		@MemberAvoidDrugsDate,  
		@MemberAnnualFlu,  
		@MemberAnnualFluDate,  
		@MemberTDAP,  
		@MemberTDAPDate,  
		@AssessMemKnowledge,  
		@AssessMemUnderstanding,  
		@PCPFollowup,  
		@AfterHours,  
		@ConvinientCare,  
		@UrgentCare,  
		@ER,  
		@AssessSelfCare,  
		@AssessDiet,  
		@ReferWIC,  
		@ReferCommSupport,  
		@AssessMedComp,  
		@Assess17P,  
		@AssessTobacco,  
		@ReferTobacco,  
		@ReferProvider,  
		@AssessAlcoholDrugs,  
		@ReferBHP,  
		@CommToProvider,  
		@CommWithMemFamily, 
		@CollWithTeam,  			 
		@chkGG1,  
		@chkGG2, 
		@chkGG3,  
		@chkGG4,  
		@chkGG5,  
		@chkGG6,  
		@chkBDG1,  
		@chkBDG2,  
		@chkBDG3,  
		@chkBDG4,  
		@chkBDG5,  
		@chkBDG6,  
		@chkBDG7,  
		@chkBDG8,  
		@chkBDG9,  
		@chkBDG10,  
		@chkPCP1,  
		@chkPCP2,  
		@chkPCP3,  
		@chkPCP4,  
		@chkPCP5,  
		@chkPCP6,  
		@chkPCP7, 
		@chkPCP8, 
		@chkPCP9, 
		@chkPCP10, 
		@chkPCP11, 
		@chkPCP12, 
		@chkPCP13, 
		@chkPCP14, 
		@chkPCP15, 
		@ContinueCare,
	    @EstablishFreq,
	    @MemDischarged,
	    @MemDischargedReason,		
	    @FormDate,
	    @StaffInterviewing,
	    GETDATE(),
	    @StaffInterviewing,
	   'OBCP'
  )
    declare @insMemberID varchar(20), @noteText varchar(1000)
     
    select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
    select @noteText = 'Form HROB Care Plan Saved. '

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
 values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'OBCP',@FormID)
    
     set @Result = @FormID
END