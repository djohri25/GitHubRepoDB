/****** Object:  Procedure [dbo].[Get_FormData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/24/2011
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Get_FormData]
	@FormType varchar(50),
	@FormID varchar(15),
	@MemberID varchar(50),
	@CustID varchar(15)
AS
BEGIN
	SET NOCOUNT ON;

	if(ISNULL(@formID,'') <> '')
	begin
		if(@FormType = 'CardiacDischarge')
		begin
			select ID as FormID
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
			  ,AdditionalInfoWound, 
				c.Name as hpName,c.cust_id, dbo.FullName(p.lastName,p.FirstName,p.MiddleName) as MemberName, li.InsMemberId as MemID 
			from dbo.Form_CardiacDischarge f
				left join HPCustomer c on f.Cust_ID = c.Cust_ID
				left join Link_MemberId_MVD_Ins li on li.InsMemberId = f.MemberID and li.Cust_ID = f.Cust_ID
				left join MainPersonalDetails p on li.MVDId = p.ICENUMBER
			where ID = @FormID
		end
		else if (@FormType = 'DPET')
		begin
			select ID as FormID
			  ,AdmissionDate
			  ,DischargeDate
			  ,DaysInHospital
			  ,PCP
			  ,PCPPhone
			  ,HospDoctor
			  ,HospDoctorPhone
			  ,OtherDoc1
			  ,OtherDocSpecialty1
			  ,OtherDoc2
			  ,OtherDocSpecialty2
			  ,OtherDoc3
			  ,OtherDocSpecialty3
			  ,DiagStayInHosp
			  ,DiagMedicalWord
			  ,DiagOtherConditions
			  ,TestInHosp1
			  ,TestInHospResult1
			  ,TestInHosp2
			  ,TestInHospResult2
			  ,TestInHosp3
			  ,TestInHospResult3
			  ,TestInHosp4
			  ,TestInHospResult4
			  ,TreatedFor1
			  ,TreatedForPurpose1
			  ,TreatedFor2
			  ,TreatedForPurpose2
			  ,TreatedFor3
			  ,TreatedForPurpose3
			  ,TreatedFor4
			  ,TreatedForPurpose4
			  ,WillFollowup
			  ,FollowupPCP
			  ,FollowupPCPPhone
			  ,FollowupPCPDate
			  ,FollowupPCPTime
			  ,FollowupSpecialist
			  ,FollowupSpecialistPhone
			  ,FollowupSpecialistDate
			  ,FollowupSpecialistTime
			  ,FollowupTest
			  ,FollowupTest1
			  ,FollowupTestLocation1
			  ,FollowupTestDate1
			  ,FollowupTestTime1
			  ,FollowupTest2
			  ,FollowupTestLocation2
			  ,FollowupTestDate2
			  ,FollowupTestTime2
			  ,FollowupTest3
			  ,FollowupTestLocation3
			  ,FollowupTestDate3
			  ,FollowupTestTime3
			  ,WarningSign1
			  ,WarningSign2
			  ,WarningSign3
			  ,WarningSign4
			  ,WarningSign5
			  ,WarningSign6
			  ,LifeStyleChanges
			  ,LifeStyleChangesActivity
			  ,LifeStyleChangesActivityBecause
			  ,LifeStyleChangesDiet
			  ,LifeStyleChangesDietBecause
			  ,NonSmoker
			  ,SmokerQuitting
			  ,LifeStyleFollowupCallDate
			  ,LifeStyleFollowupCallTime
			  ,MedicationStop
			  ,MedicationContinue
			  ,MedicationWhen
			  ,MedicationSideEffects,
				c.cust_id, c.Name as hpName, dbo.FullName(p.lastName,p.FirstName,p.MiddleName) as MemberName, li.InsMemberId as MemID  
			from dbo.Form_DPET f
				left join HPCustomer c on f.Cust_ID = c.Cust_ID
				left join Link_MemberId_MVD_Ins li on li.InsMemberId = f.MemberID and li.Cust_ID = f.Cust_ID
				left join MainPersonalDetails p on li.MVDId = p.ICENUMBER	
			where ID = @FormID
		end
	end
	else
	begin
		-- only retrieve member info
		if(@FormType = 'CardiacDischarge')
		begin
			select '' as FormID, c.cust_id, c.Name as hpName, dbo.FullName(p.lastName,p.FirstName,p.MiddleName) as MemberName, li.InsMemberId as MemID  
			from HPCustomer c 
				inner join Link_MemberId_MVD_Ins li on li.Cust_ID = c.Cust_ID
				inner join MainPersonalDetails p on li.MVDId = p.ICENUMBER				
			where li.InsMemberId = @MemberID and li.Cust_ID = @CustID
		end
		else if (@FormType = 'DPET')
		begin
			select '' as FormID,c.cust_id, c.Name as hpName, dbo.FullName(p.lastName,p.FirstName,p.MiddleName) as MemberName, li.InsMemberId as MemID  
			from HPCustomer c 
				inner join Link_MemberId_MVD_Ins li on li.Cust_ID = c.Cust_ID
				inner join MainPersonalDetails p on li.MVDId = p.ICENUMBER
			where li.InsMemberId = @MemberID and li.Cust_ID = @CustID
		end	
	end
END