/****** Object:  Procedure [dbo].[usp_ABCBS_MaternityEnrollment_Form_Insert]    Committed by VersionSQL https://www.versionsql.com ******/

------------------------------------------------------------
--	09/12/2019	dpatel	Updated proc to store correct identity values in FK tables.
--	10/03/2019	dpatel	Updated proc to disable task creation as per update in requirement.
--	10/07/2019	dpatel	Updated proc to receive @TotalScore parameter to Maternity Enrollment web-api end-point.
------------------------------------------------------------


CREATE PROC [dbo].[usp_ABCBS_MaternityEnrollment_Form_Insert] 
	@MemberId varchar(100),
	@LOB varchar(100),
	@FormDate datetime,
	@FormAuthor varchar(100),
	@CaseId varchar(100),
	@q1EnrollmentMethod varchar(max),
	@q2BabyDue datetime,
	@q3MemberGestation varchar(max),
	@q4 varchar(max),
	@q5PhysicianName varchar(max),
	@q6PhysicianPhone varchar(max),
	@q7FirstVisit datetime,
	@q8LastVisit datetime,
	@q9MemberAge varchar(max),
	@q10CompleteSchool varchar(max),
	@q11MaritalStatus varchar(max),
	@q12PlannedPregnancy varchar(max),
	@q13UnexpectedPregnancy varchar(max),
	@q14PregnancyInformation varchar(max),
	@q15Email varchar(max),
	@q16Pregnant varchar(max),
	@q17 varchar(max),
	@q18 varchar(max),
	@q19 varchar(max),
	@q20Delivery varchar(max),
	@q21 varchar(max),
	@q22 varchar(max),
	@q23Pregnant varchar(max),
	@q24Problems varchar(max),
	@q24ProblemsOther varchar(max),
	@q25LastBabyBorn varchar(max),
	@q26AdmittedHospital varchar(max),
	@q27BedRest varchar(max),
	@q28MoreThanWeek varchar(max),
	@q29DiedBaby varchar(max),
	@q30CauseOfDeath varchar(max),
	@q30CauseOfDeathOther varchar(max),
	@q31History varchar(max),
	@q32PretermLabor varchar(max),
	@q33Abortion varchar(max),
	@q34Other varchar(max),
	@q14 varchar(max),
	@q15 varchar(max),
	@q15a varchar(max),
	@q15b varchar(max),
	@q16 varchar(max),
	@q35prePregnancy varchar(max),
	@q36GoodNutrition varchar(max),
	@q37Tobacco varchar(max),
	@q38Alcohol varchar(max),
	@q39Emotional varchar(max),
	@q40SafeAtHome varchar(max),
	@q41Depressed varchar(max),
	@q42LittleInterest varchar(max),
	@CustomerId int,
	@UserName varchar(max),
	@GroupName varchar(max),
	@TotalScore varchar(max)
AS

