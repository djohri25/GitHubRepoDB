/****** Object:  Procedure [dbo].[Set_FormCHFCarePlan]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		BDW
-- Create date: 5/6/2016
-- Description: 
-- =============================================

-- exec [Set_FormCHFCarePlan] 'GW439227','1','Staff', '4/19/2016', 'M', '4/19/1962', 'IT Test Plan 1', '992795739299'
-- select * from Set_FormCHFCarePlan

CREATE PROCEDURE [dbo].[Set_FormCHFCarePlan]
		   @MVDID varchar(20),
           @CustID varchar(20),
           @StaffInterviewing varchar(60),
           @FormDate date,
           @Gender char(1),
           @DateOfBirth date,
           @PLan varchar(50),
           @ProviderIDNumber varchar(30),
           @IncreaseKnowledge varchar(500)=NULL,
           @IncreaseKnowledgeDate date=NULL,
           @ImproveMgmt varchar(500)=NULL,
           @ImproveMgmtDate date=NULL,
           @PreventERUtil varchar(500)=NULL,
           @PreventERUtilDate date=NULL,
           @IncreaseComp varchar(500)=NULL,
           @IncreaseCompDate date=NULL,
           @STG1 varchar(500)=NULL,
           @STG1Date date=NULL,
           @STG2 varchar(500)=NULL,
           @STG2Date date=NULL,
           @STG3 varchar(500)=NULL,
           @STG3Date date=NULL,
           @STG4 varchar(500)=NULL,
           @STG4Date date=NULL,
           @STG5 varchar(500)=NULL,
           @STG5Date date=NULL,
           @STG6 varchar(500)=NULL,
           @STG6Date date=NULL,
           @STG7 varchar(500)=NULL,
           @STG7Date date=NULL,
           @STG8 varchar(500)=NULL,
           @STG8Date date=NULL,
           @AssessMemKnowledge varchar(500)=NULL,
           @AssessMemUnderstanding varchar(500)=NULL,
           @PCPFollowup varchar(500)=NULL,
           @AfterHours varchar(500)=NULL,
           @ConvinientCare varchar(500)=NULL,
           @UrgentCare varchar(500)=NULL,
           @ER varchar(500)=NULL,
           @AssessSelfCare varchar(500)=NULL,
           @AssessLog varchar(500)=NULL,
           @AssessDiet varchar(500)=NULL,
           @AssessMedication varchar(500)=NULL,
           @AssessImmunization varchar(500)=NULL,
           @AssessTobacco varchar(500)=NULL,
           @ReferProvider varchar(500)=NULL,
           @ReferTobacco varchar(500)=NULL,
           @ReferCardiovascular varchar(500)=NULL,
           @CommToProvider varchar(500)=NULL,
           @CommWithMemFamily varchar(500)=NULL,
           @CollWithTeam varchar(500)=NULL,
           @ME1 varchar(500)=NULL,
           @ME2 varchar(500)=NULL,
           @ME3 varchar(500)=NULL,
           @ME4 varchar(500)=NULL,
           @ME5 varchar(500)=NULL,
           @ME6 varchar(500)=NULL,
           @ME7 varchar(500)=NULL,
           @ME8 varchar(500)=NULL,
           @ME9 varchar(500)=NULL,
           @UR1 varchar(500)=NULL,
           @UR2 varchar(500)=NULL,
           @UR3 varchar(500)=NULL,
		   @UR4 varchar(500)=NULL,
           @UR5 varchar(500)=NULL,
           @UR6 varchar(500)=NULL,
           @UR7 varchar(500)=NULL,
           @UR8 varchar(500)=NULL,  
		   @ContinueCare varchar(500)=NULL,
		   @EstablishFreq varchar(500)=NULL,
		   @MemDischarged varchar(500)=NULL,
		   @MemDischargedReason varchar(500)=NULL,       
		   @Result int = -1 output
AS
BEGIN
 SET NOCOUNT ON;

 declare @FormID int, @UserType varchar(10)

 INSERT INTO FormCHFCarePlan
		   ([MVDID]
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
           ,[Created]
           ,[CreatedBy]
           ,[ModifiedDate]
           ,[ModifiedBy]
           ,[FormType])
    VALUES
      (
	   @MVDID
	  ,@CustID
	  ,@StaffInterviewing
	  ,@FormDate
	  ,@Gender
	  ,Convert(varchar(10),@DateOfBirth,101)
	  ,@PLan 
	  ,@ProviderIDNumber
 	  ,@IncreaseKnowledge
	  ,@IncreaseKnowledgeDate
	  ,@ImproveMgmt
	  ,@ImproveMgmtDate
	  ,@PreventERUtil
	  ,@PreventERUtilDate
	  ,@IncreaseComp
	  ,@IncreaseCompDate
	  ,@STG1
	  ,@STG1Date
      ,@STG2
	  ,@STG2Date
      ,@STG3
	  ,@STG3Date
      ,@STG4
	  ,@STG4Date
      ,@STG5
	  ,@STG5Date
      ,@STG6
	  ,@STG6Date
      ,@STG7
	  ,@STG7Date
      ,@STG8
	  ,@STG8Date
	  ,@AssessMemKnowledge
      ,@AssessMemUnderstanding
      ,@PCPFollowup
      ,@AfterHours
      ,@ConvinientCare
      ,@UrgentCare
      ,@ER
      ,@AssessSelfCare
      ,@AssessLog
      ,@AssessDiet
      ,@AssessMedication
      ,@AssessImmunization
      ,@AssessTobacco
      ,@ReferProvider
      ,@ReferTobacco
      ,@ReferCardiovascular
      ,@CommToProvider
      ,@CommWithMemFamily
      ,@CollWithTeam
	  ,@ME1
	  ,@ME2
	  ,@ME3
	  ,@ME4
	  ,@ME5
	  ,@ME6
	  ,@ME7
	  ,@ME8
	  ,@ME9
	  ,@UR1
	  ,@UR2
	  ,@UR3
	  ,@UR4
	  ,@UR5
	  ,@UR6
	  ,@UR7
	  ,@UR8      
	  ,@ContinueCare
	  ,@EstablishFreq
	  ,@MemDischarged
	  ,@MemDischargedReason		
	  ,@FormDate
	  ,@StaffInterviewing
	  ,GETDATE()
	  ,@StaffInterviewing
      ,'CHF'
	  )

    declare @insMemberID varchar(20), @noteText varchar(1000)
    select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
    select @noteText = 'Form CHF Care Plan Saved. '

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
 values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'CHF',@FormID)
    
     set @Result = @FormID
END