/****** Object:  Procedure [dbo].[Set_FormParklandSenseHealthSurvey]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		BDW
-- Create date: 6/15/2016
-- Description: 
-- =============================================

-- exec [Set_FormParklandSenseHealthSurvey] 'GW439227','1','Staff', '04/19/2016', '04/19/1962', '992795739299','Bruce Wexler', 'Bruce', 'Wexler', 'High', 'Yes', '06/01/2016', 'English', 1, '123-123-1234'
-- select * from FormSenseHealthSurvey

CREATE PROCEDURE [dbo].[Set_FormParklandSenseHealthSurvey]
		   @MVDID varchar(20),
           @CustID varchar(20),
           @StaffInterviewing varchar(60),
           @FormDate date,      
           @DateOfBirth date,
           @ProviderIDNumber varchar(30),
           @Nurtur_CM_Name varchar(50),
		   @Member_Name varchar(50),		   
		   @PCCI_Risk_Score varchar(50),
		   @Consent_Status varchar(50),
		   @Consent_Date datetime,
		   @Preferred_Language varchar(50),
		   @Number_Of_Calls int,
		   @Updated_Phone_Number varchar(15),		   
		   @Result int = -1 output
AS
BEGIN
 SET NOCOUNT ON;

 declare @FormID int, @UserType varchar(10)

 INSERT INTO FormSenseHealthSurvey
		   ([MVDID]
           ,[CustID]
           ,[StaffInterviewing]
           ,[FormDate]
           ,[DateOfBirth]
           ,[ProviderIDNumber]
           ,[Nurtur_CM_Name]
		   ,[Member_Name]
		   ,[PCCI_Risk_Score]
		   ,[Consent_Status]
		   ,[Consent_Date]
		   ,[Preferred_Language]
		   ,[Number_Of_Calls]
		   ,[Updated_Phone_Number]
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
	  ,Convert(varchar(10),@DateOfBirth,101) 
	  ,@ProviderIDNumber
	  ,@Nurtur_CM_Name
	  ,@Member_Name
	  ,@PCCI_Risk_Score
	  ,@Consent_Status
	  ,@Consent_Date
	  ,@Preferred_Language
	  ,@Number_Of_Calls
	  ,@Updated_Phone_Number
	  ,@FormDate
	  ,@StaffInterviewing
	  ,GETDATE()
	  ,@StaffInterviewing
      ,'PHSF'
	  )    

	  declare @insMemberID varchar(20), @noteText varchar(1000)
	  select @insMemberID = InsMemberId from Link_MemberId_MVD_Ins where MVDId = @MVDID
	  select @noteText = 'Form Sense Health Survey Saved. '

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
 values(@MVDID,@noteText,0,GETUTCDATE(),@StaffInterviewing,@UserType,GETUTCDATE(),@StaffInterviewing,@UserType,0,0,0,0,'PHSF',@FormID)
    
     set @Result = @FormID
END