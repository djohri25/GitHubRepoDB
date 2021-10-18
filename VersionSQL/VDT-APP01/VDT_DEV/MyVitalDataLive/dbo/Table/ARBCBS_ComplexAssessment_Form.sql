/****** Object:  Table [dbo].[ARBCBS_ComplexAssessment_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ARBCBS_ComplexAssessment_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[q1Med] [varchar](max) NULL,
	[q2Med] [varchar](max) NULL,
	[q3Med] [varchar](max) NULL,
	[q4Med] [varchar](max) NULL,
	[q5Med] [varchar](max) NULL,
	[q6Med] [varchar](max) NULL,
	[q7Med] [varchar](max) NULL,
	[q8Med] [varchar](max) NULL,
	[q9Med] [varchar](max) NULL,
	[q10Med] [varchar](max) NULL,
	[q10Allergy] [varchar](max) NULL,
	[q11Allergy] [varchar](max) NULL,
	[q12Nutrition] [varchar](max) NULL,
	[q13Nutrition] [varchar](max) NULL,
	[q14Nutrition] [varchar](max) NULL,
	[q15Nutrition] [varchar](max) NULL,
	[q14] [varchar](max) NULL,
	[q15] [varchar](max) NULL,
	[q15a] [varchar](max) NULL,
	[q15b] [varchar](max) NULL,
	[q16] [varchar](max) NULL,
	[q16Nutrition] [varchar](max) NULL,
	[q17preventive] [varchar](max) NULL,
	[q18Preventive] [varchar](max) NULL,
	[q19Preventive] [varchar](max) NULL,
	[q20Preventive] [varchar](max) NULL,
	[q21Preventive] [varchar](max) NULL,
	[q22Preventive] [varchar](max) NULL,
	[q23Safety] [varchar](max) NULL,
	[q24Safety] [varchar](max) NULL,
	[q25Safety] [varchar](max) NULL,
	[q26Safety] [varchar](max) NULL,
	[q27Safety] [varchar](max) NULL,
	[q28Safety] [varchar](max) NULL,
	[q29Abuse] [varchar](max) NULL,
	[q30Abuse] [varchar](max) NULL,
	[q31Abuse] [varchar](max) NULL,
	[q32Abuse] [varchar](max) NULL,
	[q33Abuse] [varchar](max) NULL,
	[q34Social] [varchar](max) NULL,
	[q35Social] [varchar](max) NULL,
	[q36Social] [varchar](max) NULL,
	[q37Social] [varchar](max) NULL,
	[q38Health] [varchar](max) NULL,
	[q39Health] [varchar](max) NULL,
	[q40Health] [varchar](max) NULL,
	[q41Health] [varchar](max) NULL,
	[q43care] [varchar](max) NULL,
	[q44care] [varchar](max) NULL,
	[q45care] [varchar](max) NULL,
	[q46care] [varchar](max) NULL,
	[q47care] [varchar](max) NULL,
	[q48care] [varchar](max) NULL,
	[q49care] [varchar](max) NULL,
	[q50care] [varchar](max) NULL,
	[q51care] [varchar](max) NULL,
	[q52care] [varchar](max) NULL,
	[q53care] [varchar](max) NULL,
	[q54care] [varchar](max) NULL,
	[q55care] [varchar](max) NULL,
	[q56care] [varchar](max) NULL,
	[q57care] [varchar](max) NULL,
	[q58care] [varchar](max) NULL,
	[q63care] [varchar](max) NULL,
	[qHospiceDate] [datetime] NULL,
	[qHospiceSetting] [varchar](max) NULL,
	[qHospiceDateAdmit] [datetime] NULL,
	[qHospiceName] [varchar](max) NULL,
	[qHospiceAddress] [varchar](max) NULL,
	[qHospiceTel] [varchar](max) NULL,
	[qHospiceContactPerson] [varchar](max) NULL,
	[qHospiceAdmission] [varchar](max) NULL,
	[qHospiceMedHist] [varchar](max) NULL,
	[qHospiceVisits] [varchar](max) NULL,
	[qHospiceNurse] [varchar](max) NULL,
	[qInfoByHospiceNurse] [varchar](max) NULL,
	[qHospiceBenefit] [varchar](max) NULL,
	[qDyingProcess] [varchar](max) NULL,
	[qMemberConcern] [varchar](max) NULL,
	[qMemberConcern1] [varchar](max) NULL,
	[qMemberExperiencing] [varchar](max) NULL,
	[qHospiceSideEffects] [varchar](max) NULL,
	[qHospiceAssisstance] [varchar](max) NULL,
	[q65CAD] [varchar](max) NULL,
	[q66CAD] [varchar](max) NULL,
	[q67CAD] [datetime] NULL,
	[q68CAD] [varchar](max) NULL,
	[q69CAD] [varchar](max) NULL,
	[q70CAD] [varchar](max) NULL,
	[q71CAD] [varchar](max) NULL,
	[q72CAD] [datetime] NULL,
	[q73CAD] [varchar](max) NULL,
	[q74CAD] [varchar](max) NULL,
	[q75CAD] [varchar](max) NULL,
	[q76CAD] [varchar](max) NULL,
	[q77CAD] [varchar](max) NULL,
	[q78Asthma] [varchar](max) NULL,
	[q79Asthma] [varchar](max) NULL,
	[q80Asthma] [varchar](max) NULL,
	[q81Asthma] [varchar](max) NULL,
	[q82Asthma] [varchar](max) NULL,
	[q83Asthma] [varchar](max) NULL,
	[q84Asthma] [varchar](max) NULL,
	[q85Asthma] [varchar](max) NULL,
	[q86COPD] [varchar](max) NULL,
	[q87COPD] [varchar](max) NULL,
	[q88COPD] [varchar](max) NULL,
	[q89COPD] [varchar](max) NULL,
	[q91COPD] [varchar](max) NULL,
	[q92COPD] [varchar](max) NULL,
	[q93COPD] [varchar](max) NULL,
	[q94COPD] [varchar](max) NULL,
	[q95COPD] [varchar](max) NULL,
	[q96COPD] [varchar](max) NULL,
	[q97CHF] [varchar](max) NULL,
	[q98CHF] [varchar](max) NULL,
	[q99CHF] [varchar](max) NULL,
	[q100CHF] [varchar](max) NULL,
	[q101CHF] [varchar](max) NULL,
	[q102CHF] [varchar](max) NULL,
	[q103CHF] [varchar](max) NULL,
	[q104CHF] [varchar](max) NULL,
	[q105CHF] [varchar](max) NULL,
	[q106CHF] [varchar](max) NULL,
	[q107CHF] [varchar](max) NULL,
	[q108CHF] [varchar](max) NULL,
	[q109CHF] [varchar](max) NULL,
	[q110CHF] [varchar](max) NULL,
	[q111CHF] [varchar](max) NULL,
	[q112CHF] [varchar](max) NULL,
	[q113CHF] [varchar](max) NULL,
	[q114CHF] [varchar](max) NULL,
	[q115Diabetes] [varchar](max) NULL,
	[q116Diabetes] [varchar](max) NULL,
	[q117Diabetes] [varchar](max) NULL,
	[q118Diabetes] [varchar](max) NULL,
	[q119Diabetes] [varchar](max) NULL,
	[q120Diabetes] [varchar](max) NULL,
	[q121Diabetes] [varchar](max) NULL,
	[q122Diabetes] [varchar](max) NULL,
	[q123Diabetes] [varchar](max) NULL,
	[q124Diabetes] [varchar](max) NULL,
	[q125Diabetes] [varchar](max) NULL,
	[q126Diabetes] [varchar](max) NULL,
	[q127Diabetes] [varchar](max) NULL,
	[q128Diabetes] [varchar](max) NULL,
	[q129Diabetes] [varchar](max) NULL,
	[q130Diabetes] [varchar](max) NULL,
	[q131Diabetes] [varchar](max) NULL,
	[q132Diabetes] [varchar](max) NULL,
	[q133Diabetes] [varchar](max) NULL,
	[q134Cancer] [varchar](max) NULL,
	[q135Cancer] [varchar](max) NULL,
	[q136Cancer] [datetime] NULL,
	[q137Cancer] [datetime] NULL,
	[q138Cancer] [varchar](max) NULL,
	[q139Cancer] [varchar](max) NULL,
	[q140Cancer] [datetime] NULL,
	[q141Cancer] [varchar](max) NULL,
	[q142Cancer] [varchar](max) NULL,
	[q143Cancer] [varchar](max) NULL,
	[q144Cancer] [varchar](max) NULL,
	[q145Cancer] [varchar](max) NULL,
	[q146Cancer] [varchar](max) NULL,
	[q147Cancer] [varchar](max) NULL,
	[q148Cancer] [varchar](max) NULL,
	[q149Cancer] [varchar](max) NULL,
	[q150Cancer] [varchar](max) NULL,
	[q151Cancer] [varchar](max) NULL,
	[q152Cancer] [varchar](max) NULL,
	[q153Cancer] [varchar](max) NULL,
	[q154Cancer] [varchar](max) NULL,
	[q155Cancer] [varchar](max) NULL,
	[q156Cancer] [varchar](max) NULL,
	[q157Cancer] [varchar](max) NULL,
	[q158Cancer] [varchar](max) NULL,
	[qHepatitis1] [varchar](max) NULL,
	[qHepatitis2] [varchar](max) NULL,
	[qHepatitis3] [varchar](max) NULL,
	[qHepatitis4] [varchar](max) NULL,
	[qHepatitis5] [varchar](max) NULL,
	[qHepatitis6] [varchar](max) NULL,
	[qHepatitis7] [varchar](max) NULL,
	[qHepatitis8] [varchar](max) NULL,
	[qHepatitis9] [varchar](max) NULL,
	[Hepatitis10] [varchar](max) NULL,
	[qHepatitis11] [varchar](max) NULL,
	[qHepatitis12] [varchar](max) NULL,
	[qHepatitis13] [varchar](max) NULL,
	[qHepatitis14] [datetime] NULL,
	[qHepatitis15] [varchar](max) NULL,
	[qHepatitis16] [varchar](max) NULL,
	[qHepatitis17] [varchar](max) NULL,
	[qCaseProgram] [varchar](255) NULL,
	[LastModifiedDate] [datetime] NULL,
	[q120DiabetesNew] [varchar](max) NULL,
	[Version] [varchar](max) NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ARBCBS_ComplexAssessment_Form] ON [dbo].[ARBCBS_ComplexAssessment_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ARBCBS_ComplexAssessment_Form_FormDate] ON [dbo].[ARBCBS_ComplexAssessment_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ARBCBS_ComplexAssessment_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON





CREATE TRIGGER [dbo].[trCPAutoCarePlanComplexAssessment] ON [dbo].[ARBCBS_ComplexAssessment_Form]
    AFTER INSERT
    AS
    BEGIN

	SET NOCOUNT ON;
	DECLARE 
	@ID INT, @mvdid varchar(50), @careplandate date, @author varchar(100), @createdby varchar(50), @cust_id varchar(40), @programtype varchar(100)

	select @ID = ID, @programtype = qCaseProgram from inserted

	SELECT @mvdid= mvdid, @careplandate= FORMDATE, @author=FORMAUTHOR , @createdby=FORMAUTHOR
	FROM dbo.[ARBCBS_ComplexAssessment_Form] where  ID=@ID

	SELECT @cust_id = custid
	From dbo.FinalMember
	Where MVDId = @mvdid

	EXECUTE dbo.CPAutoCarePlan 'ARBCBS_ComplexAssessment', @cust_id, 1, @ID, @author, @programtype
	
	select @ID

	END

ALTER TABLE [dbo].[ARBCBS_ComplexAssessment_Form] ENABLE TRIGGER [trCPAutoCarePlanComplexAssessment]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




CREATE TRIGGER [dbo].[trCPAutoCarePlanComplexAssessmentUpdate] ON [dbo].[ARBCBS_ComplexAssessment_Form]
    AFTER UPDATE
    AS
    BEGIN

	SET NOCOUNT ON;
	DECLARE @ID INT, @mvdid varchar(50), @careplandate date, @author varchar(100), @createdby varchar(50), 
	        @cust_id varchar(40), @programtype varchar(100), @mvdid_inserted varchar(50)

	select @ID = ID, @programtype = qCaseProgram from inserted

	SELECT @mvdid= mvdid, @careplandate= FORMDATE, @author=FORMAUTHOR , @createdby=FORMAUTHOR
	FROM dbo.[ARBCBS_ComplexAssessment_Form] where  ID=@ID

	SELECT @cust_id = custid
	From dbo.FinalMember
	Where MVDId = @mvdid

	--if the MVDID column is in the inserted table check to see if the value is changing. 
	IF UPDATE(MVDID) SELECT @mvdid_inserted = mvdid FROM inserted
	
	IF @mvdid_inserted IS NULL OR @mvdid_inserted = @mvdid 
		--do not execute the proc if the MVDID column is being updated to a new value
		BEGIN
			EXECUTE dbo.CPAutoCarePlan 'ARBCBS_ComplexAssessment', @cust_id, 1, @ID, @author, @programtype
		END 

	select @ID

	END

ALTER TABLE [dbo].[ARBCBS_ComplexAssessment_Form] ENABLE TRIGGER [trCPAutoCarePlanComplexAssessmentUpdate]