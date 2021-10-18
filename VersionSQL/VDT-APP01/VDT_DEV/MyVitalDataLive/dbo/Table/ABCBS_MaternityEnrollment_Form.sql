/****** Object:  Table [dbo].[ABCBS_MaternityEnrollment_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_MaternityEnrollment_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[q1EnrollmentMethod] [varchar](max) NULL,
	[q9MemberAge] [varchar](max) NULL,
	[q10CompleteSchool] [varchar](max) NULL,
	[q11MaritalStatus] [varchar](max) NULL,
	[q14PregnancyInformation] [varchar](max) NULL,
	[q15Email] [varchar](max) NULL,
	[q15] [varchar](max) NULL,
	[q15a] [varchar](max) NULL,
	[q15b] [varchar](max) NULL,
	[q14] [varchar](max) NULL,
	[q16] [varchar](max) NULL,
	[q35Prepregnancy] [varchar](max) NULL,
	[q36GoodNutrition] [varchar](max) NULL,
	[q37Tobacco] [varchar](max) NULL,
	[q38Alcohol] [varchar](max) NULL,
	[q39Emotional] [varchar](max) NULL,
	[q40SafeAtHome] [varchar](max) NULL,
	[q41Depressed] [varchar](max) NULL,
	[q42LittleInterest] [varchar](max) NULL,
	[q4] [varchar](max) NULL,
	[q5PhysicianName] [varchar](max) NULL,
	[q6PhysicianPhone] [varchar](max) NULL,
	[q7FirstVisit] [datetime] NULL,
	[q8LastVisit] [datetime] NULL,
	[q2BabyDue] [datetime] NULL,
	[q3MemberGestation] [varchar](max) NULL,
	[q12PlannedPregnancy] [varchar](max) NULL,
	[q13UnexpectedPregnancy] [varchar](max) NULL,
	[q16Pregnant] [varchar](max) NULL,
	[q17] [varchar](max) NULL,
	[q18] [varchar](max) NULL,
	[q19] [varchar](max) NULL,
	[q20Delivery] [varchar](max) NULL,
	[q21] [varchar](max) NULL,
	[q22] [varchar](max) NULL,
	[q23Pregnant] [varchar](max) NULL,
	[q26AdmittedHospital] [varchar](max) NULL,
	[q27BedRest] [varchar](max) NULL,
	[q25LastBabyBorn] [varchar](max) NULL,
	[q28MoreThanweek] [varchar](max) NULL,
	[q29DiedBaby] [varchar](max) NULL,
	[q30CauseOfDeath] [varchar](max) NULL,
	[q30CauseOfDeathOther] [varchar](max) NULL,
	[q24Problems] [varchar](max) NULL,
	[q24ProblemsOther] [varchar](max) NULL,
	[q31History] [varchar](max) NULL,
	[q32PretermLabor] [varchar](max) NULL,
	[q33Abortion] [varchar](max) NULL,
	[q34Other] [varchar](max) NULL,
	[TotalScore] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_MaternityEnrollment_Form] ON [dbo].[ABCBS_MaternityEnrollment_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_MaternityEnrollment_Form_FormDate] ON [dbo].[ABCBS_MaternityEnrollment_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_MaternityEnrollment_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON







CREATE TRIGGER [dbo].[trCPAutoCarePlanMaternityEnrollment] ON [dbo].[ABCBS_MaternityEnrollment_Form]
    AFTER INSERT
    AS
    BEGIN

	SET NOCOUNT ON;
	DECLARE 
	@ID INT, @mvdid varchar(50), @careplandate date, @author varchar(100), @createdby varchar(50), @cust_id varchar(40)

	select @ID = ID from inserted

	SELECT @mvdid= mvdid, @careplandate= FORMDATE, @author=FORMAUTHOR , @createdby=FORMAUTHOR
	FROM dbo.ABCBS_MaternityEnrollment_Form where  ID=@ID

	SELECT @cust_id = cust_id
	From dbo.Link_MemberId_MVD_Ins
	Where MVDId = @mvdid

	EXECUTE dbo.CPAutoCarePlan 'ABCBS_MaternityEnrollment', @cust_id, 1, @ID, @author, 'Maternity'
	
	select @ID

	END

ALTER TABLE [dbo].[ABCBS_MaternityEnrollment_Form] ENABLE TRIGGER [trCPAutoCarePlanMaternityEnrollment]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE TRIGGER [dbo].[trCPAutoCarePlanMaternityEnrollmentUpdate] ON [dbo].[ABCBS_MaternityEnrollment_Form]
    AFTER UPDATE
    AS
    BEGIN

	SET NOCOUNT ON;
	DECLARE 
	@ID INT, @mvdid varchar(50), @careplandate date, @author varchar(100), @createdby varchar(50), @cust_id varchar(40), @mvdid_inserted varchar(50)

	select @ID = ID from inserted

	SELECT @mvdid= mvdid, @careplandate= FORMDATE, @author=FORMAUTHOR , @createdby=FORMAUTHOR
	FROM dbo.ABCBS_MaternityEnrollment_Form where  ID=@ID

	SELECT @cust_id = cust_id
	From dbo.Link_MemberId_MVD_Ins
	Where MVDId = @mvdid

	--if the MVDID column is in the inserted table check to see if the value is changing. 
	IF UPDATE(MVDID) SELECT @mvdid_inserted = mvdid FROM inserted
	
	IF @mvdid_inserted IS NULL OR @mvdid_inserted = @mvdid 
		--do not execute the proc if the MVDID column is being updated to a new value
		BEGIN
			EXECUTE dbo.CPAutoCarePlan 'ABCBS_MaternityEnrollment', @cust_id, 1, @ID, @author, 'Maternity'
		END

	select @ID

	END

ALTER TABLE [dbo].[ABCBS_MaternityEnrollment_Form] ENABLE TRIGGER [trCPAutoCarePlanMaternityEnrollmentUpdate]