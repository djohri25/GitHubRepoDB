/****** Object:  Procedure [dbo].[Get_FormERIntakeAssessmentByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Shraddha Chauhan
-- Create date: 5/14/2014 Get_FormGeneralAssessmentByID
-- Description:	Get data from ERIntakeAssessment as per FormID
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormERIntakeAssessmentByID]
@ID varchar(20)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT   TOP 1 [ID],
		F.[MVDID],
		F.[CustID],
		F.[StaffInterviewing],
		F.[FormDate],
		F.[Gender],
		F.[DateOfBirth],
		F.[PLan],
		F.[ProviderIDNumber],
		F.[Address],
		F.[City],
		F.[State],
		F.[Zip],
		F.[MemberPhone],
		F.[MemberOtherPhone],
		F.[MemberExt],
		F.[MemberEmail],
		F.[ParentLegalGuardian],
		F.[GuardianPhone],
		[GuardianOtherPhone],
		[GuardianExt],
		[IntroductionOfCMRole],
		[MemberAgreeToCMservices],
		[CMServicesReason],
		[PrimaryCareProvider],
		[ProviderContactNumber],
		[DateofLastVisit],
		[ReviewedER] ,
		[Networkfacilitiest] ,
		[ClinicsWithinArea] ,
		[MedicalAdvice] ,
		[SetonHealthPlan] ,
		[PostERVisit] ,
		[MedicationPrescriptions] ,
		[PharmacyDelivery] ,
		[ChildCurrentVisits] ,
		[RecommendedImmunizations] ,
		[HealthInsurance] ,
		[InsuranceType] ,
		[ReliableTransportation] ,
		[Transportation],
		[SocialProblems] ,
		[BeaconEAP],
		[AdditionalResource],
		[SpecialNotes],
		d.FirstName,
		d.LastName
    FROM     FormERIntakeAssessment AS F
             LEFT JOIN MainPersonalDetails AS d ON d.ICENUMBER = F.MVDID
             LEFT JOIN MainInsurance AS m ON m.ICENUMBER = F.MVDID
    where F.ID = @ID
  order by f.FormDate desc
END