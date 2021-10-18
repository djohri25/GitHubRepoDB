/****** Object:  Procedure [dbo].[uspInsertMMFormCaseConversion]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Spaitereddy
-- Create date: 05/15/2019
-- MODIFIED: 05/20/2019 -- added Hp alert note procedure 
-- MODIFIED: 07/10/2019 -- added Sectioncompleted update statement 
-- MODIFIED: 07/24/2019 -- added Set @Isactive=' | Active |'
--						   Set @Note= @CaseProgram+@Isactive+@Note
-- Description:	Inserts into MemberReferral Table based on input values
-- Execution: exec dbo.uspInsertMMFormCaseConversion
-- dpatel - added parent referralid to insert mmf proc
--================================================


CREATE  procedure [dbo].[uspInsertMMFormCaseConversion] 
(
	@ParentDocID bigint, -- This is the ID for the MMFORM,
	@CaseCloseFLG int, --This indicates if the case is closed
	@CustomerId int,
	@ProductId int,
	@NewFormOwner varchar(100)
)

AS 
BEGIN 
	
	--Assigning default user 
	declare  
		@MVDID varchar(30), 
		@CreatedDate datetime,
		@Owner VARCHAR(100),
		@formOwner varchar(100),
		@ReferralId bigint,
		@ReferralDate datetime,
		@TaskSource varchar(150),
		@ReferralExternal varchar(50)='Yes',
		@ReferralSource varchar(50),
		@CaseProgram varchar(max),
		@NonViableReason varchar(100)='Case Conversion',
		@AUTHOR VARCHAR(100),
		@ParentReferralID Varchar(max),
		@IsCaseConversion varchar(5)='Yes',
		@Inprogress varchar(10),
		@q15AssignTo varchar(100),
		@CaseOwner Varchar(100),
		
		@DocID bigint,
		@CheckAssignment bit, -- 0=N, 1=Y
		@MemberId varchar(50),
		@StatusId int, 
		@taskID bigint,
		@NewTaskId int,
		@PriorityId int,
		@Title nvarchar(100)='Case Converted',
		@Narrative nvarchar(max)='A new Member Management Form has been created for the member',
		@TypeId int,
		@FormID bigint,
		@TaskStatus varchar(50),
		@TaskPriority varchar(50),
		@TaskType varchar(50),
		@FormName varchar(255),
		@UserType varchar(2)='HP',
		@Note varchar(255)='Member Management Form For Case Conversion Saved',
		@Result int,
		@Isactive varchar(50),
		@HistoryFormID bigint 

		--both Owner for task and form; and Author for form and task will be set to NewFormOwner
		set @Owner = @NewFormOwner
		set @formOwner = @NewFormOwner
		set @AUTHOR = @NewFormOwner
	
	
	if (@CaseCloseFLG = 1)
		Begin
	
			--select top 1 @MVDID = mvdid, @CaseProgram=q4CaseProgram, @ParentReferralID=ReferralID, @Owner=ReferralOwner, @AUTHOR=FormAuthor, 
			--			 @CaseOwner=isnull(q1CaseOwner,q16CareQ)
			--from dbo.ABCBS_MemberManagement_Form where id = @ParentDocID and ltrim(rtrim(qCloseCase))='Yes'

			select top 1 @MVDID = MVDID, @CaseProgram=q4CaseProgram, @ParentReferralID=ReferralID, @ReferralSource = ReferralSource, @TaskSource = ReferralReason,
						@ReferralExternal = ReferralExternal,
						@CaseOwner = case 
										when q1CaseOwner is not null and LTRIM(RTRIM(q1CaseOwner)) <> '' then LTRIM(RTRIM(q1CaseOwner)) 
										else LTRIM(RTRIM(ReferralOwner)) 
									 end
			from dbo.ABCBS_MemberManagement_Form where id = @ParentDocID and ltrim(rtrim(qCloseCase))='Yes'
			
			
			--select @MemberId= InsMemberId from link_memberid_mvd_ins where mvdid=@MVDID and Cust_ID=@CustomerId 
			select @MemberId = MemberID from ComputedCareQueue where MVDID = @MVDID
			
			--select @CheckAssignment= CheckAssignment , @TaskSource=TaskSource from memberreferral where  Id=@ParentReferralID
			
			if (@TaskType is not null)
				Begin
				select @TypeId= codeid from dbo.LOOKUP_GENERIC_CODE where codetypeid =15 and LTRIM(rtrim(Label))=LTRIM(rtrim(@TaskType))
				End 
			else 
				Begin 
				select  @TypeId= codeid from dbo.LOOKUP_GENERIC_CODE where codetypeid =15 and LTRIM(rtrim(Label))='Referral'
				End
			
			if (@TaskPriority is not null)
				Begin
				select @PriorityId= codeid from dbo.LOOKUP_GENERIC_CODE where codetypeid =14 and LTRIM(rtrim(Label))=LTRIM(rtrim(@TaskPriority))
				End 
			else 
				Begin 
				select  @PriorityId= codeid from dbo.LOOKUP_GENERIC_CODE where codetypeid =14 and LTRIM(rtrim(Label))='Medium'
				End
			
			if (@TaskStatus is not null)
				Begin
				select @StatusId= codeid from dbo.LOOKUP_GENERIC_CODE where codetypeid =13 and LTRIM(rtrim(Label))=LTRIM(rtrim(@TaskStatus))
				End 
			else 
				Begin 
				select  @StatusId= codeid from dbo.LOOKUP_GENERIC_CODE where codetypeid =13 and LTRIM(rtrim(Label))='New'
				End
			
			
				Set @CreatedDate =GETUTCDATE()
				set @ParentReferralID = cast(@ParentReferralID as bigint)
				set @ReferralDate = GETUTCDATE()
			
			
			--Insert into MemberReferral 
			EXECUTE  [dbo].[uspInsertMemberReferral] 
			   @DocID=null  --This would be null for the first time / Update later
			  ,@ParentDocID=@ParentDocID -- Not null
			  ,@MemberID=@MemberID --not null
			  ,@TaskID=null --This would be null for the first time / Update later
			  ,@TaskSource=@TaskSource --not null
			  ,@CaseProgram=@CaseProgram --not null
			  ,@ParentReferralID=@ParentReferralID --Not null/ has parent 
			  ,@NonViableReason=@NonViableReason --Not null/ has parent 
			  ,@CreatedDate=@CreatedDate --not null
			  ,@CreatedBy=@Author --not null 
			  ,@CheckAssignment=@CheckAssignment --not null
			  ,@Cust_ID=@CustomerId --not null
			  ,@ReferralId  =@ReferralId OUTPUT --not null 
			
			
			--Create New Task
			EXECUTE [dbo].[Set_UserTask] 
			   @Title=@Title
			  ,@Narrative=@Narrative
			  ,@MVDID=@MVDID
			  ,@CustomerId=@CustomerId
			  ,@ProductId=@ProductId
			  ,@Author=@Author
			  ,@Owner=@Owner--@formOwner        --******************* Check Who is the Form Owner? which field/ some case may be "@formowner"
			  ,@CREATEDDATE=@CreatedDate
			  --,@DueDate=@DueDate
			  ,@StatusId=@StatusId
			  ,@PriorityId=@PriorityId
			  ,@TypeId=@TypeId
			  ,@NewTaskId =@NewTaskId OUTPUT
			
			
			set @ReferralId = cast(@ReferralId as varchar(max))
			set @CreatedDate = GETUTCDATE()
			Set @Inprogress= 'No'
						
			
			--Create a new member management form
			EXECUTE [dbo].[uspInsertABCBSMemberManagementForm] 
			   @MVDID=@MVDID
			  ,@CreatedDate=@CreatedDate
			  ,@Owner=@Owner
			  ,@ReferralId=@ReferralId
			  ,@ReferralDate=@ReferralDate
			  ,@TaskSource=@TaskSource
			  ,@ReferralExternal=@ReferralExternal
			  ,@ReferralSource=@ReferralSource
			  ,@CaseProgram=@CaseProgram
			  ,@NonViableReason=@NonViableReason
			  ,@formAuthor=@AUTHOR
			  ,@ParentReferralID=@ParentReferralID
			  ,@IsCaseConversion=@IsCaseConversion
			  ,@Inprogress=@Inprogress
			  --,@q15AssignTo=@q15AssignTo
			  ,@q15AssignTo='User'
			  ,@qViableReason = 'Yes'
			  ,@q19AssignedUser = @Owner
			  ,@FormID=@FormID OUTPUT
			
			Update ABCBS_MemberManagement_Form
			set SectionCompleted='1'
			where id=@FormID
			
			update ABCBS_MMFHistory_Form set SectionCompleted = '1'
			where OriginalFormID = @FormID
			select @HistoryFormID = ID from ABCBS_MMFHistory_Form where OriginalFormID = @FormID

			--Update pending fields
			EXECUTE [dbo].[uspUpdateMemberReferral] 
			   @ReferralID=@ReferralId
			  ,@DocID=@FormID  --Every time a form is created "@FormID" needs to go into the update
			  ,@TaskID=@NewTaskId --Every time a Task is created "@NewTaskId" needs to go into the update

			

			Set @Isactive=' | Active | '
			Set @Note= @CaseProgram+@Isactive+@Note
			
			
			select @FormName=ProcedureName from LookupCS_MemberNoteForms where FormName='Member Management'
			
		
			EXECUTE [dbo].[Set_HPAlertNoteForForm] 
			   @MVDID=@mvdid
			  ,@Owner=@Author
			  ,@UserType=@UserType
			  ,@Note=@Note
			 -- ,@FormID=@FormName
			 ,@FormID = 'ABCBS_MMFHistory'
			  ,@MemberFormID=@HistoryFormID
			  ,@StatusID=0
			  ,@CaseID=null
			  ,@Result=@Result OUTPUT
		End
END