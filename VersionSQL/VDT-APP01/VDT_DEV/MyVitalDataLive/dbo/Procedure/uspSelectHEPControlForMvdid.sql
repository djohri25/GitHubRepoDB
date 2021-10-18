/****** Object:  Procedure [dbo].[uspSelectHEPControlForMvdid]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 11/05/2019
-- Description:	Get HEP control record for provided MVDID
-- Example: exec uspSelectHEPControlForMvdid '16F05B0074EA380985FC'
-- =============================================
CREATE PROCEDURE [dbo].[uspSelectHEPControlForMvdid] 
	@MVDID varchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select
		[RecordID] as RecordID,
		[Adult_Asthma_OriginalCaseFindDate] as 'adultAsthmaOCFDate',
		[Adult_Asthma_MostRecentCaseFindDate] as 'adultAsthmaMRCFDate',
		[Adult_Asthma_MostRecentEnrollDate] as 'adultAsthmaMREDate',
		[Adult_Asthma_MostRecentCompleteDate] as 'adultAsthmaMRCDate',
		[Adult_Asthma_ExcludeProgram] as 'adultAsthmaEP',
		[Adult_Cardio_OriginalCaseFindDate] as 'adultCardioOCFDate',
		[Adult_Cardio_MostRecentCaseFindDate] as 'adultCardioMRCFDate',
		[Adult_Cardio_MostRecentEnrollDate] as 'adultCardioMREDate',
		[Adult_Cardio_MostRecentCompleteDate] as 'adultCardioMRCDate',
		[Adult_Cardio_ExcludeProgram] as 'adultCardioEP',
		[Adult_CHF_OriginalCaseFindDate] as 'adultCHFOCFDate',
		[Adult_CHF_MostRecentCaseFindDate] as 'adultCHFMRCFDate',
		[Adult_CHF_MostRecentEnrollDate] as 'adultCHFMREDate',
		[Adult_CHF_MostRecentCompleteDate] as 'adultCHFMRCDate',
		[Adult_CHF_ExcludeProgram] as 'adultCHFEP',
		[Adult_COPD_OriginalCaseFindDate] as 'adultCOPDOCFDate',
		[Adult_COPD_MostRecentCaseFindDate] as 'adultCOPDMRCFDate',
		[Adult_COPD_MostRecentEnrollDate] as 'adultCOPDMREDate',
		[Adult_COPD_MostRecentCompleteDate] as 'adultCOPDMRCDate',
		[Adult_COPD_ExcludeProgram] as 'adultCOPDEP',
		[Adult_Diabetes_OriginalCaseFindDate] as 'adultDiabetesOCFDate',
		[Adult_Diabetes_MostRecentCaseFindDate] as 'adultDiabetesMRCFDate',
		[Adult_Diabetes_MostRecentEnrollDate] as 'adultDiabetesMREDate',
		[Adult_Diabetes_MostRecentCompleteDate] as 'adultDiabetesMRCDate',
		[Adult_Diabetes_ExcludeProgram] as 'adultDiabetesEP',
		[Adult_Weigh_OriginalCaseFindDate] as 'adultHealthyWeightOCFDate',
		[Adult_Weigh_MostRecentCaseFindDate] as 'adultHealthyWeightMRCFDate',
		[Adult_Weigh_MostRecentEnrollDate] as 'adultHealthyWeightMREDate',
		[Adult_Weigh_MostRecentCompleteDate] as 'adultHealthyWeightMRCDate',
		[Adult_Weigh_ExcludeProgram] as 'adultHealthyWeightEP',
		[Adult_LBP_OriginalCaseFindDate] as 'adultLowBackPainOCFDate',
		[Adult_LBP_MostRecentCaseFindDate] as 'adultLowBackPainMRCFDate',
		[Adult_LBP_MostRecentEnrollDate] as 'adultLowBackPainMREDate',
		[Adult_LBP_MostRecentCompleteDate] as 'adultLowBackPainMRCDate',
		[Adult_LBP_ExcludeProgram] as 'adultLowBackPainEP',
		[Adult_LBP_ExcludeProgramLowBack] as 'adultEPLBPSurgery',
		[YouthDiabetes_0to3_OriginalCaseFindDate] as 'youthDiabetesOCFDate03',
		[YouthDiabetes_0to3_MostRecentCaseFindDate] as 'youthDiabetesMRCFDate03',
		[YouthDiabetes_0to3_MostRecentEnrollDate] as 'youthDiabetesMREDate03',
		[YouthDiabetes_0to3_MostRecentCompleteDate] as 'youthDiabetesMRCDate03',
		[YouthDiabetes_0to3_ExcludeProgram] as 'youthDiabetesEP03',
		[YouthDiabetes_4to6_OriginalCaseFindDate] as 'youthDiabetesOCFDate46',
		[YouthDiabetes_4to6_MostRecentCaseFindDate] as 'youthDiabetesMRCFDate46',
		[YouthDiabetes_4to6_MostRecentEnrollDate] as 'youthDiabetesMREDate46',
		[YouthDiabetes_4to6_MostRecentCompleteDate] as 'youthDiabetesMRCDate46',
		[YouthDiabetes_4to6_ExcludeProgram] as 'youthDiabetesEP46',
		[YouthDiabetes_7to14_OriginalCaseFindDate] as 'youthDiabetesOCFDate714',
		[YouthDiabetes_7to14_MostRecentCaseFindDate] as 'youthDiabetesMRCFDate714',
		[YouthDiabetes_7to14_MostRecentEnrollDate] as 'youthDiabetesMREDate714',
		[YouthDiabetes_7to14_MostRecentCompleteDate] as 'youthDiabetesMRCDate714',
		[YouthDiabetes_7to14_ExcludeProgram] as 'youthDiabetesEP714',
		[YouthDiabetes_12to17_OriginalCaseFindDate] as 'youthDiabetesOCFDate1217',
		[YouthDiabetes_12to17_MostRecentCaseFindDate] as 'youthDiabetesMRCFDate1217',
		[YouthDiabetes_12to17_MostRecentEnrollDate] as 'youthDiabetesMREDate1217',
		[YouthDiabetes_12to17_MostRecentCompleteDate] as 'youthDiabetesMRCDate1217',
		[YouthDiabetes_12to17_ExcludeProgram] as 'youthDiabetesEP1217',
		[YouthAsthma_0to3_OriginalCaseFindDate] as 'youthAsthmaOCFDate03',
		[YouthAsthma_0to3_MostRecentCaseFindDate] as 'youthAsthmaMRCFDate03',
		[YouthAsthma_0to3_MostRecentEnrollDate] as 'youthAsthmaMREDate03',
		[YouthAsthma_0to3_MostRecentCompleteDate] as 'youthAsthmaMRCDate03',
		[YouthAsthma_0to3_ExcludeProgram] as 'youthAsthmaEP03',
		[YouthAsthma_4to6_OriginalCaseFindDate] as 'youthAsthmaOCFDate46',
		[YouthAsthma_4to6_MostRecentCaseFindDate] as 'youthAsthmaMRCFDate46',
		[YouthAsthma_4to6_MostRecentEnrollDate] as 'youthAsthmaMREDate46',
		[YouthAsthma_4to6_MostRecentCompleteDate] as 'youthAsthmaMRCDate46',
		[YouthAsthma_4to6_ExcludeProgram] as 'youthAsthmaEP46',
		[YouthAsthma_7to14_OriginalCaseFindDate] as 'youthAsthmaOCFDate714',
		[YouthAsthma_7to14_MostRecentCaseFindDate] as 'youthAsthmaMRCFDate714',
		[YouthAsthma_7to14_MostRecentEnrollDate] as 'youthAsthmaMREDate714',
		[YouthAsthma_7to14_MostRecentCompleteDate] as 'youthAsthmaMRCDate714',
		[YouthAsthma_7to14_ExcludeProgram] as 'youthAsthmaEP714',
		[YouthAsthma_12to17_OriginalCaseFindDate] as 'youthAsthmaOCFDate1217',
		[YouthAsthma_12to17_MostRecentCaseFindDate] as 'youthAsthmaMRCFDate1217',
		[YouthAsthma_12to17_MostRecentEnrollDate] as 'youthAsthmaMREDate1217',
		[YouthAsthma_12to17_MostRecentCompleteDate] as 'youthAsthmaMRCDate1217',
		[YouthAsthma_12to17_ExcludeProgram] as 'youthAsthmaEP1217',
		[HealthEducationProgramEligible] as 'hepEligible',
		[ChronicConditionManagementEligible] as 'ccmEligible',
		CreatedBy,
		CreatedDate,
		UpdatedBy,
		UpdatedDate
	from HEP_Control
	where MVDID = @MVDID
END