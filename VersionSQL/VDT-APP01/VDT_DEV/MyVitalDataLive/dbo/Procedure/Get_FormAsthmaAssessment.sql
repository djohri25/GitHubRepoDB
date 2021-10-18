/****** Object:  Procedure [dbo].[Get_FormAsthmaAssessment]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormAsthmaAssessment]
	@MVDID varchar(20),@CustID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1 f.ID,
		f.MVDID,
		f.CustID,
		f.StaffInterviewing,
		f.FormDate,
		f.Gender,
		f.DateOfBirth,
		f.[Plan] as 'PLan',
		f.ProviderIDNumber as 'ProviderIDNumber',
		f.Address,
		f.[City], 
		f.[State],
		f.Zip,
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
		MemberAgreeableToCMservices ,
		CMServicesReason ,
		PrimaryCareProvider ,
		ProviderContactNumber,
		DateofLastVisit ,
		AshthmaSymptoms ,
		AsthmaSymptomsAreYouOrYourChildHaving ,
		AgeofPrimaryAsthmaDiagnosis,
		WhoManagesAsthma,
		SpecialistProviderNameContactNumber ,
		HosptializationInPastyear,
		Location,
		HosptializationOtherLocation,
		HosptializationDate,
		NumberOfEmergencyDepartmentEDVisitsPast6Months,
		EDVisitsLocation,
		EDVisitsOtherLocation,
		EDvisitInNetworkFacility,
		Excersie,
		RespiratoryInfections,
		SeasonalChanges,
		Cold,
		Humidification,
		Allergans,
		Dust,
		Mold,
		Carpet,
		Fragrances ,
		Pets,
		Pollen,
		Cedar,
		Chemicals,
		DoesAnyoneinYourHouseholdSmoke,
		SmokingCessation,
		DoYouorYourChildReceiveTheFLUVaccineSeasonally,
		FrequencyofprovidervisitsRelatedtoAsthmaManagement,
		DailyMaintenanceMedicaitons,
		Nebilzer,
		RescueInhaler,
		HowOftenUsed,
		PeakFlowMeter,
		Spacer,
		DateOflastPulmonryFunctionTest,
		SchoolInformedOfActionPlanForYourChild  ,
		InhalerAtSchool  ,
		SpecialNotes
  FROM FormAsthmaAssessment f
  Left JOIN MainPersonalDetails d ON d.ICENUMBER = f.MVDID 
  Left JOIN MainInsurance m ON m.ICENUMBER = f.MVDID 
  where MVDID = @MVDID and CustID= @CustID
  order by f.ID desc
END