/****** Object:  Procedure [dbo].[Set_FormCardiacDischarge]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/1/2011
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Set_FormCardiacDischarge]
	@RecordID int = null,
	@MemberID varchar(15),
	@ModifiedBy varchar(50),
	@Cust_ID int,
	@DiagACS bit,
	@DiagMI bit,
	@DiagCAD bit,
	@DiagHF bit,
	@DiagHHD bit,
	@DiagIH bit,
	@ProcDiagCath bit,
	@ProcCoronaryInter bit,
	@ProcICD bit,
	@EjectionFractionDysfunction bit,
	@MedListReviewed bit,
	@MedAspirinAllergic bit,
	@MedPlavixAllergic bit,
	@MedACEAllergic bit,
	@MedACELowBP bit,
	@MedACECough bit,
	@MedACERenal bit,
	@MedACEOther bit,
	@MedARBAllergic bit,
	@MedARBLowBP bit,
	@MedARBRenal bit,
	@MedARBOther bit,
	@MedBetaBlockerLowPulse bit,
	@MedBetaBlockerLungDisease bit,
	@MedBetaBlockerLowBP bit,
	@MedBetaBlockerOther bit,
	@MedLipidAllergic bit,
	@MedLipidOutpatient bit,
	@MedFishOil bit,
	@MedSeeAdditionalSheet bit,	
	@FollowupLabPending bit,
	@ContDocForChestPain bit,
	@ContDocForIncreasedPain bit,
	@ContDocForRedness bit,
	@ActivityAfterNoActivity bit,
	@ActivityAfterNoDriving bit,
	@ActivityAfterReturnToWork bit,
	@ActivityAfterGraduallyIncrease bit,
	@ActivityAfterSex bit,
	@ContDocForVomiting bit,
	@ContDocForTemp bit,
	@ContDocForOther varchar(50),
	@DietRecInfoMeditAmer bit,
	@DietRecInfoLowFat bit,
	@DietRecInfoSodium bit,
	@DietRecInfoFluid bit,
	@DietRecInfoDiabetic bit,
	@DietRecInfoOther bit,
	@LearnHeartDisAcute bit,
	@LearnHeartDisCoumadin bit,
	@LearnHeartDisClosure bit,
	@LearnHeartDisPostInstr bit,
	@LearnHeartDisPostPacerInstr bit,
	@LearnHeartDisCardiacRehab bit,
	@LearnHeartDisCardiacCath bit,
	@LearnHeartDisDiuretics bit,
	@LearnHeartDisOther bit,
	@HeartFailureNA bit,
	@HeartFailureGivenNotebook bit,
	@ReferralsHeartFailure bit,
	@ReferralsCardiacRehab bit,
	@ReferralsRiskReduction bit,
	@VaccinesFlu bit,
	@VaccinesPneumania bit,
	
	@DiagOther varchar(50),
	@ProcOther varchar(50),
	@EjectionFractionPerc int,
	@EjectionFraction2 varchar(15),
	@MedAspririnDose varchar(50),
	@MedAspirinOther varchar(50),
	@MedPlavixDose varchar(50),
	@MedPlavixOther varchar(50),
	@MedACEDose varchar(50),
	@MedARBDose varchar(50),
	@MedBetaBlockerDose varchar(50),
	@MedLipidDose varchar(50),
	@MedAldosteroneDose varchar(50),
	@MedAldosteroneNotApply varchar(50),
	@MedAnticoagulantDose varchar(50),
	@MedAnticoagulantNotApply varchar(50),
	@MedDiureticDose varchar(50),
	@MedDiureticNotApply varchar(50),
	@MedNitrateDose varchar(50),
	@MedNitrateNotApply varchar(50),
	@MedPotassiumDose varchar(50),
	@MedPotassiumNotApply varchar(50),
	@MedFishOilDose varchar(50),
	@MedFishOilNotApply varchar(50),

	@FollowupAptLocation1 varchar(50),
	@FollowupAptPhone1 varchar(50),
	@FollowupAptWhen1 varchar(50),
	@FollowupAptLocation2 varchar(50),
	@FollowupAptPhone2 varchar(50),
	@FollowupAptWhen2 varchar(50),
	@FollowupAptLocation3 varchar(50),
	@FollowupAptPhone3 varchar(50),
	@FollowupAptWhen3 varchar(50),
	@FollowupLabCholesterol varchar(50),
	@FollowupLabLDL varchar(50),
	@FollowupLabHDL varchar(50),
	@FollowupLabTriglycerides varchar(50),
	@ActivityAfterNoActivityUntil varchar(50),
	@ActivityAfterNoDrivingFor varchar(50),
	@ActivityAfterReturnToWorkText varchar(50),
	@DietRecInfoFluidText varchar(50),
	@DietRecInfoDiabeticText varchar(50),
	@DietRecInfoOtherText varchar(50),

	@LearnHeartDisOtherText varchar(50),
	@HeartFailureDischargeWeight varchar(50),
	@HeartFailureWeightAtHome varchar(50),

	@CommunityAgency varchar(50),
	@HomeHCAgency varchar(50),
	@VaccinesFluDate varchar(50),
	@VaccinesPneumaniaDate varchar(50),
	@AdditionalInfoPainMgmt varchar(50),
	@AdditionalInfoWound varchar(50)
	,
	@FollowupAptCall1 tinyint,
	@FollowupAptCall2 tinyint,
	@FollowupAptCall3 tinyint
	

	
AS
BEGIN

	SET NOCOUNT ON;

	--declare 



	if(@RecordID is not null AND @RecordID <> 0)
	begin
		delete from Form_CardiacDischarge where ID = @RecordID
	end
	
	INSERT INTO Form_CardiacDischarge
           (MemberID
           ,Cust_ID
           ,DiagACS
           ,DiagMI
           ,DiagCAD
           ,DiagHF
           ,DiagHHD
           ,DiagIH
           ,DiagOther
           ,ProcDiagCath
           ,ProcCoronaryInter
           ,ProcICD
           ,ProcOther
           ,EjectionFractionPerc
           ,EjectionFraction2
           ,EjectionFractionDysfunction
           ,MedListReviewed
           ,MedAspririnDose
           ,MedAspirinAllergic
           ,MedAspirinOther
           ,MedPlavixDose
           ,MedPlavixAllergic
           ,MedPlavixOther
           ,MedACEDose
           ,MedACEAllergic
           ,MedACELowBP
           ,MedACECough
           ,MedACERenal
           ,MedACEOther
           ,MedARBDose
           ,MedARBAllergic
           ,MedARBLowBP
           ,MedARBRenal
           ,MedARBOther
           ,MedBetaBlockerDose
           ,MedBetaBlockerLowPulse
           ,MedBetaBlockerLungDisease
           ,MedBetaBlockerLowBP
           ,MedBetaBlockerOther
           ,MedLipidDose
           ,MedLipidAllergic
           ,MedLipidOutpatient
           ,MedAldosteroneDose
           ,MedAldosteroneNotApply
           ,MedAnticoagulantDose
           ,MedAnticoagulantNotApply
           ,MedDiureticDose
           ,MedDiureticNotApply
           ,MedNitrateDose
           ,MedNitrateNotApply
           ,MedPotassiumDose
           ,MedPotassiumNotApply
           ,MedFishOil
           ,MedFishOilDose
           ,MedFishOilNotApply
           ,MedSeeAdditionalSheet
           ,FollowupAptLocation1
           ,FollowupAptPhone1
           ,FollowupAptWhen1
           ,FollowupAptCall1
           ,FollowupAptLocation2
           ,FollowupAptPhone2
           ,FollowupAptWhen2
           ,FollowupAptCall2
           ,FollowupAptLocation3
           ,FollowupAptPhone3
           ,FollowupAptWhen3
           ,FollowupAptCall3
           ,FollowupLabCholesterol
           ,FollowupLabLDL
           ,FollowupLabHDL
           ,FollowupLabTriglycerides
           ,FollowupLabPending
           ,ContDocForChestPain
           ,ContDocForIncreasedPain
           ,ContDocForRedness
           ,ActivityAfterNoActivity
           ,ActivityAfterNoActivityUntil
           ,ActivityAfterNoDriving
           ,ActivityAfterNoDrivingFor
           ,ActivityAfterReturnToWork
           ,ActivityAfterReturnToWorkText
           ,ActivityAfterGraduallyIncrease
           ,ActivityAfterSex
           ,ContDocForVomiting
           ,ContDocForTemp
           ,ContDocForOther
           ,DietRecInfoMeditAmer
           ,DietRecInfoLowFat
           ,DietRecInfoSodium
           ,DietRecInfoFluid
           ,DietRecInfoFluidText
           ,DietRecInfoDiabetic
           ,DietRecInfoDiabeticText
           ,DietRecInfoOther
           ,DietRecInfoOtherText
           ,LearnHeartDisAcute
           ,LearnHeartDisCoumadin
           ,LearnHeartDisClosure
           ,LearnHeartDisPostInstr
           ,LearnHeartDisPostPacerInstr
           ,LearnHeartDisCardiacRehab
           ,LearnHeartDisCardiacCath
           ,LearnHeartDisDiuretics
           ,LearnHeartDisOther
           ,LearnHeartDisOtherText
           ,HeartFailureNA
           ,HeartFailureDischargeWeight
           ,HeartFailureWeightAtHome
           ,HeartFailureGivenNotebook
           ,ReferralsHeartFailure
           ,ReferralsCardiacRehab
           ,ReferralsRiskReduction
           ,CommunityAgency
           ,HomeHCAgency
           ,VaccinesFlu
           ,VaccinesFluDate
           ,VaccinesPneumania
           ,VaccinesPneumaniaDate
           ,AdditionalInfoPainMgmt
           ,AdditionalInfoWound
           ,CreatedBy
           ,DateCreated
           ,ModifiedBy
           ,DateModified)
     VALUES
           (@MemberID
           ,@Cust_ID
           ,@DiagACS
           ,@DiagMI
           ,@DiagCAD
           ,@DiagHF
           ,@DiagHHD
           ,@DiagIH
           ,@DiagOther
           ,@ProcDiagCath
           ,@ProcCoronaryInter
           ,@ProcICD
           ,@ProcOther
           ,@EjectionFractionPerc
           ,@EjectionFraction2
           ,@EjectionFractionDysfunction
           ,@MedListReviewed
           ,@MedAspririnDose
           ,@MedAspirinAllergic
           ,@MedAspirinOther
           ,@MedPlavixDose
           ,@MedPlavixAllergic
           ,@MedPlavixOther
           ,@MedACEDose
           ,@MedACEAllergic
           ,@MedACELowBP
           ,@MedACECough
           ,@MedACERenal
           ,@MedACEOther
           ,@MedARBDose
           ,@MedARBAllergic
           ,@MedARBLowBP
           ,@MedARBRenal
           ,@MedARBOther
           ,@MedBetaBlockerDose
           ,@MedBetaBlockerLowPulse
           ,@MedBetaBlockerLungDisease
           ,@MedBetaBlockerLowBP
           ,@MedBetaBlockerOther
           ,@MedLipidDose
           ,@MedLipidAllergic
           ,@MedLipidOutpatient
           ,@MedAldosteroneDose
           ,@MedAldosteroneNotApply
           ,@MedAnticoagulantDose
           ,@MedAnticoagulantNotApply
           ,@MedDiureticDose
           ,@MedDiureticNotApply
           ,@MedNitrateDose
           ,@MedNitrateNotApply
           ,@MedPotassiumDose
           ,@MedPotassiumNotApply
           ,@MedFishOil
           ,@MedFishOilDose
           ,@MedFishOilNotApply
           ,@MedSeeAdditionalSheet
           ,@FollowupAptLocation1
           ,@FollowupAptPhone1
           ,@FollowupAptWhen1
           ,@FollowupAptCall1
           ,@FollowupAptLocation2
           ,@FollowupAptPhone2
           ,@FollowupAptWhen2
           ,@FollowupAptCall2
           ,@FollowupAptLocation3
           ,@FollowupAptPhone3
           ,@FollowupAptWhen3
           ,@FollowupAptCall3
           ,@FollowupLabCholesterol
           ,@FollowupLabLDL
           ,@FollowupLabHDL
           ,@FollowupLabTriglycerides
           ,@FollowupLabPending
           ,@ContDocForChestPain
           ,@ContDocForIncreasedPain
           ,@ContDocForRedness
           ,@ActivityAfterNoActivity
           ,@ActivityAfterNoActivityUntil
           ,@ActivityAfterNoDriving
           ,@ActivityAfterNoDrivingFor
           ,@ActivityAfterReturnToWork
           ,@ActivityAfterReturnToWorkText
           ,@ActivityAfterGraduallyIncrease
           ,@ActivityAfterSex
           ,@ContDocForVomiting
           ,@ContDocForTemp
           ,@ContDocForOther
           ,@DietRecInfoMeditAmer
           ,@DietRecInfoLowFat
           ,@DietRecInfoSodium
           ,@DietRecInfoFluid
           ,@DietRecInfoFluidText
           ,@DietRecInfoDiabetic
           ,@DietRecInfoDiabeticText
           ,@DietRecInfoOther
           ,@DietRecInfoOtherText
           ,@LearnHeartDisAcute
           ,@LearnHeartDisCoumadin
           ,@LearnHeartDisClosure
           ,@LearnHeartDisPostInstr
           ,@LearnHeartDisPostPacerInstr
           ,@LearnHeartDisCardiacRehab
           ,@LearnHeartDisCardiacCath
           ,@LearnHeartDisDiuretics
           ,@LearnHeartDisOther
           ,@LearnHeartDisOtherText
           ,@HeartFailureNA
           ,@HeartFailureDischargeWeight
           ,@HeartFailureWeightAtHome
           ,@HeartFailureGivenNotebook
           ,@ReferralsHeartFailure
           ,@ReferralsCardiacRehab
           ,@ReferralsRiskReduction
           ,@CommunityAgency
           ,@HomeHCAgency
           ,@VaccinesFlu
           ,@VaccinesFluDate
           ,@VaccinesPneumania
           ,@VaccinesPneumaniaDate
           ,@AdditionalInfoPainMgmt
           ,@AdditionalInfoWound
           ,@ModifiedBy
           ,GETUTCDATE()
           ,@ModifiedBy
           ,GETUTCDATE())

END