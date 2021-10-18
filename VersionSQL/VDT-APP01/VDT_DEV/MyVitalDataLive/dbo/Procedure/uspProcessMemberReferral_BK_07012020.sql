/****** Object:  Procedure [dbo].[uspProcessMemberReferral_BK_07012020]    Committed by VersionSQL https://www.versionsql.com ******/

--=====================================================================  
-- Author:		Spaitereddy
-- Create date: 07/25/2019
-- MODIFIED: --changed @lockFormFLG from 3 to 4 , 07/25/2019, spaitereddy
-- Description:	Inserts into MemberReferral Table based on input values
--09/04/2019 - dpatel - Updated proc for proper indentation.
--10/24/2019 - dpatel - Updated proc to find appropriate CareQ as an owner if input owner is Admission AutoQ.
--01/03/2020 - dpatel - Updated proc to find InActive member and process referral request.
-- Execution:

--Declare 
--@CustomerId int = 10,
--@MemberId varchar(50) = '708161081',
--@Title nvarchar(100) = 'Start Case management',
--@Narrative nvarchar(max) = 'Member has contacted regarding some chronic conditions. Start member management and probably case management after consent.',
--@Author varchar(100) = null,
--@Owner varchar(100) = 'dpatel',
--@CreatedDate datetime =getutcdate(),
-- @duedate datetime = (getutcdate() +10),
--@TaskStatus varchar(50)= 'New',
--@TaskPriority varchar(50) = 'Medium' ,
--@TaskType varchar(50) = 'Referral',
--@TaskSource varchar(150) = 'Precert/Prenote',
--@CheckAssignment bit = 1, -- 0=N, 1=Y
--@CaseProgram varchar(150) = 'Chronic Condition Management',
--@ProductId int = 2,
--@referralid bigint


--EXECUTE  [dbo].[uspProcessMemberReferral] 
--   @CustomerId=@CustomerId
--  ,@MemberId=@MemberId
--  ,@Title=@Title
--  ,@Narrative=@Narrative
--  ,@Author=@Author
--  ,@Owner=@Owner
--  ,@CreatedDate=@CreatedDate
--  ,@DueDate=@DueDate
--  ,@TaskStatus=@TaskStatus
--  ,@TaskPriority=@TaskPriority
--  ,@TaskType=@TaskType
--  ,@TaskSource=@TaskSource
--  ,@CheckAssignment=@CheckAssignment
--  ,@CaseProgram=@CaseProgram
--  ,@ProductId=@ProductId
--  ,@referralid=@referralid output
--=====================================================================


