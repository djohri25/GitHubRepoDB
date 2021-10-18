/****** Object:  Procedure [dbo].[Get_FormPostPartumAssessmentByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormPostPartumAssessmentByID]
@ID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1[ID]
      ,F.[MVDID]
      ,F.[CustID]
      ,F.[StaffInterviewing]
      ,F.[FormDate]
      ,F.[Gender]
      ,F.[DateOfBirth]
      ,F.[PLan]
      ,F.[ProviderIDNumber]
      ,F.[Address]
      ,F.[City]
      ,F.[State]
      ,F.[Zip]
      ,F.[MemberPhone]
      ,F.[MemberOtherPhone]
      ,F.[MemberExt]
      ,F.[MemberEmail]
      ,F.[ParentLegalGuardian]
      ,F.[GuardianPhone]
      ,[GuardianOtherPhone]
      ,[GuardianExt]
      ,[IntroductionOfCMRole]
      ,[MemberAgreeToCMservices]
      ,[CMServicesReason]
      ,[PrimaryCareProvider]
      ,[ProviderContactNumber]
      ,[DateofLastVisit]
      ,[ReliableTransportation]
      ,[HaveOBProvider]
      ,[HelpFindingOBprovider]
      ,[OBProviderContactNumber]
      ,[OBProviderOfficeLocation]
      ,[OBProviderNames]
      ,[OBProviderDateOfVisit]
      ,[FirstOBVisit]
      ,[DiaperGiftCard]
      ,[MotherAdmissionDate]
      ,[MotherDischargeDate]
      ,[MotherExtendedStayReason]
      ,[DeliverDate]
      ,[Vaginal]
      ,[VaginalwTL]
      ,[VBAC]
      ,[VBACwTL]
      ,[CSX]
      ,[CSXwTL]
      ,[BirthWeightLBs]
      ,[BirthWeightOZs]
      ,[BirthWeightGrams]
      ,[BirthCertificateFirstName]
      ,[BirthCertificateMIName]
      ,[BirthCertificateLastName]
      ,[ExtendedStayNICU]
      ,[ReasonExtendedStay]
      ,[BabyDischargeDate]
      ,[PreEclampsia]
      ,[Eclampsia]
      ,[GestationalHypertension]
      ,[HypertensionNotPregnanant]
      ,[GestationalDiabetes]
      ,[DietControl]
      ,[InsulinControl]
      ,[PretermLabor]
      ,[170DuringPregnancy]
      ,[Other]
      ,[ComplicationDescription]
      ,[DeliveryComplications]
      ,[DeliveryComplicationDesc]
      ,[MotherBabyOncehome]
      ,[Breastfeeding]
      ,[FormulaFeeding]
      ,[Both]
      ,[BreastPump]
      ,[WIC]
      ,[SocialProblems]
      ,[EAP]
      ,[MTP]
      ,[keepingDrAppointments]
      ,[AppointmentForMother]
      ,[AppointmentForBaby]
      ,[BabyPediatrician]
      ,[PediatricianContactNumber]
      ,[WereInstructionsProvided]
      ,[EducationalMaterialProvided]
      ,[EducationalMaterialSite]
      ,[OBorPCP]
      ,[SpecialNotes],
		d.FirstName,
		d.LastName
	
  FROM [FormPostPartumAssessment] F
  Left JOIN MainPersonalDetails d ON d.ICENUMBER = F.MVDID
  LEFT JOIN MainInsurance m ON m.ICENUMBER = F.MVDID 
  where F.ID = @ID
  order by f.FormDate desc
END