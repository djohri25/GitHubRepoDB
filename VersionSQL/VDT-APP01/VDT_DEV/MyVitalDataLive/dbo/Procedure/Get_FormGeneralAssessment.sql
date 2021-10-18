/****** Object:  Procedure [dbo].[Get_FormGeneralAssessment]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:  Shraddha Chauhan
-- Create date: 5/14/2014
-- Description: Get data from GeneralAssessment as per MVDID & CustID
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormGeneralAssessment]
@MVDID VARCHAR (20), @CustID VARCHAR (20)=NULL
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
                   [ReliableTransportation],
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
    FROM     FormGeneralAssessment AS F
             LEFT OUTER JOIN
             MainPersonalDetails AS d
             ON d.ICENUMBER = F.MVDID
             LEFT OUTER JOIN
             MainInsurance AS m
             ON m.ICENUMBER = F.MVDID
    WHERE    MVDID = @MVDID
             AND CustID = @CustID
    ORDER BY f.ID DESC;
END