/****** Object:  View [dbo].[vwCurrentEligibility]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE VIEW dbo.vwCurrentEligibility
AS
SELECT        RecordID, MVDID, MemberID, LOB, BabyID, MomID, MemberFirstName, MemberLastName, MemberMiddleName, MemberEffectiveDate, MemberTerminationDate, HealthPlanEmployeeFlag, CurrentCoPaylevel, 
                         PCPNPI, CategoryCode, CountyName, RiskGroupId, PayorTypeId, BenefitGroup, PlanGroup, PlanIdentifier, PlanMetalLevel, PlanPremiumAmount, EnrollMaintainTypeCode, RateAreaIdentifier, Product, 
                         EligibleMedicalBenefit, EligibleRxBenefit, EligibleVisionBenefit, GestationAge, Birthweight, PreviousPlan, DisenrollmentReason, SDA, Perinate, Pregnant, CustID, BaseBatchID, CurrentBatchID, 
                         EligibleDentalBenefit, PartyKey, CompanyKey, SubgroupKey, MemberKey
FROM            dbo.FinalEligibility
WHERE        (MemberTerminationDate >= GETDATE())