/****** Object:  Table [dbo].[ABCBS_MASocialAssessment_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_MASocialAssessment_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[Version] [varchar](3) NULL,
	[docTag] [varchar](50) NULL,
	[qConsultation] [varchar](max) NULL,
	[qConsulationOther] [varchar](max) NULL,
	[qMajorConcerns] [varchar](max) NULL,
	[qMaritalStatus] [varchar](max) NULL,
	[qVeteran] [varchar](max) NULL,
	[qCareGiver] [varchar](max) NULL,
	[qGeneralComments] [varchar](max) NULL,
	[qEnoughGroceries] [varchar](max) NULL,
	[qFoodInsecurityComments] [varchar](max) NULL,
	[qStableHousing] [varchar](max) NULL,
	[qStableHousing1] [varchar](max) NULL,
	[qHousingComments] [varchar](max) NULL,
	[qUtilities] [varchar](max) NULL,
	[qUtilitiesComments] [varchar](max) NULL,
	[qBills] [varchar](max) NULL,
	[qBillsComments] [varchar](max) NULL,
	[qfinancial] [varchar](max) NULL,
	[qfinancialComments] [varchar](max) NULL,
	[qAssistance] [varchar](max) NULL,
	[qAssistanceComments] [varchar](max) NULL,
	[qTransportation] [varchar](max) NULL,
	[qTransportationComments] [varchar](max) NULL,
	[qViolence] [varchar](max) NULL,
	[qViolenceComments] [varchar](max) NULL,
	[qCaregiving] [varchar](max) NULL,
	[qCaregivingComments] [varchar](max) NULL,
	[qEducation] [varchar](max) NULL,
	[qEducationComments] [varchar](max) NULL,
	[qEmployment] [varchar](max) NULL,
	[qIncomeSources] [varchar](max) NULL,
	[qIncomeOther] [varchar](max) NULL,
	[qEmploymentComments] [varchar](max) NULL,
	[qHealthBehaviors] [varchar](max) NULL,
	[qAlcohol] [varchar](max) NULL,
	[qOtherDrugs] [varchar](max) NULL,
	[qRecentChanges] [varchar](max) NULL,
	[qExcercise] [varchar](max) NULL,
	[qAssistiveDevices] [varchar](max) NULL,
	[qHealthBehavioursComments] [varchar](max) NULL,
	[qSocialIsolation] [varchar](max) NULL,
	[qSocialIsolationComments] [varchar](max) NULL,
	[qMentalHealthNeed] [varchar](max) NULL,
	[qBHComments] [varchar](max) NULL,
	[qAdvDirectives] [varchar](max) NULL,
	[qAdvDirectiveComments] [varchar](max) NULL,
	[qUrgency] [varchar](max) NULL,
	[qAdditionalQuest] [varchar](max) NULL,
	[qSummary] [varchar](max) NULL,
	[IsLocked] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE TRIGGER [dbo].[trCPAutoCarePlanMASocialWork] ON [dbo].[ABCBS_MASocialAssessment_Form]
    AFTER INSERT
    AS
    BEGIN

	SET NOCOUNT ON;
	DECLARE 
	@ID INT, @mvdid varchar(50), @careplandate date, @author varchar(100), @createdby varchar(50), @cust_id varchar(40)

	select @ID = ID from inserted

	SELECT @mvdid= mvdid, @careplandate= FORMDATE, @author=FORMAUTHOR , @createdby=FORMAUTHOR
	FROM dbo.ABCBS_MASocialAssessment_Form where  ID=@ID

	SELECT @cust_id = cust_id
	From dbo.Link_MemberId_MVD_Ins
	Where MVDId = @mvdid

	EXECUTE dbo.CPAutoCarePlan 'ABCBS_MASocialAssessment', @cust_id, 1, @ID, @author, 'Social Work'
	
	select @ID

	END

ALTER TABLE [dbo].[ABCBS_MASocialAssessment_Form] ENABLE TRIGGER [trCPAutoCarePlanMASocialWork]