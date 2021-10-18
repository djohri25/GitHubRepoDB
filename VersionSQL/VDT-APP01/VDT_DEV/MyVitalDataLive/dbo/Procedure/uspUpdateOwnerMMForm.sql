/****** Object:  Procedure [dbo].[uspUpdateOwnerMMForm]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Spaitereddy
-- Create date: 07/09/2019
-- MODIFIED: 
-- Description:	Updates the MMFORM Owner Table based on MMFORM ID
-- Execution: 	execute dbo.[uspUpdateOwnerMMForm] 83, 10, 2
-- MODIFIED: Raghu 
-- Description:	added new parameter to insert/update history table of MMForm
-- Execution: 	

--================================================


CREATE procedure [dbo].[uspUpdateOwnerMMForm]

(@ID bigint,
@CustomerId int,
@ProductId int,
 @HistoryFormId int  null)

as Begin 

Declare @q16CareQ varchar(100), 
		@q18User varchar(100),
	    @AssignTo varchar(100),
	    @Title nvarchar(100),
		@Narrative nvarchar(max),
		@Note varchar(255)='Member Management Form Saved',
		@UserType varchar(2)='HP',
		@FormName varchar(255),
		@mvdid varchar(50),
		@ReferralId bigint,
		@TaskID bigint, 
		@DueDate datetime,
	    @StatusId int ,
		@PriorityId int ,
		@TypeId int,
		@NewTaskId bigint,
		@CREATEDDATE datetime,
		@author varchar(100),
		@GroupID int,
		@Owner Varchar(100),
		@Result bigint




if exists (select 1 from ABCBS_MemberManagement_Form where ID =@id) 
Begin


			select  @mvdid=MVDID, @q16CareQ=q16CareQ, @q18User=q18User,--= isnull(q16CareQ,q18User)
			@AssignTo=q15AssignTo, @ReferralId=ReferralId  from ABCBS_MemberManagement_Form where id = @ID

			if (@q16CareQ = '')
			begin
			set @q16CareQ =null
			End

			if (@q18User = '')
			begin
			set @q18User =null
			End

			set @Owner = isnull(@q16CareQ,@q18User)

			select @groupID=Id  from HPAlertGroup where name = @q16CareQ and Cust_ID=@CustomerId
			and active=1


			update ABCBS_MemberManagement_Form
			set ReferralOwner=@Owner
			  --, SectionCompleted=1
			where id = @ID

			
			-- maintaining history of each MMF form Save 
			if(@HistoryFormId <> NULL)
			BEGIN
				update ABCBS_MMFHistory_Form set ReferralOwner = @Owner where ID = @HistoryFormId;
			END
			
	

End 

------------------------------------------------------------------------------------------------
--select @TaskID= taskid from MemberReferral
--where id=@ReferralId


----Get Information for task

--select 
--@Title=task.Title,
--@Narrative=Narrative,
--@author=task.author,
--@TypeId=task.TypeId,
--@DueDate=act.DueDate ,
--@StatusId=act.StatusId,
--@PriorityId=act.PriorityId
--from dbo.Task task
--	inner join (
--					select TaskId, MAX(CreatedDate) as MaxCreatedDate
--					from TaskActivityLog
--					Group By TaskId
--				) mtd on task.Id = mtd.TaskId
--	inner join [dbo].[TaskActivityLog] act on mtd.TaskId = act.TaskId and mtd.MaxCreatedDate = act.CreatedDate
--	inner join  [dbo].MainPersonalDetails main
--		on main.ICENUMBER=task.MVDID
--	inner join [dbo].[Link_MemberId_MVD_Ins] link
--		on main.ICENUMBER= link.mvdid
--	inner join [dbo].MainInsurance ins
--		on ins.ICENUMBER= task.MVDID
--	where 
--	 task.customerid=@CustomerId
--	and task.ProductId=@ProductId
--	and task.Id=@TaskID
--order by task.ReminderDate 


--			set @CreatedDate = GETUTCDATE()
--			Set @Title = 'Original: '+ isnull(@Title,'') + ' :::Current: Assigned to CareQ/User'
--			Set @Narrative = 'Original: '+ isnull(@Narrative,'') + ' :::Current: Assigned to CareQ/User'


--						EXECUTE [dbo].[Set_UserTask] 
--						   @Title=@Title
--						  ,@Narrative=@Narrative
--						  ,@MVDID=@MVDID
--						  ,@CustomerId=@CustomerId
--						  ,@ProductId=@ProductId
--						  ,@Author=@Author
--						  ,@Owner=@Owner        --Confirm if (q16CareQ) field is for both User/CareQ
--						  ,@CREATEDDATE=@CreatedDate
--						  ,@DueDate=@DueDate
--						  ,@StatusId=@StatusId
--						  ,@PriorityId=@PriorityId
--						  ,@TypeId=@TypeId
--						  ,@groupID=@groupID
--						  ,@NewTaskId =@NewTaskId OUTPUT

------------------------------------------------------------------------------

--Set FormName 
--select @FormName=ProcedureName from LookupCS_MemberNoteForms where FormName='Member Management' and active=1


--EXECUTE [dbo].[Set_HPAlertNoteForForm] 
--   @MVDID=@mvdid
--  ,@Owner=@Author
--  ,@UserType=@UserType
--  ,@Note=@Note
--  ,@FormID=@FormName
--  ,@MemberFormID=@ID
--  ,@StatusID=0
--  ,@CaseID=null
--  ,@Result=@Result OUTPUT

End 