CREATE   procedure [dbo].[uspProcessMemberReferral_BK_07012020] 
(
	@CustomerId int,
	@MemberId varchar(50),
	@Title nvarchar(100),
	@Narrative nvarchar(max) ,
	@Author varchar(100) =null,
	@Owner varchar(100),
	@CreatedDate datetime =null,
	@DueDate datetime =null,
	@TaskStatus varchar(50)= null,
	@TaskPriority varchar(50) = null ,
	@TaskType varchar(50) = null,
	@TaskSource varchar(150),	--ReferralReason parameter from web-service
	@CheckAssignment bit =null, -- 0=N, 1=Y
	@ReferralSource varchar(50) =null, 
	@CaseProgram varchar(150),
	@ProductId int,
	@LOB varchar(50)= null,
	@ReferralId bigint output,
	@NewTaskId bigint OUTPUT,
	@FormID bigint OUTPUT
)
AS 
BEGIN TRY

	SET NOCOUNT ON

	--Assigning default user 
	declare  
		 -- @ReferralId int,
		 @Nurse varchar(100),
		 @MVDID varchar(30), 
		 @StatusId int =Null, 
		 --@NewTaskId int,
		 @PriorityId int =null,
		 @TypeId int,
		 @ParentDocID int,
		 @IsCaseConversion varchar(5),
		 @ReferralDate datetime,
		 --@FormID bigint,
		 @ReferralExternal varchar(50)='Yes',
		 @NonViableReason varchar(100),
		 @ParentReferralID varchar(max),
		 @InitializationFLG varchar(1) ='0',
		 @ReferralFLG varchar(1) ='1',
		 @lockFormFLG varchar(1) ='4', --changed this from 3 to 4
		 @InProgress varchar(50),
		 @formOwner varchar(100),
		 @MMFCaseProgram varchar(150),
		 @UserType varchar(2)='HP',
		 @Isactive varchar(50),
		 @Note varchar(max)=' Member Management Form Saved',
		 @FormName varchar(255),
		 @Result int,
		 --@CareQName varchar(100),
		 @AssignTO Varchar(100),
		 @HistoryFormID bigint
		 --@ReferralSource varchar(50)='External'  -- Need to be added as input parameter

	--Set @ReferralSource
	if @ReferralSource is null
		Begin
			set @ReferralSource='External'
		End 

	if exists (select MVDID from ComputedCareQueue where MemberID = @MemberId and LOB = @LOB)-- and Isactive = 1)
		begin
			select @MVDID = MVDID
			from ComputedCareQueue 
			where MemberID = @MemberId 
				and LOB = @LOB 
				--and Isactive = 1
		end
	else
		begin
			RAISERROR('Member not found.', 16, 1)
		end

	--Set FormName 
	select @FormName=ProcedureName from LookupCS_MemberNoteForms where FormName='Member Management' and active=1

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

	If @Author is null 
		set @Author='System'

	--set an owner based on member's CMOrgRegion if input owner is Admission AutoQ
	if LTRIM(RTRIM(@Owner)) = 'Admission AutoQ'
		begin
			select @Owner = dbo.Get_CareQForAdmissionAutoQ(@MVDID)
		end

	--**************************************************************************************************
	--if Check Assignment FLG is "N"
	If (@CheckAssignment =0)
		Begin
			if exists (select 1 from dbo.[ABCBS_MemberManagement_Form] where MVDID=@MVDID and CaseProgram=@CaseProgram 
					   and InProgress='No' and ISNULL(qCloseCase,'No') <> 'Yes' and CAST(SectionCompleted as int) < 3 )-- Active MMF exists =yes 
				Begin		
					select top 1 @ParentDocID= Id, @IsCaseConversion =CaseConversion, @NonViableReason=NonViableReason,
								 @ParentReferralID=ReferralID, 
								 @formOwner = case 
												when q1CaseOwner is not null and LTRIM(RTRIM(q1CaseOwner)) <> '' then LTRIM(RTRIM(q1CaseOwner)) 
												else LTRIM(RTRIM(ReferralOwner)) 
											  end, 
								 @MMFCaseProgram=CaseProgram
					from dbo.[ABCBS_MemberManagement_Form] 
					where MVDID=@MVDID and CaseProgram=@CaseProgram and InProgress='No' --and q3Convo='Yes' 
						and ISNULL(qCloseCase,'No') <> 'Yes' and CAST(SectionCompleted as int) < 3
					order by id  
		
					--Update the Previous "In Progess" to Yes since the form Exists 
					--Update ABCBS_MemberManagement_Form
					--set InProgress='Yes'
					--where id=@ParentDocID
							
					--***************************************************************************************************************************
					--For case conversion "yes"  and nonviableReason as "Case Conversion"
					IF (ltrim(rtrim(@IsCaseConversion))='Yes' and ltrim(rtrim(@NonViableReason))='Case Conversion' 
					and ltrim(Rtrim(@MMFCaseProgram))=ltrim(Rtrim(@CaseProgram)))
						Begin 
							if 	@ParentReferralID is null 
								select top 1  @ParentReferralID = cast(Id as varchar(max)) from MemberReferral where docid = @ParentDocID order by id  
			
		
							--*******  Check is NonViableReason is from PrevForm or Default as "Referral"
		
							set @ParentReferralID=cast(@ParentReferralID as bigint)
							set @CreatedDate= getutcdate()
							
								--Insert into MemberReferral 
							EXECUTE  [dbo].[uspInsertMemberReferral] 
							   @DocID=null  --This would be null for the first time / Update later
							  ,@ParentDocID=@ParentDocID --If parent exists, always "yes" for current case 
							  ,@MemberID=@MemberID --not null
							  ,@TaskID=null --This would be null for the first time / Update later
							  ,@TaskSource=@TaskSource --not null
							  ,@CaseProgram=@CaseProgram --not null
							  ,@ParentReferralID=@ParentReferralID -- For parent form when form exits , always "yes" for current case 
							  ,@NonViableReason=@NonViableReason --If parent exists, always "yes" for current case 
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
							  ,@Owner=@Owner        --******************* dpatel- Check if Form Owner is correct? Should form owner be owner from task web-service? Yes, owner will always be from web-service.
							  ,@CREATEDDATE=@CreatedDate
							  ,@DueDate=@DueDate
							  ,@StatusId=@StatusId
							  ,@PriorityId=@PriorityId
							  ,@TypeId=@TypeId
							  ,@NewTaskId =@NewTaskId OUTPUT
							
							
							set @ReferralId = cast(@ReferralId as varchar(max))
							set @ParentReferralID = cast(@ParentReferralID as varchar(max))
							Set @IsCaseConversion = 'Yes'
							Set @InProgress= 'Yes'
							
							
							--Create a new member management form
							EXECUTE [dbo].[uspInsertABCBSMemberManagementForm] 
							   @MVDID=@MVDID
							  ,@CreatedDate=@CreatedDate
							  ,@FormAuthor=@Author
							  ,@Owner=@Owner			--dpatel- Check if Form Owner is correct? Should form owner be owner from task web-service? Yes, owner will always be from web-service.
							  ,@ReferralId=@ReferralId
							  ,@ReferralDate=@CreatedDate
							  ,@TaskSource=@TaskSource
							  ,@ReferralExternal=@ReferralExternal
							  ,@ReferralSource=@ReferralSource
							  ,@CaseProgram=@CaseProgram
							  ,@NonViableReason=@NonViableReason  
							  ,@IsCaseConversion=@IsCaseConversion
							  ,@ParentReferralID=@ParentReferralID
							  ,@InProgress=@InProgress
							  ,@qNonViableReason = 'Referral/Case Already Open'
							  ,@FormID=@FormID OUTPUT
							

							--Update pending fields
							EXECUTE [dbo].[uspUpdateMemberReferral] 
							   @ReferralID=@ReferralId
							  ,@DocID=@FormID  --Every time a form is created "@FormID" needs to go into the update
							  ,@TaskID=@NewTaskId --Every time a Task is created "@NewTaskId" needs to go into the update
							  ,@ParentReferralID=@ParentReferralID -- For parent form when form exits , always "yes" for current case 
							  ,@NonViableReason=@NonViableReason --If parent exists, always "yes" for current case 
							  ,@ParentDocID=@ParentDocID --If parent exists, always "yes" for current case 
		 

							--Lock the section of the form / Initialization is complete
							UPDATE [ABCBS_MemberManagement_Form]
							--set SectionCompleted=@InitializationFLG		--dpatel - should it be @referralflg? since we have to skip to section 3/Consent
							set SectionCompleted=@lockFormFLG
							where id = @FormID

							-- History log for MMF
							UPDATE [ABCBS_MMFHistory_Form]							
							set SectionCompleted=@lockFormFLG
							where OriginalFormID = @FormID
		
							select @HistoryFormID = ID from ABCBS_MMFHistory_Form where OriginalFormID = @FormID
						
							Set @Isactive=' | Locked |'
							Set @Note= @CaseProgram+@Isactive+@Note
							
							--Insert into HPAlert
							EXECUTE [dbo].[Set_HPAlertNoteForForm] 
							   @MVDID=@mvdid
							  ,@Owner=@Author
							  ,@UserType=@UserType
							  ,@Note=@Note
							  --,@FormID=@FormName
							  ,@FormID='ABCBS_MMFHistory'
							  ,@MemberFormID=@HistoryFormID
							  ,@StatusID=0
							  ,@CaseID=null
							  ,@Result=@Result OUTPUT
						
						End 
					--***************************************************************************************************************************
					
					
					--***************************************************************************************************************************
					--For Case Conversion "No" and Member form Already Exist
					IF (ltrim(rtrim(@IsCaseConversion))='No')
						Begin
							if 	@ParentReferralID is null 
								select top 1  @ParentReferralID = cast(Id as varchar(max)) from MemberReferral where docid = @ParentDocID order by id  
							
							Set @NonViableReason= 'Referral/Case Already Open'
							set @ParentReferralID=cast(@ParentReferralID as bigint)
							set @CreatedDate= getutcdate()
		
							--Insert into MemberReferral 
							EXECUTE  [dbo].[uspInsertMemberReferral] 
							   @DocID=null  --This would be null for the first time / Update later
							  ,@ParentDocID=@ParentDocID -- --This would be null for the first time / This case not null Parent exists
							  ,@MemberID=@MemberID --not null
							  ,@TaskID=null --This would be null for the first time / Update later
							  ,@TaskSource=@TaskSource --not null
							  ,@CaseProgram=@CaseProgram --not null
							  ,@ParentReferralID=@ParentReferralID -- --This would be null for the first time / This case not null Parent exists
							  ,@NonViableReason=@NonViableReason ----This would be null for the first time / This case not null Parent exists
							  ,@CreatedDate=@CreatedDate --not null
							  ,@CreatedBy=@Author --not null 
							  ,@CheckAssignment=@CheckAssignment --not null
							  ,@Cust_ID=@CustomerId --not null
							  ,@ReferralId  =@ReferralId OUTPUT --not null 
		
							--select * from [ABCBS_MemberManagement_Form]
		
							--Create Task
							EXECUTE [dbo].[Set_UserTask] 
							   @Title=@Title
							  ,@Narrative=@Narrative
							  ,@MVDID=@MVDID
							  ,@CustomerId=@CustomerId
							  ,@ProductId=@ProductId
							  ,@Author=@Author
							  ,@Owner=@Owner        --dpatel- Check if Form Owner is correct? Should form owner be owner from task web-service? Yes, owner will always be from web-service.
							  ,@CREATEDDATE=@CreatedDate
							  ,@DueDate=@DueDate
							  ,@StatusId=@StatusId
							  ,@PriorityId=@PriorityId
							  ,@TypeId=@TypeId
							  ,@NewTaskId =@NewTaskId OUTPUT
		
							--Insert a new member management form
		   					select @ReferralDate= createddate from memberreferral where id =@ReferralId
							set @ReferralId = cast(@ReferralId as varchar(max))
							set @ParentReferralID = cast(@ParentReferralID as varchar(max))
							Set @IsCaseConversion='No'
							Set @InProgress='Yes'
							
							
							EXECUTE [dbo].[uspInsertABCBSMemberManagementForm] 
							   @MVDID=@MVDID
							  ,@CreatedDate=@CreatedDate
							  ,@Owner=@Owner			--dpatel- Check if Form Owner is correct? Should form owner be owner of existing active form? Yes, owner will always be from web-service.
							  ,@FormAuthor=@Author
							  ,@ReferralId=@ReferralId
							  ,@ReferralDate=@ReferralDate
							  ,@TaskSource=@TaskSource
							  ,@ReferralExternal=@ReferralExternal
							  ,@ReferralSource=@ReferralSource
							  ,@CaseProgram=@CaseProgram
							  --,@NonViableReason=@NonViableReason		--No need to have non-viable reason in Init section
							  ,@IsCaseConversion=@IsCaseConversion
							  ,@ParentReferralID=@ParentReferralID
							  ,@InProgress=@InProgress
							  ,@qNonViableReason = 'Referral/Case Already Open'
							  ,@FormID=@FormID OUTPUT
							

							--Update pending fields
							EXECUTE [dbo].[uspUpdateMemberReferral] 
							   @ReferralID=@ReferralId
							  ,@DocID=@FormID  --Every time a form is created "@FormID" needs to go into the update
							  ,@TaskID=@NewTaskId --Every time a Task is created "@NewTaskId" needs to go into the update
							  ,@ParentReferralID=@ParentReferralID -- For parent form when form exits , always "yes" for current case 
							  ,@NonViableReason=@NonViableReason --If parent exists, always "yes" for current case 
							  ,@ParentDocID=@ParentDocID --If parent exists, always "yes" for current case 
							
							--Lock the whole form 
							UPDATE [ABCBS_MemberManagement_Form]
							set SectionCompleted=@lockFormFLG
							where id = @FormID

							-- History log for MMF
							UPDATE [ABCBS_MMFHistory_Form]							
							set SectionCompleted=@lockFormFLG
							where OriginalFormID = @FormID
		
							select @HistoryFormID = ID from ABCBS_MMFHistory_Form where OriginalFormID = @FormID

							Set @Isactive=' | Locked |'
							Set @Note= @CaseProgram+@Isactive+@Note
		
							--Insert into HPAlert
							EXECUTE [dbo].[Set_HPAlertNoteForForm] 
							   @MVDID=@mvdid
							  ,@Owner=@Author
							  ,@UserType=@UserType
							  ,@Note=@Note
							  --,@FormID=@FormName
							  ,@FormID='ABCBS_MMFHistory'
							  ,@MemberFormID=@HistoryFormID
							  ,@StatusID=0
							  ,@CaseID=null
							  ,@Result=@Result OUTPUT
						End
					--***************************************************************************************************************************
				End
		
			--No Member form exists at this point 
			If not exists (select 1 from dbo.[ABCBS_MemberManagement_Form] where MVDID=@MVDID and CaseProgram=@CaseProgram and InProgress='No' 
							and ISNULL(qCloseCase,'No') <> 'Yes' and CAST(SectionCompleted as int) < 3)	--active MMF doesnt exist for MVDID + CaseProgram
				Begin 
					
					set @CreatedDate=getutcdate()
		
					--Insert into MemberReferral 
					EXECUTE  [dbo].[uspInsertMemberReferral] 
					   @DocID=null
					  ,@ParentDocID=null
					  ,@MemberID=@MemberID
					  ,@TaskID=null
					  ,@TaskSource=@TaskSource
					  ,@CaseProgram=@CaseProgram
					  ,@ParentReferralID=null
					  ,@NonViableReason=null
					  ,@CreatedDate=@CreatedDate
					  ,@CreatedBy=@Author
					  ,@CheckAssignment=@CheckAssignment
					  ,@Cust_ID=@CustomerId
					  ,@ReferralId  =@ReferralId OUTPUT
					
					--Insert into Task, TaskActivity Log 
					--Create Task
					EXECUTE [dbo].[Set_UserTask] 
					   @Title=@Title
					  ,@Narrative=@Narrative
					  ,@MVDID=@MVDID
					  ,@CustomerId=@CustomerId
					  ,@ProductId=@ProductId
					  ,@Author=@Author
					  ,@Owner=@Owner
					  ,@CREATEDDATE=@CreatedDate
					  ,@DueDate=@DueDate
					  ,@StatusId=@StatusId
					  ,@PriorityId=@PriorityId
					  ,@TypeId=@TypeId
					  ,@NewTaskId =@NewTaskId OUTPUT
		
					select @ReferralDate=createddate from MemberReferral where Id=@ReferralId
					set @ReferralId = cast(@ReferralId as varchar(max))
					set @CreatedDate = GETUTCDATE()
					Set @IsCaseConversion='No'
					set @InProgress='No'
		
		
					--Create a new member management form
					EXECUTE [dbo].[uspInsertABCBSMemberManagementForm] 
					   @MVDID=@MVDID
					  ,@CreatedDate=@CreatedDate
					  ,@Owner=@Owner
					  ,@FormAuthor=@Author
					  ,@ReferralId=@ReferralId
					  ,@ReferralDate=@ReferralDate
					  ,@TaskSource=@TaskSource
					  ,@ReferralExternal=@ReferralExternal
					  ,@ReferralSource=@ReferralSource
					  ,@CaseProgram=@CaseProgram
					  ,@IsCaseConversion=@IsCaseConversion
					  ,@NonViableReason=@NonViableReason
					  ,@InProgress=@InProgress
					  ,@FormID=@FormID OUTPUT
		
					--Update pending fields
					EXECUTE [dbo].[uspUpdateMemberReferral] 
					   @ReferralID=@ReferralId
					  ,@DocID=@FormID  --Every time a form is created "@FormID" needs to go into the update
					  ,@TaskID=@NewTaskId --Every time a Task is created "@NewTaskId" needs to go into the update
					
					  
					Update ABCBS_MemberManagement_Form
					set Sectioncompleted=@InitializationFLG
					where id=@formid

					-- History log for MMF
					UPDATE [ABCBS_MMFHistory_Form]							
					set SectionCompleted=@InitializationFLG
					where OriginalFormID = @FormID
		
					select @HistoryFormID = ID from ABCBS_MMFHistory_Form where OriginalFormID = @FormID
					
					Set @Isactive=' | Active |'
					Set @Note= @CaseProgram+@Isactive+@Note
		
					--Insert into HPAlert
					EXECUTE [dbo].[Set_HPAlertNoteForForm] 
					   @MVDID=@mvdid
					  ,@Owner=@Author
					  ,@UserType=@UserType
					  ,@Note=@Note
					  --,@FormID=@FormName
					  ,@FormID='ABCBS_MMFHistory'
					  ,@MemberFormID=@HistoryFormID
					  ,@StatusID=0
					  ,@CaseID=null
					  ,@Result=@Result OUTPUT
				End

			--dpatel - if owner of task and MMF should be as Owner from task web-service and if value is Admission AutoQ then run logic to update owner to appropriate queue
			--dpatel - 10/24/2019 this check is happening at the start to prevent multiple inserts and updates
			--if LTRIM(RTRIM(@Owner)) = 'Admission AutoQ'
			--	begin
			--		exec usp_UpdateMemberManagementFormOwner @ReferralId
			--	end
		End 

	IF (@CHECKASSIGNMENT = 1 )
		begin
			--CHECK IF THE FORM EXISTS. current FormOwner or CaseOwner will be the Owner for new form and task.
			if exists (select 1 from dbo.[ABCBS_MemberManagement_Form] where MVDID=@MVDID and CaseProgram=@CaseProgram and InProgress='No'
						and ISNULL(qCloseCase,'No') <> 'Yes' and CAST(SectionCompleted as int) < 3)-- active MMF exists for MVDID + CaseProgram
				Begin
					select top 1 @ParentDocID= Id, @IsCaseConversion =CaseConversion, @NonViableReason=NonViableReason,
								 @ParentReferralID=ReferralID, 
								 @formOwner = case 
												when q1CaseOwner is not null and LTRIM(RTRIM(q1CaseOwner)) <> '' then LTRIM(RTRIM(q1CaseOwner)) 
												else LTRIM(RTRIM(ReferralOwner)) 
											  end, 
								 @MMFCaseProgram=CaseProgram
					from dbo.[ABCBS_MemberManagement_Form] 
					where MVDID=@MVDID and CaseProgram=@CaseProgram and InProgress='No' --and q3Convo='Yes'
						and ISNULL(qCloseCase,'No') <> 'Yes' and CAST(SectionCompleted as int) < 3
					order by id

					--Update ABCBS_MemberManagement_Form
					--set InProgress='Yes'
					--where id=@ParentDocID

					--***************************************************************************************************************************
					--For case conversion "yes"  and nonviableReason as "Case Conversion"
					IF (ltrim(rtrim(@IsCaseConversion))='Yes' and ltrim(rtrim(@NonViableReason))='Case Conversion' and ltrim(Rtrim(@MMFCaseProgram))=ltrim(Rtrim(@CaseProgram)))
						Begin 
							
							if 	@ParentReferralID is null 
							select top 1  @ParentReferralID = cast(Id as varchar(max)) from MemberReferral where docid = @ParentDocID order by id desc 

							--*******  Check is NonViableReason is from PrevForm or Default as "Referral"
							
							set @ParentReferralID=cast(@ParentReferralID as bigint)
							set @CreatedDate= getutcdate()
							
								--Insert into MemberReferral 
							EXECUTE  [dbo].[uspInsertMemberReferral] 
							   @DocID=null  --This would be null for the first time / Update later
							  ,@ParentDocID=@ParentDocID --If parent exists, always "yes" for current case 
							  ,@MemberID=@MemberID --not null
							  ,@TaskID=null --This would be null for the first time / Update later
							  ,@TaskSource=@TaskSource --not null
							  ,@CaseProgram=@CaseProgram --not null
							  ,@ParentReferralID=@ParentReferralID -- For parent form when form exits , always "yes" for current case 
							  ,@NonViableReason=@NonViableReason --If parent exists, always "yes" for current case 
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
							  ,@Owner=@formOwner        --******************* Check Who is the Form Owner? which field/ some case may be "@formowner". Onwer of current active MMF will be the owner.
							  ,@CREATEDDATE=@CreatedDate
							  ,@DueDate=@DueDate
							  ,@StatusId=@StatusId
							  ,@PriorityId=@PriorityId
							  ,@TypeId=@TypeId
							  ,@NewTaskId =@NewTaskId OUTPUT

							select @ReferralDate= createddate from memberreferral where id =@ReferralId
							set @ReferralId = cast(@ReferralId as varchar(max))
							set @ParentReferralID = cast(@ParentReferralID as varchar(max))
							Set @IsCaseConversion = 'Yes'
							Set @InProgress= 'Yes'

							--Create a new member management form
							EXECUTE [dbo].[uspInsertABCBSMemberManagementForm] 
							   @MVDID=@MVDID
							  ,@CreatedDate=@CreatedDate
							  ,@FormAuthor=@Author
							  ,@Owner=@formOwner		--Check if Form Owner is correct? Onwer of current active MMF will be the owner.
							  ,@ReferralId=@ReferralId
							  ,@ReferralDate=@ReferralDate
							  ,@TaskSource=@TaskSource
							  ,@ReferralExternal=@ReferralExternal
							  ,@ReferralSource=@ReferralSource
							  ,@CaseProgram=@CaseProgram
							  ,@NonViableReason=@NonViableReason  
							  ,@IsCaseConversion=@IsCaseConversion
							  ,@ParentReferralID=@ParentReferralID
							  ,@InProgress=@InProgress
							  ,@qNonViableReason = 'Referral/Case Already Open'
							  ,@FormID=@FormID OUTPUT
							
							--Update pending fields
							EXECUTE [dbo].[uspUpdateMemberReferral] 
							   @ReferralID=@ReferralId
							  ,@DocID=@FormID  --Every time a form is created "@FormID" needs to go into the update
							  ,@TaskID=@NewTaskId --Every time a Task is created "@NewTaskId" needs to go into the update
							  --,@ParentReferralID=@ParentReferralID -- For parent form when form exits , always "yes" for current case 
							  --,@NonViableReason=@NonViableReason --If parent exists, always "yes" for current case 
							  --,@ParentDocID=@ParentDocID --If parent exists, always "yes" for current case 
							 
							
							--Lock the section of the form / Initialization is complete
							UPDATE [ABCBS_MemberManagement_Form]
							set SectionCompleted=@lockFormFLG
							where id = @FormID

							-- History log for MMF
							UPDATE [ABCBS_MMFHistory_Form]							
							set SectionCompleted=@lockFormFLG
							where OriginalFormID = @FormID
		
							select @HistoryFormID = ID from ABCBS_MMFHistory_Form where OriginalFormID = @FormID

							Set @Isactive=' | Locked |'
							Set @Note= @CaseProgram+@Isactive+@Note
							
							
							--Insert into HPAlert
							EXECUTE [dbo].[Set_HPAlertNoteForForm] 
							   @MVDID=@mvdid
							  ,@Owner=@Author
							  ,@UserType=@UserType
							  ,@Note=@Note
							  --,@FormID=@FormName
							  ,@FormID='ABCBS_MMFHistory'
							  ,@MemberFormID=@HistoryFormID
							  ,@StatusID=0
							  ,@CaseID=null
							  ,@Result=@Result OUTPUT
						End 
					--***************************************************************************************************************************

					--***************************************************************************************************************************
					--For Case Conversion "No" and Member form Already Exist
					IF (ltrim(rtrim(@IsCaseConversion))='No')
						Begin
							if 	@ParentReferralID is null 
								select top 1  @ParentReferralID = cast(Id as varchar(max)) from MemberReferral where docid = @ParentDocID order by id desc 

						    Set @NonViableReason= 'Referral/Case Already Open'
							set @ParentReferralID=cast(@ParentReferralID as bigint)
							set @CreatedDate= getutcdate()

							--Insert into MemberReferral 
							EXECUTE  [dbo].[uspInsertMemberReferral] 
							   @DocID=null  --This would be null for the first time / Update later
							  ,@ParentDocID=@ParentDocID -- --This would be null for the first time / This case not null Parent exists
							  ,@MemberID=@MemberID --not null
							  ,@TaskID=null --This would be null for the first time / Update later
							  ,@TaskSource=@TaskSource --not null
							  ,@CaseProgram=@CaseProgram --not null
							  ,@ParentReferralID=@ParentReferralID -- --This would be null for the first time / This case not null Parent exists
							  ,@NonViableReason=@NonViableReason ----This would be null for the first time / This case not null Parent exists
							  ,@CreatedDate=@CreatedDate --not null
							  ,@CreatedBy=@Author --not null 
							  ,@CheckAssignment=@CheckAssignment --not null
							  ,@Cust_ID=@CustomerId --not null
							  ,@ReferralId  =@ReferralId OUTPUT --not null 
							
							--select * from [ABCBS_MemberManagement_Form]

							--Create Task
							EXECUTE [dbo].[Set_UserTask] 
							   @Title=@Title
							  ,@Narrative=@Narrative
							  ,@MVDID=@MVDID
							  ,@CustomerId=@CustomerId
							  ,@ProductId=@ProductId
							  ,@Author=@Author
							  ,@Owner=@formOwner        --  Onwer of current active MMF will be the owner.
							  ,@CREATEDDATE=@CreatedDate
							  ,@DueDate=@DueDate
							  ,@StatusId=@StatusId
							  ,@PriorityId=@PriorityId
							  ,@TypeId=@TypeId
							  ,@NewTaskId =@NewTaskId OUTPUT

							--Insert a new member management form
   							select @ReferralDate= createddate from memberreferral where id =@ReferralId
							set @ReferralId = cast(@ReferralId as varchar(max))
							set @ParentReferralID = cast(@ParentReferralID as varchar(max))
							Set @IsCaseConversion='No'
							Set @InProgress= 'Yes'

							EXECUTE [dbo].[uspInsertABCBSMemberManagementForm] 
							   @MVDID=@MVDID
							  ,@CreatedDate=@CreatedDate
							  ,@Owner=@formOwner		--  Onwer of current active MMF will be the owner.
							  ,@FormAuthor=@Author
							  ,@ReferralId=@ReferralId
							  ,@ReferralDate=@ReferralDate
							  ,@TaskSource=@TaskSource
							  ,@ReferralExternal=@ReferralExternal
							  ,@ReferralSource=@ReferralSource
							  ,@CaseProgram=@CaseProgram
							  --,@NonViableReason=@NonViableReason
							  ,@IsCaseConversion=@IsCaseConversion
							  ,@ParentReferralID=@ParentReferralID
							  ,@InProgress=@InProgress
							  ,@qNonViableReason = 'Referral/Case Already Open'
							  ,@FormID=@FormID OUTPUT

							--Update pending fields
							EXECUTE [dbo].[uspUpdateMemberReferral] 
							   @ReferralID=@ReferralId
							  ,@DocID=@FormID  --Every time a form is created "@FormID" needs to go into the update
							  ,@TaskID=@NewTaskId --Every time a Task is created "@NewTaskId" needs to go into the update
							  ,@ParentReferralID=@ParentReferralID -- For parent form when form exits , always "yes" for current case 
							  ,@NonViableReason=@NonViableReason --If parent exists, always "yes" for current case 
							  ,@ParentDocID=@ParentDocID --If parent exists, always "yes" for current case 
							
							
							--Lock the whole form 
							UPDATE [ABCBS_MemberManagement_Form]
							set SectionCompleted=@lockFormFLG
							where id = @FormID
							
							-- History log for MMF
							UPDATE [ABCBS_MMFHistory_Form]							
							set SectionCompleted=@lockFormFLG
							where OriginalFormID = @FormID
		
							select @HistoryFormID = ID from ABCBS_MMFHistory_Form where OriginalFormID = @FormID

							Set @Isactive=' | Locked |'
							Set @Note= @CaseProgram+@Isactive+@Note
							
							--Insert into HPAlert
							EXECUTE [dbo].[Set_HPAlertNoteForForm] 
							   @MVDID=@mvdid
							  ,@Owner=@Author
							  ,@UserType=@UserType
							  ,@Note=@Note
							  --,@FormID=@FormName
							  ,@FormID='ABCBS_MMFHistory'
							  ,@MemberFormID=@HistoryFormID
							  ,@StatusID=0
							  ,@CaseID=null
							  ,@Result=@Result OUTPUT
						End
			End
			--***************************************************************************************************************************
			--End
	
			--NO MEMBER FORM EXISTS AT THIS POINT 
			If not exists (select 1 from dbo.[ABCBS_MemberManagement_Form] where MVDID=@MVDID and CaseProgram=@CaseProgram and InProgress='No'
							and ISNULL(qCloseCase,'No') <> 'Yes' and CAST(SectionCompleted as int) < 3)	--active MMF doesn't exist for MVDID + CaseProgram
				Begin 
					--check for Primary MemberOwner. If found then Primary will be form and task owner, otherwise Owner from web-service will be form and task owner
					if exists (select 1 from Final_MemberOwner where MVDID = @MVDID and OwnerType = 'Primary' and IsDeactivated = 0)
						begin
							select top 1 @Nurse = OwnerName 
							from Final_MemberOwner 
							where MVDID = @MVDID 
								and OwnerType = 'Primary' 
								and IsDeactivated = 0
							order by StartDate desc

							if @Nurse is not null and LTRIM(RTRIM(@Nurse)) <> ''
								begin
									set @formOwner = @Nurse
								end
							else
								begin
									set @formOwner = @Owner
								end
						end
					else
						begin
							set @formOwner = @Owner
						end

					set @CreatedDate=getutcdate()

					--Insert into MemberReferral 
					EXECUTE  [dbo].[uspInsertMemberReferral] 
					   @DocID=null
					  ,@ParentDocID=null
					  ,@MemberID=@MemberID
					  ,@TaskID=null
					  ,@TaskSource=@TaskSource
					  ,@CaseProgram=@CaseProgram
					  ,@ParentReferralID=null
					  ,@NonViableReason=null
					  ,@CreatedDate=@CreatedDate
					  ,@CreatedBy=@Author
					  ,@CheckAssignment=@CheckAssignment
					  ,@Cust_ID=@CustomerId
					  ,@ReferralId  =@ReferralId OUTPUT
					
					
					--Insert into Task, TaskActivity Log 
					--Create Task
					EXECUTE [dbo].[Set_UserTask] 
					   @Title=@Title
					  ,@Narrative=@Narrative
					  ,@MVDID=@MVDID
					  ,@CustomerId=@CustomerId
					  ,@ProductId=@ProductId
					  ,@Author=@Author
					  ,@Owner=@formOwner			--Owner from the web-service
					  ,@CREATEDDATE=@CreatedDate
					  ,@DueDate=@DueDate
					  ,@StatusId=@StatusId
					  ,@PriorityId=@PriorityId
					  ,@TypeId=@TypeId
					  ,@NewTaskId =@NewTaskId OUTPUT

					select @ReferralDate=createddate from MemberReferral where Id=@ReferralId
					set @ReferralId = cast(@ReferralId as varchar(max))
					Set @IsCaseConversion='No'
					set @InProgress='No'

					--Create a new member management form
					EXECUTE [dbo].[uspInsertABCBSMemberManagementForm] 
					   @MVDID=@MVDID
					  ,@CreatedDate=@CreatedDate
					  ,@Owner=@formOwner			--Owner from the web-service
					  ,@FormAuthor=@Author
					  ,@ReferralId=@ReferralId
					  ,@ReferralDate=@ReferralDate
					  ,@TaskSource=@TaskSource
					  ,@ReferralExternal=@ReferralExternal
					  ,@ReferralSource=@ReferralSource
					  ,@CaseProgram=@CaseProgram
					  ,@IsCaseConversion=@IsCaseConversion
					  --,@NonViableReason=@NonViableReason
					  ,@InProgress=@InProgress
					  --,@q15AssignTo=@AssignTO
					  ,@FormID=@FormID OUTPUT
  					
  
					--Update pending fields
					EXECUTE [dbo].[uspUpdateMemberReferral] 
					   @ReferralID=@ReferralId
					  ,@DocID=@FormID  --Every time a form is created "@FormID" needs to go into the update
					  ,@TaskID=@NewTaskId --Every time a Task is created "@NewTaskId" needs to go into the update


					Update ABCBS_MemberManagement_Form
					set Sectioncompleted=@InitializationFLG
					where id=@formid

					-- History log for MMF
					UPDATE [ABCBS_MMFHistory_Form]							
					set SectionCompleted=@InitializationFLG
					where OriginalFormID = @FormID
		
					select @HistoryFormID = ID from ABCBS_MMFHistory_Form where OriginalFormID = @FormID

					--owner of task and MMF should be as Owner from task web-service and if value is Admission AutoQ then run logic to update owner to appropriate queue
					--if LTRIM(RTRIM(@formOwner)) = 'Admission AutoQ'
					--	begin
					--		exec usp_UpdateMemberManagementFormOwner @ReferralId
					--	end

					
					Set @Isactive=' | Active |'
					Set @Note= @CaseProgram+@Isactive+@Note
					
					--Insert into HP AlertNote
					EXECUTE [dbo].[Set_HPAlertNoteForForm] 
					   @MVDID=@mvdid
					  ,@Owner=@Author
					  ,@UserType=@UserType
					  ,@Note=@Note
					  --,@FormID=@FormName
					  ,@FormID='ABCBS_MMFHistory'
					  ,@MemberFormID=@HistoryFormID
					  ,@StatusID=0
					  ,@CaseID=null
					  ,@Result=@Result OUTPUT
					
			End
		End 
	
--	exec usp_UpdateMemberManagementFormOwner @ReferralId

END TRY
BEGIN CATCH
	THROW
END CATCH