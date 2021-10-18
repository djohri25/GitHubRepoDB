/****** Object:  Table [dbo].[ABCBS_MaternityComplexAssessment_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_MaternityComplexAssessment_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[q1Questions] [varchar](max) NULL,
	[q2MedCareEmotionalCond] [varchar](max) NULL,
	[q3Treatment] [varchar](max) NULL,
	[q3Treatment1] [varchar](max) NULL,
	[q4MedCareMedCond] [varchar](max) NULL,
	[q4MedCareMedCond1] [varchar](max) NULL,
	[q5Specialist] [varchar](max) NULL,
	[q5PrescriptionMed] [varchar](max) NULL,
	[q6PrimaryCareProviderAware] [varchar](max) NULL,
	[q7CMInstructedImpPCP] [varchar](max) NULL,
	[q8WhyTheseMedications] [varchar](max) NULL,
	[q9problemsObtainingMedicine] [varchar](max) NULL,
	[q10MedicationsAsInstructed] [varchar](max) NULL,
	[q11WhyMedicationNotTaken] [varchar](max) NULL,
	[q11WhyMedicationNotTaken1] [varchar](max) NULL,
	[q12PCPprovidedSampleMed] [varchar](max) NULL,
	[q13PharmacyName] [varchar](max) NULL,
	[q14Contraceptives] [varchar](max) NULL,
	[q15AnyonePrescription] [varchar](max) NULL,
	[q16StreetDrugs] [varchar](max) NULL,
	[q17FamilyHistory] [varchar](max) NULL,
	[q18Concerns] [varchar](max) NULL,
	[q18ConcernsOther] [varchar](max) NULL,
	[q19CommunityServices] [varchar](max) NULL,
	[q19CommunityServicesOther] [varchar](max) NULL,
	[q20SafetyRisks] [varchar](max) NULL,
	[q20SafetyRisks1] [varchar](max) NULL,
	[q21FillingMedicalForms] [varchar](max) NULL,
	[q22Upset] [varchar](max) NULL,
	[q23Pregnancy] [varchar](max) NULL,
	[q24PhysicalAbuse] [varchar](max) NULL,
	[q25TransmittedDisease] [varchar](max) NULL,
	[q26TeethCleaned] [varchar](max) NULL,
	[q27OralHealth] [varchar](max) NULL,
	[q28Experienced] [varchar](max) NULL,
	[q29IfNausea] [varchar](max) NULL,
	[q30Water] [varchar](max) NULL,
	[q31SymptomsOfDehyrdration] [varchar](max) NULL,
	[q32LabworkPhysician] [varchar](max) NULL,
	[q33Excercising] [varchar](max) NULL,
	[q33AvoidDiet] [varchar](max) NULL,
	[q34StressLevel] [varchar](max) NULL,
	[q35PhysicallyDemanding] [varchar](max) NULL,
	[q36Dizziness] [varchar](max) NULL,
	[q37] [varchar](max) NULL,
	[q38GlucoseTolerance] [varchar](max) NULL,
	[q39Date] [datetime] NULL,
	[q40WeightGained] [varchar](max) NULL,
	[q41BabyMoving] [varchar](max) NULL,
	[q42FluShot] [varchar](max) NULL,
	[q43] [varchar](max) NULL,
	[q44Csection] [varchar](max) NULL,
	[q45] [varchar](max) NULL,
	[q46DateofProcedure] [datetime] NULL,
	[q47Labor] [varchar](max) NULL,
	[q48BabyMovement] [varchar](max) NULL,
	[q49SurgicalWound] [varchar](max) NULL,
	[q50] [varchar](max) NULL,
	[q51] [varchar](max) NULL,
	[q52] [varchar](max) NULL,
	[q53] [varchar](max) NULL,
	[q54PainAfterMedication] [varchar](max) NULL,
	[q55UnresolvedPain] [varchar](max) NULL,
	[q56Caregiver] [varchar](max) NULL,
	[q160ADate] [datetime] NULL,
	[q163Date] [datetime] NULL,
	[q56Gestation] [varchar](max) NULL,
	[q57Preterm] [varchar](max) NULL,
	[q57HowManyBabies] [varchar](max) NULL,
	[q58BirthWeight] [varchar](max) NULL,
	[q59Sex] [varchar](max) NULL,
	[q60NoOfDays] [varchar](max) NULL,
	[q61IntensiveCare] [varchar](max) NULL,
	[q61IntensiveCare1] [varchar](max) NULL,
	[q62BirthWeight] [varchar](max) NULL,
	[q63Sex] [varchar](max) NULL,
	[q64NoOfDays] [varchar](max) NULL,
	[q65IntensiveCare] [varchar](max) NULL,
	[q65IntensiveCare1] [varchar](max) NULL,
	[q66BirthWeight] [varchar](max) NULL,
	[q67Sex] [varchar](max) NULL,
	[q68NoOfDays] [varchar](max) NULL,
	[q69IntensiveCare] [varchar](max) NULL,
	[q69IntensiveCare1] [varchar](max) NULL,
	[q70BirthWeight] [varchar](max) NULL,
	[q71Sex] [varchar](max) NULL,
	[q72NoOfDays] [varchar](max) NULL,
	[q73IntensiveCare] [varchar](max) NULL,
	[q73IntensiveCare1] [varchar](max) NULL,
	[q74BirthWeight] [varchar](max) NULL,
	[q75Sex] [varchar](max) NULL,
	[q76NoOfDays] [varchar](max) NULL,
	[q77IntensiveCare] [varchar](max) NULL,
	[q77IntensiveCare1] [varchar](max) NULL,
	[q78BirthWeight] [varchar](max) NULL,
	[q79Sex] [varchar](max) NULL,
	[q80NoOfDays] [varchar](max) NULL,
	[q81IntensiveCare] [varchar](max) NULL,
	[q81IntensiveCare1] [varchar](max) NULL,
	[q82BirthWeight] [varchar](max) NULL,
	[q83Sex] [varchar](max) NULL,
	[q84NoOfDays] [varchar](max) NULL,
	[q85IntensiveCare] [varchar](max) NULL,
	[q85IntensiveCare1] [varchar](max) NULL,
	[q86MomInHosp] [varchar](max) NULL,
	[q87TypeOfDelivery] [varchar](max) NULL,
	[q88ReasonForInduction] [varchar](max) NULL,
	[q89CSection] [varchar](max) NULL,
	[q89CSection1] [varchar](max) NULL,
	[q90HomeHealthNurse] [varchar](max) NULL,
	[q91Currently] [varchar](max) NULL,
	[q92TeethCleaned] [varchar](max) NULL,
	[q93PhysicianTalked] [varchar](max) NULL,
	[q94Tobacco] [varchar](max) NULL,
	[q95EnrollTobacco] [varchar](max) NULL,
	[q95EnrollTobacco1] [varchar](max) NULL,
	[q95EnrollTobacco2] [varchar](max) NULL,
	[q96] [varchar](max) NULL,
	[q97BirthControl] [varchar](max) NULL,
	[q97Other] [varchar](max) NULL,
	[q98PCP] [varchar](max) NULL,
	[q99EduMember] [varchar](max) NULL,
	[q100PediaTricianForBaby] [varchar](max) NULL,
	[q101PostPartumVisit] [datetime] NULL,
	[q102VisitInRange] [varchar](max) NULL,
	[q103Mammogram] [varchar](max) NULL,
	[q104PapSmear] [varchar](max) NULL,
	[q105AddBaby] [varchar](max) NULL,
	[q106OBNurse] [varchar](max) NULL,
	[q107OBNurse] [varchar](max) NULL,
	[q108Prenatal] [varchar](max) NULL,
	[q109Material] [varchar](max) NULL,
	[q110Rate] [varchar](max) NULL,
	[q110Hear] [varchar](max) NULL,
	[qComments] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_MaternityComplexAssessment_Form] ON [dbo].[ABCBS_MaternityComplexAssessment_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_MaternityComplexAssessment_Form_FormDate] ON [dbo].[ABCBS_MaternityComplexAssessment_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_MaternityComplexAssessment_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE TRIGGER [dbo].[trCPAutoCarePlanMaternityComplexAssessment] ON [dbo].[ABCBS_MaternityComplexAssessment_Form]
    AFTER INSERT
    AS
    BEGIN

	SET NOCOUNT ON;
	DECLARE 
	@ID INT, @mvdid varchar(50), @careplandate date, @author varchar(100), @createdby varchar(50), @cust_id varchar(40)

	select @ID = ID from inserted

	SELECT @mvdid= mvdid, @careplandate= FORMDATE, @author=FORMAUTHOR , @createdby=FORMAUTHOR
	FROM dbo.ABCBS_MaternityComplexAssessment_Form where  ID=@ID

	SELECT @cust_id = cust_id
	From dbo.Link_MemberId_MVD_Ins
	Where MVDId = @mvdid

	EXECUTE dbo.CPAutoCarePlan 'ABCBS_MaternityComplexAssessment', @cust_id, 1, @ID, @author, 'Maternity'
	
	select @ID

	END

ALTER TABLE [dbo].[ABCBS_MaternityComplexAssessment_Form] ENABLE TRIGGER [trCPAutoCarePlanMaternityComplexAssessment]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE TRIGGER [dbo].[trCPAutoCarePlanMaternityComplexAssessmentUpdate] ON [dbo].[ABCBS_MaternityComplexAssessment_Form]
    AFTER UPDATE
    AS
    BEGIN

	SET NOCOUNT ON;
	DECLARE @ID INT, @mvdid varchar(50), @careplandate date, @author varchar(100), @createdby varchar(50), @cust_id varchar(40), @mvdid_inserted varchar(50)
	
	select @ID = ID from inserted

	SELECT @mvdid= mvdid, @careplandate= FORMDATE, @author=FORMAUTHOR , @createdby=FORMAUTHOR
	FROM dbo.ABCBS_MaternityComplexAssessment_Form where  ID=@ID

	SELECT @cust_id = cust_id
	From dbo.Link_MemberId_MVD_Ins
	Where MVDId = @mvdid

	--if the MVDID column is in the inserted table check to see if the value is changing.
	--get the value
	IF UPDATE(MVDID) SELECT @mvdid_inserted = mvdid FROM inserted
	
	IF @mvdid_inserted IS NULL OR @mvdid_inserted = @mvdid 
		--do not execute the proc if the MVDID column is being updated to a new value
		BEGIN
			EXECUTE dbo.CPAutoCarePlan 'ABCBS_MaternityComplexAssessment', @cust_id, 1, @ID, @author, 'Maternity'
		END 

	select @ID

	END

ALTER TABLE [dbo].[ABCBS_MaternityComplexAssessment_Form] ENABLE TRIGGER [trCPAutoCarePlanMaternityComplexAssessmentUpdate]