BEGIN TRY
	BEGIN TRANSACTION
	
	DECLARE @MVDID varchar(20)
	DECLARE @IsMemberActive bit 

	IF EXISTS (SELECT top 1 *
			   FROM [dbo].[ComputedCareQueue]
			   WHERE MemberID = @MemberId and LOB = @LOB)
		BEGIN
			SELECT top 1 @MVDID = MVDID, @IsMemberActive = ISNULL(Isactive,0)
			FROM [dbo].[ComputedCareQueue]
			WHERE MemberID = @MemberId and LOB = @LOB

			if @IsMemberActive = 0
				Begin
					RAISERROR('Member is not active.',16,1);
				End
		END 
	ELSE
		BEGIN
		   RAISERROR('Member Id not found.',16,1);
		END


	--DECLARE @RC int
	--DECLARE @Id bigint
	--DECLARE @Title nvarchar(100)
	--DECLARE @Narrative nvarchar(max)
	--DECLARE @ProductId int
	--DECLARE @Author varchar(100)
	--DECLARE @Owner varchar(100)
	--DECLARE @UpdatedBy varchar(100)
	--DECLARE @UpdatedDate datetime
	--DECLARE @DueDate datetime
	--DECLARE @ReminderDate datetime
	--DECLARE @CompletedDate datetime
	--DECLARE @PercentComplete tinyint
	--DECLARE @ParentTaskId bigint
	--DECLARE @TaskLibraryId int
	--DECLARE @AutomationProcId int
	--DECLARE @SensitivityId int
	--DECLARE @AccountingId int
	--DECLARE @IsDelete bit
	--DECLARE @ReasonForUpdate varchar(250)
	DECLARE @CreatedDate datetime
	DECLARE @CodeTypeId int
	--DECLARE @StatusId int
	--DECLARE @PriorityId int
	--DECLARE @TypeId int
	--DECLARE @GroupID int
	--DECLARE @TaskOwner varchar(100)
	--DECLARE @NewTaskId bigint

	-- TODO: Set parameter values here.
	SET @CreatedDate= GETUTCDATE()

	--Task creation is disabled as per new update in requirement
	--set @CodeTypeId = (select CodeTypeID from Lookup_Generic_Code_Type where CodeType = 'TaskStatus')
	--SET @StatusId = (SELECT CodeId FROM Lookup_Generic_Code WHERE Label = 'New' and CodeTypeID = @CodeTypeId)

	--set @CodeTypeId = (select CodeTypeID from Lookup_Generic_Code_Type where CodeType = 'TaskPriority')
	--SET @PriorityId = (SELECT CodeId FROM Lookup_Generic_Code WHERE LABEL = 'Medium' and CodeTypeID = @CodeTypeId)
	
	--set @CodeTypeId = (select CodeTypeID from Lookup_Generic_Code_Type where CodeType = 'TaskType')
	--SET @TypeId = (SELECT CodeId FROM Lookup_Generic_Code WHERE LABEL = 'Referral' and CodeTypeID = @CodeTypeId)

	
	--if @GroupName is not null
	--	Begin
	--		SET @GroupId = (SELECT Id
	--						FROM HPAlertGroup
	--						WHERE Name = @GroupName)

	--		if @GroupID is not null
	--			Begin
	--				Set @TaskOwner = @GroupName
	--			End
	--		Else
	--			Begin
	--				set @TaskOwner = @UserName
	--				set @GroupID = NULL
	--			End
	--	End
	--Else
	--	Begin
	--		set @TaskOwner = @UserName
	--		set @GroupID = NULL
	--	End
	

	--INSERT INTO [dbo].[Task]
	--           ([Title]
	--           ,[Narrative]
	--           ,[MVDID]
	--           ,[CustomerId]
	--           ,[ProductId]
	--           ,[Author]
	--           ,[CreatedDate]
	--           ,[UpdatedDate]
	--           ,[ReminderDate]
	--           ,[CompletedDate]
	--           ,[PercentComplete]
	--           ,[TypeId]
	--           ,[ParentTaskId]
	--           ,[TaskLibraryId]
	--           ,[AutomationProcId]
	--           ,[SensitivityId]
	--           ,[AccountingId]
	--           ,[CaseId]
	--           ,[UpdatedBy]
	--           ,[IsDelete])
	--VALUES
	--           (
	--            'Maternity Enrollment Request'
	--		   ,'Maternity enrollment request received and new Maternity Enrollment added.'
	--           ,@MVDID
	--           ,@CustomerId
	--           ,2
	--           ,@UserName
	--           ,@CreatedDate
	--           ,NULL
	--           ,NULL
	--           ,NULL
	--           ,NULL
	--           ,@TypeId
	--           ,NULL
	--           ,NULL
	--           ,NULL
	--           ,NULL
	--           ,NULL
	--           ,NULL
	--           ,NULL
	--           ,0)

	--SET @NewTaskId= SCOPE_IDENTITY()

	--INSERT INTO [dbo].[TaskActivityLog]
	--           ([TaskId]
	--           ,[Owner]
	--           ,[DueDate]
	--           ,[StatusId]
	--           ,[PriorityId]
	--           ,[CreatedDate]
	--           ,[CreatedBy]
	--           ,[ReasonForUpdate]
	--           ,[GroupID])
	--     VALUES
	--           (@NewTaskId
	--           ,@TaskOwner
	--           ,NULL
	--           ,@StatusId
	--           ,@PriorityId
	--           ,@CreatedDate
	--           ,@UserName
	--           ,NULL
	--           ,@GroupId)


	INSERT INTO [dbo].[ABCBS_MaternityEnrollment_Form] (
	  [MVDID]
	, [FormDate]
	, [FormAuthor]
	, [CaseID]
	, [q1EnrollmentMethod]
	, [q2BabyDue]
	, [q3MemberGestation]
	, [q4]
	, [q5PhysicianName]
	, [q6PhysicianPhone]
	, [q7FirstVisit]
	, [q8LastVisit]
	, [q9MemberAge]
	, [q10CompleteSchool]
	, [q11MaritalStatus]
	, [q12PlannedPregnancy]
	, [q13UnexpectedPregnancy]
	, [q14PregnancyInformation]
	, [q15Email]
	, [q16Pregnant]
	, [q17]
	, [q18]
	, [q19]
	, [q20Delivery]
	, [q21]
	, [q22]
	, [q23Pregnant]
	, [q24Problems]
	, [q24ProblemsOther]
	, [q25LastBabyBorn]
	, [q26AdmittedHospital]
	, [q27BedRest]
	, [q28MoreThanweek]
	, [q29DiedBaby]
	, [q30CauseOfDeath]
	, [q30CauseOfDeathOther]
	, [q31History]
	, [q32PretermLabor]
	, [q33Abortion]
	, [q34Other]
	, [q14]
	, [q15]
	, [q15a]
	, [q15b]
	, [q16]
	, [q35Prepregnancy]
	, [q36GoodNutrition]
	, [q37Tobacco]
	, [q38Alcohol]
	, [q39Emotional]
	, [q40SafeAtHome]
	, [q41Depressed]
	, [q42LittleInterest]
	, [TotalScore])
	  VALUES (@MVDID, @FormDate, @FormAuthor, @CaseID, @q1EnrollmentMethod, @q2BabyDue, @q3MemberGestation, @q4, @q5PhysicianName, @q6PhysicianPhone, @q7FirstVisit, @q8LastVisit, @q9MemberAge, @q10CompleteSchool, @q11MaritalStatus, @q12PlannedPregnancy, @q13UnexpectedPregnancy, @q14PregnancyInformation, @q15Email, @q16Pregnant, @q17, @q18, @q19, @q20Delivery, @q21, @q22, @q23Pregnant, @q24Problems, @q24ProblemsOther, @q25LastBabyBorn, @q26AdmittedHospital, @q27BedRest, @q28MoreThanweek, @q29DiedBaby, @q30CauseOfDeath, @q30CauseOfDeathOther, @q31History, @q32PretermLabor, @q33Abortion, @q34Other, @q14, @q15, @q15a, @q15b, @q16, @q35Prepregnancy, @q36GoodNutrition, @q37Tobacco, @q38Alcohol, @q39Emotional, @q40SafeAtHome, @q41Depressed, @q42LittleInterest,@TotalScore)

	DECLARE @DOCID bigint
	--SET @DOCID = @@IDENTITY
	SET @DOCID = SCOPE_IDENTITY()


	DECLARE @MemberReferralId bigint
	DECLARE @ParentDocID bigint
	DECLARE @TaskID bigint
	DECLARE @TaskSource nvarchar(100)
	DECLARE @CaseProgram varchar(100)
	DECLARE @ParentReferralID bigint
	DECLARE @NonViableReason nvarchar(100)
	DECLARE @CreatedBy nvarchar(100)
	DECLARE @CheckAssignment bit
	DECLARE @Cust_ID int

	EXECUTE @MemberReferralId = [dbo].[InsertMemberReferral] @DocID = @DOCID,
	                                                         @ParentDocID = NULL,
	                                                         @MemberID = @MemberId,
	                                                         --@TaskID = @NewTaskId,
															 @TaskID = NULL,
	                                                         @TaskSource = 'Maternity Enrollment',
	                                                         @CaseProgram = NULL,
	                                                         @ParentReferralID = NULL,
	                                                         @NonViableReason = NULL,
	                                                         @CreatedDate= @CreatedDate,
	                                                         @CreatedBy = @UserName,
	                                                         @CheckAssignment = 0,
	                                                         @Cust_ID = @CustomerId,
	                                                         @ReferralId = NULL

	DECLARE @NoteTypeID int
	set @CodeTypeId = (select CodeTypeID from Lookup_Generic_Code_Type where CodeType = 'NoteType')
	SET @NoteTypeID = (SELECT CodeId FROM Lookup_Generic_Code WHERE Label = 'DocumentNote' and CodeTypeID = @CodeTypeId)

	INSERT INTO HPAlertNote (AlertID,
	Note,
	AlertStatusID,
	DateCreated,
	CreatedBy,
	DateModified,
	ModifiedBy,
	CreatedByCompany,
	ModifiedByCompany,
	MVDID,
	CreatedByType,
	ModifiedByType,
	Active,
	SendToHP,
	SendToPCP,
	SendToNurture,
	SendToNone,
	LinkedFormType,
	LinkedFormID,
	NoteTypeID,
	ActionTypeID,
	DueDate,
	CompletedDate,
	NoteTimestampId,
	NoteSourceId,
	SendToMyVitalDataMobile,
	SendToOHIT,
	SendToState,
	SendToDMVendor,
	CaseID,
	IsDelete,
	SessionID,
	DocType)
	VALUES (NULL, 'Maternity Enrollment Saved.', 0, @CreatedDate, @UserName, @CreatedDate, @UserName, NULL, NULL, @MVDID, 'HP', 'HP', 1, NULL, NULL, NULL, NULL, 
			'ABCBS_MaternityEnrollment', @DOCID, @NoteTypeID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL)

	SELECT @DOCID

	COMMIT
END TRY
BEGIN CATCH
    THROW 
	ROLLBACK
END CATCH