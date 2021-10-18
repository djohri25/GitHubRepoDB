/****** Object:  Procedure [dbo].[Set_MemberCarePlanIndex]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Set_MemberCarePlanIndex]
@CustID int,
@MVDID varchar(50),
@CPLIBRARYID int,
@CPDATE date,
@Language varchar(50),
@AUTHOR varchar(50),
@REVIEW varchar(10),
@CaseID       varchar(100) = NULL,
@pCpID int OUTPUT, 
@NoteID int = null OUTPUT

as
begin

Declare @NoteTypeID  int 

Select @NoteTypeID = CodeID from Lookup_Generic_Code GC JOIN Lookup_Generic_Code_Type  GCT ON GCT.CodeTypeID = GC.CodeTypeID Where GCT.CodeType = 'NoteType' and GC.[Label] = 'DocumentNote'

-- Insert the CarePlan Index record
INSERT INTO [dbo].[MainCarePlanIndex]
           ([Cust_ID]
           ,[MVDID]
           ,[cpLibraryID]
           ,[CarePlanDate]
                 ,[Language]
                 ,[CarePlanReview]
           ,[Author]
                 ,[CaseID])
     VALUES
           (@CustID, @MVDID, @CPLIBRARYID, @CPDATE, @Language, @REVIEW, @AUTHOR, @CaseID)

SELECT @pCpID = SCOPE_IDENTITY();

insert into [dbo].[HPAlertNote]
                     (MVDID,              
                     Note,                      
                     AlertStatusID,             
                     datecreated,         
                     createdby,                 
                     CreatedByType,             
                     datemodified,        
                     modifiedby,                
                     ModifiedByType,            
                     SendToHP,                  
                     SendToPCP,                 
                     SendToNurture,             
                     SendToNone,                
                     LinkedFormType,            
                     LinkedFormID,
					 NoteTypeID,
                     CaseID)              
       values                                   
                     (@MVDID,
                     'Care Plan Saved.',
                     0,
                     GETUTCDATE(),
                     @AUTHOR,
                     'HP',
                     GETUTCDATE(),
                     @AUTHOR,
                     'HP',
                     0,
                     0,
                     0,
                     0,
                     'CCC_CarePlan',
                     @pCpID,
					 @NoteTypeID,
                     @CaseID       )

SELECT @NoteID = SCOPE_IDENTITY();

end