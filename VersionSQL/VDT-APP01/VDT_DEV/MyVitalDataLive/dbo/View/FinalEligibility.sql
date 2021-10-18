/****** Object:  View [dbo].[FinalEligibility]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE view [dbo].[FinalEligibility] as

select
	fe.RecordID
	, fe.MVDID
	, fe.MemberID
	, fe.LOB
	, fe.BabyID
	, fe.MomID
	, fe.MemberFirstName
	, fe.MemberLastName
	, fe.MemberMiddleName
	, fe.MemberEffectiveDate
	, fe.MemberTerminationDate
	, fe.HealthPlanEmployeeFlag
	, fe.CurrentCoPaylevel
	, fe.PCPNPI
	, fe.CategoryCode
	, fe.CountyName
	, fe.RiskGroupId
	, fe.PayorTypeId
	, fe.BenefitGroup
	, fe.PlanGroup
	, fe.PlanIdentifier
	, fe.PlanMetalLevel
	, fe.PlanPremiumAmount
	, fe.EnrollMaintainTypeCode
	, fe.RateAreaIdentifier
	, fe.Product
	, fe.EligibleMedicalBenefit
	, fe.EligibleRxBenefit
	, fe.EligibleVisionBenefit
	, fe.GestationAge
	, fe.Birthweight
	, fe.PreviousPlan
	, fe.DisenrollmentReason
	, fe.SDA
	, fe.Perinate
	, fe.Pregnant
	, fe.CustID
	, fe.BaseBatchID
	, fe.CurrentBatchID
	, fe.EligibleDentalBenefit
	, fe.PartyKey
	, fe.CompanyKey
	, fe.SubgroupKey
	, fe.MemberKey
	, fe.PersonalHarm
	, fe.FakeSpanInd
	, fe.SpanVoidInd
	, fe.BrandingName
	, fe.CmOrgRegion
	, fe.DataSource
	, fe.LoadDate
	, fe.ClientLoadDT
	, fe.RiderKey
	, fe.GrpInitvCd
from FinalEligibilityETL fe

union

select
	fe.RecordID
	, fe.MVDID
	, fe.MemberID
	, fe.LOB
	, fe.BabyID
	, fe.MomID
	, fe.MemberFirstName
	, fe.MemberLastName
	, fe.MemberMiddleName
	, fe.MemberEffectiveDate
	, fe.MemberTerminationDate
	, fe.HealthPlanEmployeeFlag
	, fe.CurrentCoPaylevel
	, fe.PCPNPI
	, fe.CategoryCode
	, fe.CountyName
	, fe.RiskGroupId
	, fe.PayorTypeId
	, fe.BenefitGroup
	, fe.PlanGroup
	, fe.PlanIdentifier
	, fe.PlanMetalLevel
	, fe.PlanPremiumAmount
	, fe.EnrollMaintainTypeCode
	, fe.RateAreaIdentifier
	, fe.Product
	, fe.EligibleMedicalBenefit
	, fe.EligibleRxBenefit
	, fe.EligibleVisionBenefit
	, fe.GestationAge
	, fe.Birthweight
	, fe.PreviousPlan
	, fe.DisenrollmentReason
	, fe.SDA
	, fe.Perinate
	, fe.Pregnant
	, fe.CustID
	, fe.BaseBatchID
	, fe.CurrentBatchID
	, fe.EligibleDentalBenefit
	, fe.PartyKey
	, fe.CompanyKey
	, fe.SubgroupKey
	, fe.MemberKey
	, NULL as PersonalHarm -- added as NULL as there is no column in FinalEligibilityTemporary table.
	, NULL as FakeSpanInd -- added as NULL as there is no column in FinalEligibilityTemporary table.
	, NULL as SpanVoidInd -- added as NULL as there is no column in FinalEligibilityTemporary table.
	, NULL as BrandingName -- added as NULL as there is no column in FinalEligibilityTemporary table.
	, NULL as CmOrgRegion -- added as NULL as there is no column in FinalEligibilityTemporary table.
	, NULL as DataSource -- added as NULL as there is no column in FinalEligibilityTemporary table.
	, NULL as LoadDate -- added as NULL as there is no column in FinalEligibilityTemporary table.
	, NULL as ClientLoadDT -- added as NULL as there is no column in FinalEligibilityTemporary table.
	, NULL as RiderKey -- added as NULL as there is no column in FinalEligibilityTemporary table.
	, NULL as GrpInitvCd -- added as NULL as there is no column in FinalEligibilityTemporary table.
FROM FinalEligibilityTemporary fe