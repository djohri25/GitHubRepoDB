/****** Object:  Procedure [dbo].[Get_FormOBIntakeAssessmentByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:  <Author,,Name>
-- Create date: 5/14/2014
-- Description: <Description,,>
-- =============================================[Get_FormOBIntakeAssessmentByID]
CREATE PROCEDURE [dbo].[Get_FormOBIntakeAssessmentByID]
@ID varchar(20)
AS
BEGIN
 SET NOCOUNT ON;

	 SELECT TOP (1)
	 [ID]
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
	,[CMServicesReason],
	[ReliableTransportation],
	[OBProvider] ,
	[FindingOBProvider] ,
	[OBProviderContactNumber] ,
	[OBProviderLocation] ,
	[OBProviderName],
	[FirstTrimester] ,
	[FirstOBVisitDate],
	[GestationFirstOBVisit],
	[CurrentWeekGestation],
	[EDD],
	[Gravida],
	[Para],
	[LC],
	[PreEclampsia] ,
	[Eclampsia] ,
	[GestationalHypertension] ,
	[HypertensionNotPregnanant] ,
	[GestationalDiabetes] ,
	[DietControl] ,
	[InsulinControl] ,
	[PretermLabor] ,
	[TakeP] ,
	[CesareanSection] ,
	[Other] ,
	[ComplicationDescription],
	[MedicalConditionsIllnesses] ,
	[ListMedicalConditionsIllnesses] ,
	[Facility],
	[FacilityOther],
	[FacilityOON],
	[AttendingChildbirthClasses] ,
	F.[Medicaid],
	[MedicaidType],
	[MTP],
	[SocialProblems],
	[BeaconEAP],
	[DrAppointments] ,
	[NextOBAppointment],
	[PediatricianBaby] ,
	[PediatricianName],
	[PediatricianContactNumber],
	[WIC] ,
	[SNAP] ,
	[SupportFromFamily] ,
	[ManagementFollowup] ,
	[SpecialNotes],
	d.FirstName,
	d.LastName
	FROM dbo.FormOBIntakeAssessment F
	LEFT JOIN dbo.MainPersonalDetails d ON d.ICENUMBER = F.MVDID
	LEFT JOIN dbo. MainInsurance m ON m.ICENUMBER = F.MVDID 
	WHERE F.ID = @ID
	ORDER BY f.FormDate desc
END