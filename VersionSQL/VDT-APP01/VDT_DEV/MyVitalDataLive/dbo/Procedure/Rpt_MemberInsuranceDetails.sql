/****** Object:  Procedure [dbo].[Rpt_MemberInsuranceDetails]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Rpt_MemberInsuranceDetails]
(
	@ICENUMBER varchar(15)
)
AS
BEGIN 

SELECT @ICENUMBER as ICENUMBER, Dual as [DualEligible], MedicareID as [MedicareID], CONVERT(Date,medicare_effdt) as [EffStart],	CONVERT(Date,medicare_termdt) as [EffEnd], Plan_stratid [PlanStratID], benefit_code as [BenefitCode],waiver_toa as [TOAWaiver]
FROM [dbo].[Driscoll_EligibilityAdditionalInfo] 
WHERE ICENUMBER = @ICENUMBER 

END 