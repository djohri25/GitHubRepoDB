/****** Object:  Table [dbo].[ABCBS_MaternityRiskREEvaluation_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_MaternityRiskREEvaluation_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[q1LastPrenatalVisit] [datetime] NULL,
	[q2Problems] [varchar](max) NULL,
	[q2ProblemsOther] [varchar](max) NULL,
	[q3weightGained] [varchar](max) NULL,
	[q7TeethCleaned] [varchar](max) NULL,
	[q8PhysicianTalked] [varchar](max) NULL,
	[q4PrescriptionMedications] [varchar](max) NULL,
	[q5PrenatalCareRegularly] [varchar](max) NULL,
	[q5GoodSupport] [varchar](max) NULL,
	[q6Upset] [varchar](max) NULL,
	[q9Nicotine] [varchar](max) NULL,
	[q10Alcohol] [varchar](max) NULL,
	[q11Emotional] [varchar](max) NULL,
	[q12SafeInHome] [varchar](max) NULL,
	[q13Depressed] [varchar](max) NULL,
	[q14Pleasure] [varchar](max) NULL,
	[TotalScore] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_MaternityRiskREEvaluation_Form] ON [dbo].[ABCBS_MaternityRiskREEvaluation_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_MaternityRiskREEvaluation_Form_FormDate] ON [dbo].[ABCBS_MaternityRiskREEvaluation_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_MaternityRiskREEvaluation_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON





CREATE TRIGGER [dbo].[trCPAutoCarePlanMaternityRiskREEvaluation] ON [dbo].[ABCBS_MaternityRiskREEvaluation_Form]
    AFTER INSERT
    AS
    BEGIN

	SET NOCOUNT ON;
	DECLARE 
	@ID INT, @mvdid varchar(50), @careplandate date, @author varchar(100), @createdby varchar(50), @cust_id varchar(40)

	select @ID = ID from inserted

	SELECT @mvdid= mvdid, @careplandate= FORMDATE, @author=FORMAUTHOR , @createdby=FORMAUTHOR
	FROM dbo.[ABCBS_MaternityRiskREEvaluation_Form] where  ID=@ID

	SELECT @cust_id = cust_id
	From dbo.Link_MemberId_MVD_Ins
	Where MVDId = @mvdid

	EXECUTE dbo.CPAutoCarePlan 'ABCBS_MaternityRiskREEvaluation', @cust_id, 1, @ID, @author, 'Maternity'
	
	select @ID

	END

ALTER TABLE [dbo].[ABCBS_MaternityRiskREEvaluation_Form] ENABLE TRIGGER [trCPAutoCarePlanMaternityRiskREEvaluation]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE TRIGGER [dbo].[trCPAutoCarePlanMaternityRiskREEvaluationUpdate] ON [dbo].[ABCBS_MaternityRiskREEvaluation_Form]
    AFTER UPDATE
    AS
    BEGIN

	SET NOCOUNT ON;
	DECLARE 
	@ID INT, @mvdid varchar(50), @careplandate date, @author varchar(100), @createdby varchar(50), @cust_id varchar(40), @mvdid_inserted varchar(50)

	select @ID = ID from inserted

	SELECT @mvdid= mvdid, @careplandate= FORMDATE, @author=FORMAUTHOR , @createdby=FORMAUTHOR
	FROM dbo.[ABCBS_MaternityRiskREEvaluation_Form] where  ID=@ID

	SELECT @cust_id = cust_id
	From dbo.Link_MemberId_MVD_Ins
	Where MVDId = @mvdid

	--if the MVDID column is in the inserted table check to see if the value is changing. 
	IF UPDATE(MVDID) SELECT @mvdid_inserted = mvdid FROM inserted
	
	IF @mvdid_inserted IS NULL OR @mvdid_inserted = @mvdid 
		--do not execute the proc if the MVDID column is being updated to a new value
		BEGIN
			EXECUTE dbo.CPAutoCarePlan 'ABCBS_MaternityRiskREEvaluation', @cust_id, 1, @ID, @author, 'Maternity'
		END

	select @ID

	END

ALTER TABLE [dbo].[ABCBS_MaternityRiskREEvaluation_Form] ENABLE TRIGGER [trCPAutoCarePlanMaternityRiskREEvaluationUpdate]