/****** Object:  Procedure [dbo].[Get_FormDiabetesAssessmentByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormDiabetesAssessmentByID]
		@ID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1 f.ID,
			f.MVDID,
			f.StaffInterviewing,
			f.FormDate,
			f.Gender,
			f.DateOfBirth,
			f.[Plan] as 'PLan',
			f.ProviderIDNumber as 'ProviderIDNumber',
			f.Address,
			f.[City] ,
			f.[State],
			f.Zip ,
			f.MemberPhone,
			f.MemberOtherPhone ,
			f.MemberExt ,
			f.MemberEmail,
			d.FirstName,
			d.LastName,
			ParentLegalGuardian,
			GuardianPhone ,
			GuardianOtherPhone,
			GuardianExt ,
			IntroductionOfCMRole ,
			MemberAgreeToCMservices,
			CMServicesReason ,
			PrimaryCareProvider ,
			ProviderContactNumber,
			DateofLastVisit ,
			Type1,
			Type2,
			ChildTakeInsulin,
			ChildInsulinDetails,
			OralHypoglycemicAgents,
			AgeatDiagnosis,
			ChildsDiabetesName,
			ChildsDiabetesLocation,
			ChildsDiabetesContact,
			SpecialistDiabetesName ,
			SpecialistDiabetesContact,
			SpecialistDiabetesName1,
			SpecialistDiabetesContact1,
			DoctorforDiabetesManagement,
			HospPastYear,
			HospLocation,
			HospOtherLocation,
			HospDate,
			NumberOfEDVisitsPast6Months,
			EDVisitsLocation,
			EDVisitsOtherLocation,
			Dates,
			BloodGlucoseLevels ,
			BloodGlucoseRange,
			HbA1clevel  ,
			CholesterolScreen,
			CholesterolScreenResult,
			BloodPressureChecked,
			BloodPressureResults,
			VisionExam,
			MediInstructions,
			RoutineVisit,
			LossOfSensation,
			ClosedTtoeShoes,
			DMEducation,
			FLUVaccineSeasonally,
			HowDescribeChildDM,
			HowOftenChildDM,
			DoctorAppointments,
			DiffDiabetesmanagement,
			SpecialNotes
  FROM FormDiabetesAssessment f
  Left JOIN MainPersonalDetails d ON d.ICENUMBER = f.MVDID
  Left JOIN MainInsurance m ON m.ICENUMBER = f.MVDID 
  where ID = @ID
   order by f.FormDate desc
END