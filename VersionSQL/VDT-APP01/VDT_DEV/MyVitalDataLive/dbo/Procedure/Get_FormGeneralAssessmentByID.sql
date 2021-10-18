/****** Object:  Procedure [dbo].[Get_FormGeneralAssessmentByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:  Shraddha Chauhan
-- Create date: 7/15/2014
-- Description: Get data from GeneralAssessment as per FormID
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormGeneralAssessmentByID]
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
                   [ReliableTransportation] ,
				   [SeeSpecialist],
                   [Specialty],
                   [SpecialistName],
                   [ClinicName],
                   [ClinicLocation],
                   [ClinicPhoneNumber],
                   [NumberOfHospitalVisit6Mnths],
                   [HospLocation],
                   [HospOther],
                   [HospDate],
                   [NumberOfEDVisit],
                   [EDVisitLocation],
                   [EDVisitOther],
                   [MedicalAppointments],
                   [PrimaryDiagnoses],
                   [SocialEnvironment],
                   [BehavioralHealth],
                   [RoutineMedications],
                   [ListOfMedications],
                   [ObtainingYourMedication],
                   [TreatmentRegimen],
                   [DME],
                   [ObtainingYourDME],
                   [SpecialNotes],
                   d.FirstName,
                   d.LastName 
  FROM FormGeneralAssessment F
  Left JOIN MainPersonalDetails d ON d.ICENUMBER = F.MVDID
  LEFT JOIN MainInsurance m ON m.ICENUMBER = F.MVDID 
  where F.ID = @ID
  order by f.FormDate desc
END