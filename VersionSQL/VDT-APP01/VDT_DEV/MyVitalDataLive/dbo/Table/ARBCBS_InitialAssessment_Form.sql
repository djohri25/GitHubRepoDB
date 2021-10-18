/****** Object:  Table [dbo].[ARBCBS_InitialAssessment_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ARBCBS_InitialAssessment_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[q1] [varchar](max) NULL,
	[q2Score] [varchar](max) NULL,
	[q2ScoreOther] [varchar](max) NULL,
	[q3Score] [varchar](max) NULL,
	[q3ScoreOther] [varchar](max) NULL,
	[q4Score] [varchar](max) NULL,
	[q4ScoreOther] [varchar](max) NULL,
	[q5Score] [varchar](max) NULL,
	[q5ScoreOther] [varchar](max) NULL,
	[q5ScoreOtherA] [varchar](max) NULL,
	[q6Score] [varchar](max) NULL,
	[q8Score] [varchar](max) NULL,
	[q8ScoreOtherA] [varchar](max) NULL,
	[q8ScoreOther1] [varchar](max) NULL,
	[q8ScoreOtherB] [varchar](max) NULL,
	[q8ScoreOtherC] [varchar](max) NULL,
	[q8ScoreOtherD] [varchar](max) NULL,
	[q8ScoreOtherE] [varchar](max) NULL,
	[q8ScoreOtherE1] [varchar](max) NULL,
	[q8ScoreOtherF] [varchar](max) NULL,
	[q8ScoreOtherG] [varchar](max) NULL,
	[q7Score] [varchar](max) NULL,
	[q7ScoreOther] [varchar](max) NULL,
	[q7ScoreOther1] [varchar](max) NULL,
	[q7ScoreOther2] [varchar](max) NULL,
	[qLastMonthDepression] [varchar](max) NULL,
	[qLastMonthInterest] [varchar](max) NULL,
	[qCompanionShip] [varchar](max) NULL,
	[qIsolated] [varchar](max) NULL,
	[q9MentalCondition] [varchar](max) NULL,
	[q9Counseling] [varchar](max) NULL,
	[q9TakingMed] [varchar](max) NULL,
	[q9CMInteventions] [varchar](max) NULL,
	[q9ScoreOtherC] [varchar](max) NULL,
	[q12Score] [varchar](max) NULL,
	[q13Score] [varchar](max) NULL,
	[q14Score] [varchar](max) NULL,
	[q15Score] [varchar](max) NULL,
	[q15ScoreOther] [varchar](max) NULL,
	[q16Score] [varchar](max) NULL,
	[q17Score] [varchar](max) NULL,
	[q17ScoreOther] [datetime] NULL,
	[TotalScore] [varchar](max) NULL,
	[q19Score] [varchar](max) NULL,
	[qCaseProgram] [varchar](255) NULL,
	[qAcuity] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[q4InstatePCPType] [varchar](max) NULL,
	[q4OutstatePCP] [varchar](max) NULL,
	[q4OutstatePCPType] [varchar](max) NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ARBCBS_InitialAssessment_Form] ON [dbo].[ARBCBS_InitialAssessment_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ARBCBS_InitialAssessment_Form_FormDate] ON [dbo].[ARBCBS_InitialAssessment_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ARBCBS_InitialAssessment_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE TRIGGER [dbo].[trAutoTaskInitialAssessment] ON [dbo].[ARBCBS_InitialAssessment_Form]
    AFTER INSERT
    AS
    BEGIN

	SET NOCOUNT ON;
	DECLARE 
	@ID INT, @mvdid varchar(50), @FORMDATE datetime, @author varchar(100), 
	@createdby varchar(50), @CustomerId int=16,  @TypeId int, @DueDate datetime
	,@ReminderDate datetime, @Title nvarchar(100)='Consult Consideration', @Narrative nvarchar(max), 
	@answer1 varchar(max)='Consider a behavioral health or social work consultation for this member'
	, @answer2 varchar(max) ='Offer the member a social work consultation' ,
	@qLastMonthDepression varchar(max), @qLastMonthInterest varchar(max), @qCompanionShip varchar(max), @qIsolated varchar(max),
	@q9MentalCondition varchar(max), @q15Score varchar(max), @CurrentDate datetime=getUTCdate(),
	@StatusId int , @PriorityId int, @ProductId int =2, @NewTaskId bigint, @checkScore int



	select @ID = ID from inserted

	select @TypeId=CodeID from Lookup_Generic_Code where  
	codetypeid in (select codetypeid from Lookup_Generic_Code_Type where codetype='Tasktype')
	and label='Consult'

	Set @DueDate= dateadd(hour, 72, @FORMDATE)
	Set @ReminderDate= dateadd(hour, 48, @FORMDATE)
	select  @PriorityId= codeid from dbo.LOOKUP_GENERIC_CODE where codetypeid =14 and LTRIM(rtrim(Label))='Medium'
	select  @StatusId= codeid from dbo.LOOKUP_GENERIC_CODE where codetypeid =13 and LTRIM(rtrim(Label))='New'


	SELECT @mvdid= mvdid, @FORMDATE= FORMDATE, @author=FORMAUTHOR , @createdby=FORMAUTHOR, @qLastMonthDepression=qLastMonthDepression,
	@qLastMonthInterest=qLastMonthInterest, @qCompanionShip=qCompanionShip, @qIsolated=qIsolated, @q9MentalCondition=q9MentalCondition, @q15Score=q15Score
	FROM dbo.ARBCBS_InitialAssessment_Form where  ID=@ID

if len(@q15Score)>2 

	begin 

		set @checkScore=
		case when @q15Score not like '%None%' then 1
			 when @q15Score like '%None%' and len(@q15Score)=14 then 0
			 when @q15Score like '%None%' and len(@q15Score)>14 then 1
			 end 

	end

if len(@q15Score)<2 
	Begin
		set @checkScore=0
	End


If (@qLastMonthDepression='Yes' or @qLastMonthInterest='Yes'  or @qCompanionShip='Often' or @qIsolated='Often' or @q9MentalCondition='Yes')

	Begin 

	set @Narrative= @answer1 

							EXECUTE [dbo].[Set_UserTask] 
						   @Title=@Title
						  ,@Narrative=@Narrative
						  ,@MVDID=@MVDID
						  ,@CustomerId=@CustomerId
						  ,@ProductId=@ProductId
						  ,@Author=@Author
						  ,@Owner=@createdby        
						  ,@CREATEDDATE=@FORMDATE
						  ,@DueDate=@DueDate
						  ,@ReminderDate=@ReminderDate
						  ,@StatusId=@StatusId
						  ,@PriorityId=@PriorityId
						  ,@TypeId=@TypeId
						  ,@NewTaskId =@NewTaskId OUTPUT

	
				if (@checkScore=1)

					Begin 

					set @Narrative= @answer2

								EXECUTE [dbo].[Set_UserTask] 
						   @Title=@Title
						  ,@Narrative=@Narrative
						  ,@MVDID=@MVDID
						  ,@CustomerId=@CustomerId
						  ,@ProductId=@ProductId
						  ,@Author=@Author
						  ,@Owner=@createdby        
						  ,@CREATEDDATE=@FORMDATE
						  ,@DueDate=@DueDate
  						  ,@ReminderDate=@ReminderDate
						  ,@StatusId=@StatusId
						  ,@PriorityId=@PriorityId
						  ,@TypeId=@TypeId
						  ,@NewTaskId =@NewTaskId OUTPUT

					End 


	End 

	else 

	begin 
			if (@checkScore=1)
			Begin

			set @Narrative= @answer2


								EXECUTE [dbo].[Set_UserTask] 
						   @Title=@Title
						  ,@Narrative=@Narrative
						  ,@MVDID=@MVDID
						  ,@CustomerId=@CustomerId
						  ,@ProductId=@ProductId
						  ,@Author=@Author
						  ,@Owner=@createdby        
						  ,@CREATEDDATE=@FORMDATE
						  ,@DueDate=@DueDate
  						  ,@ReminderDate=@ReminderDate
						  ,@StatusId=@StatusId
						  ,@PriorityId=@PriorityId
						  ,@TypeId=@TypeId
						  ,@NewTaskId =@NewTaskId OUTPUT

			End 


	end 




	

	
	select @ID

	END

ALTER TABLE [dbo].[ARBCBS_InitialAssessment_Form] ENABLE TRIGGER [trAutoTaskInitialAssessment]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE TRIGGER [dbo].[trAutoTaskInitialAssessment_bkup] ON [dbo].[ARBCBS_InitialAssessment_Form]
    AFTER INSERT
    AS
    BEGIN

	SET NOCOUNT ON;
	DECLARE 
	@ID INT, @mvdid varchar(50), @FORMDATE date, @author varchar(100), 
	@createdby varchar(50), @CustomerId int=16,  @TypeId int, @DueDate datetime
	,@ReminderDate datetime, @Title nvarchar(100)='Consult Consideration', @Narrative nvarchar(max), 
	@answer1 varchar(max)='Consider a behavioral health or social work consultation for this member'
	, @answer2 varchar(max) ='Offer the member a social work consultation' ,
	@qLastMonthDepression varchar(max), @qLastMonthInterest varchar(max), @qCompanionShip varchar(max), @qIsolated varchar(max),
	@q9MentalCondition varchar(max), @q15Score varchar(max), @CurrentDate datetime=getUTCdate(),
	@StatusId int , @PriorityId int, @ProductId int =2, @NewTaskId bigint, @checkScore int



	select @ID = ID from inserted

	select @TypeId=CodeID from Lookup_Generic_Code where  
	codetypeid in (select codetypeid from Lookup_Generic_Code_Type where codetype='Tasktype')
	and label='Consult'

	Set @DueDate= dateadd(hour, 72, @CurrentDate)
	Set @ReminderDate= dateadd(hour, 48, @CurrentDate)
	select  @PriorityId= codeid from dbo.LOOKUP_GENERIC_CODE where codetypeid =14 and LTRIM(rtrim(Label))='Medium'
	select  @StatusId= codeid from dbo.LOOKUP_GENERIC_CODE where codetypeid =13 and LTRIM(rtrim(Label))='New'


	SELECT @mvdid= mvdid, @FORMDATE= FORMDATE, @author=FORMAUTHOR , @createdby=FORMAUTHOR, @qLastMonthDepression=qLastMonthDepression,
	@qLastMonthInterest=qLastMonthInterest, @qCompanionShip=qCompanionShip, @qIsolated=qIsolated, @q9MentalCondition=q9MentalCondition, @q15Score=q15Score
	FROM dbo.ARBCBS_InitialAssessment_Form where  ID=@ID

if len(@q15Score)>2 

	begin 

		set @checkScore=
		case when @q15Score not like '%None%' then 1
			 when @q15Score like '%None%' and len(@q15Score)=14 then 0
			 when @q15Score like '%None%' and len(@q15Score)>14 then 1
			 end 

	end

if len(@q15Score)<2 
	Begin
		set @checkScore=0
	End


If (@qLastMonthDepression='Yes' or @qLastMonthInterest='Yes'  or @qCompanionShip='Often' or @qIsolated='Often' or @q9MentalCondition='Yes')

	Begin 

	set @Narrative= @answer1 

							EXECUTE [dbo].[Set_UserTask] 
						   @Title=@Title
						  ,@Narrative=@Narrative
						  ,@MVDID=@MVDID
						  ,@CustomerId=@CustomerId
						  ,@ProductId=@ProductId
						  ,@Author=@Author
						  ,@Owner=@createdby        
						  ,@CREATEDDATE=@CurrentDate
						  ,@DueDate=@DueDate
						  ,@ReminderDate=@ReminderDate
						  ,@StatusId=@StatusId
						  ,@PriorityId=@PriorityId
						  ,@TypeId=@TypeId
						  ,@NewTaskId =@NewTaskId OUTPUT

	
				if (@checkScore=1)

					Begin 

					set @Narrative= @answer2

								EXECUTE [dbo].[Set_UserTask] 
						   @Title=@Title
						  ,@Narrative=@Narrative
						  ,@MVDID=@MVDID
						  ,@CustomerId=@CustomerId
						  ,@ProductId=@ProductId
						  ,@Author=@Author
						  ,@Owner=@createdby        
						  ,@CREATEDDATE=@CurrentDate
						  ,@DueDate=@DueDate
  						  ,@ReminderDate=@ReminderDate
						  ,@StatusId=@StatusId
						  ,@PriorityId=@PriorityId
						  ,@TypeId=@TypeId
						  ,@NewTaskId =@NewTaskId OUTPUT

					End 


	End 

	else 

	begin 
			if (@checkScore=1)
			Begin

			set @Narrative= @answer2


								EXECUTE [dbo].[Set_UserTask] 
						   @Title=@Title
						  ,@Narrative=@Narrative
						  ,@MVDID=@MVDID
						  ,@CustomerId=@CustomerId
						  ,@ProductId=@ProductId
						  ,@Author=@Author
						  ,@Owner=@createdby        
						  ,@CREATEDDATE=@CurrentDate
						  ,@DueDate=@DueDate
  						  ,@ReminderDate=@ReminderDate
						  ,@StatusId=@StatusId
						  ,@PriorityId=@PriorityId
						  ,@TypeId=@TypeId
						  ,@NewTaskId =@NewTaskId OUTPUT

			End 


	end 




	

	
	select @ID

	END

ALTER TABLE [dbo].[ARBCBS_InitialAssessment_Form] DISABLE TRIGGER [trAutoTaskInitialAssessment_bkup]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON







CREATE TRIGGER [dbo].[trCPAutoCarePlanInitialAssessment] ON [dbo].[ARBCBS_InitialAssessment_Form]
    AFTER INSERT
    AS
    BEGIN

	SET NOCOUNT ON;
	DECLARE 
	@ID INT, @mvdid varchar(50), @careplandate date, @author varchar(100), @createdby varchar(50), @cust_id varchar(40), @programtype varchar(100)

	select @ID = ID, @programtype = qCaseProgram from inserted

	SELECT @mvdid= mvdid, @careplandate= FORMDATE, @author=FORMAUTHOR , @createdby=FORMAUTHOR
	FROM dbo.[ARBCBS_InitialAssessment_Form] where  ID=@ID

	SELECT @cust_id = custid
	From dbo.FinalMember
	Where MVDId = @mvdid

	EXECUTE dbo.CPAutoCarePlan 'ARBCBS_InitialAssessment', @cust_id, 1, @ID, @author, @programtype
	
	select @ID

	END

ALTER TABLE [dbo].[ARBCBS_InitialAssessment_Form] ENABLE TRIGGER [trCPAutoCarePlanInitialAssessment]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE TRIGGER [dbo].[trCPAutoCarePlanInitialAssessmentUpdate] ON [dbo].[ARBCBS_InitialAssessment_Form]
    AFTER UPDATE
    AS
    BEGIN

	SET NOCOUNT ON;
	DECLARE @ID INT, @mvdid varchar(50), @careplandate date, @author varchar(100), @createdby varchar(50), @cust_id varchar(40), 
			@programtype varchar(100), @mvdid_inserted varchar(50)

	select @ID = ID, @programtype = qCaseProgram from inserted

	SELECT @mvdid= mvdid, @careplandate= FORMDATE, @author=FORMAUTHOR , @createdby=FORMAUTHOR
	FROM dbo.[ARBCBS_InitialAssessment_Form] where  ID=@ID

	SELECT @cust_id = custid
	From dbo.FinalMember
	Where MVDId = @mvdid

	--if the MVDID column is in the inserted table check to see if the value is changing. 
	IF UPDATE(MVDID) SELECT @mvdid_inserted = mvdid FROM inserted
	
	IF @mvdid_inserted IS NULL OR @mvdid_inserted = @mvdid 
		--do not execute the proc if the MVDID column is being updated to a new value
		BEGIN
			EXECUTE dbo.CPAutoCarePlan 'ARBCBS_InitialAssessment', @cust_id, 1, @ID, @author, @programtype
		END

	select @ID

	END

ALTER TABLE [dbo].[ARBCBS_InitialAssessment_Form] ENABLE TRIGGER [trCPAutoCarePlanInitialAssessmentUpdate]