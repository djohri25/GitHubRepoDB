/****** Object:  View [dbo].[FinalMember]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE view [dbo].[FinalMember] as
select
	fm.RecordID
	, fm.MVDID
	, fm.MemberID
	, fm.MemberFirstName
	, fm.MemberLastName
	, fm.MemberMiddleName
	, fm.Gender
	, fm.DateOfBirth
	, fm.SSN
	, fm.Relationship
	, fm.SubscriberID
	, fm.Address1
	, fm.Address2
	, fm.City
	, fm.State
	, fm.Zipcode
	, fm.Race
	, fm.Ethnicity
	, fm.CurrentCoPayLevel
	, fm.Suffix
	, fm.HomePhone
	, fm.WorkPhone
	, fm.Fax
	, fm.Email
	, fm.Language
	, fm.SpokenLanguage
	, fm.WrittenLanguage
	, fm.OtherLanguage
	, fm.DentalBenefit
	, fm.DrugBenefit
	, fm.MentalHealthBenefitInpatient
	, fm.MentalHealthBenefitIntensiveOutpatient
	, fm.MentalHealthBenefitOutpatientED
	, fm.ChemicalDependencyBenefitInpatient
	, fm.ChemicalDependencyBenefitIntensiveOutpatient
	, fm.ChemicalDependencyBenefitOutpatientED
	, fm.HospiceBenefit
	, fm.HealthPlanEmployeeFlag
	, fm.MaritalStatus
	, fm.HeightInches
	, fm.WeightLbs
	, fm.CustID
	, fm.BaseBatchID
	, fm.CurrentBatchID
	, fm.MemberKey
	, fm.CompanyKey
	, fm.PartyKey
	, fm.SubgroupKey
	, fm.PlanGroup
	, fm.BrandingName
	, fm.CmOrgRegion
	, fm.LOB
	, fm.countyname
	, fm.RiskGroupID
	, fm.PersonalHarm
	, fm.datasource
	, fm.LoadDate
	, fm.ClientLoadDT
	, fm.GrpInitvCd
	, fm.DentalCM
	, fm.NewDirSvcCd
	, fm.COBCD
	, fm.SRCOICID
	, fm.Custom1 as EmpLocCd
	, fm.Custom2 as ValBasedProg
from FinalMemberETL fm

union

select fm.RecordID
	, fm.MVDID
	, fm.MemberID
	, fm.MemberFirstName
	, fm.MemberLastName
	, fm.MemberMiddleName
	, fm.Gender
	, fm.DateOfBirth
	, fm.SSN
	, fm.Relationship
	, fm.SubscriberID
	, fm.Address1
	, fm.Address2
	, fm.City
	, fm.State
	, fm.Zipcode
	, fm.Race
	, fm.Ethnicity
	, fm.CurrentCoPayLevel
	, fm.Suffix
	, fm.HomePhone
	, fm.WorkPhone
	, fm.Fax
	, fm.Email
	, fm.Language
	, fm.SpokenLanguage
	, fm.WrittenLanguage
	, fm.OtherLanguage
	, fm.DentalBenefit
	, fm.DrugBenefit
	, fm.MentalHealthBenefitInpatient
	, fm.MentalHealthBenefitIntensiveOutpatient
	, fm.MentalHealthBenefitOutpatientED
	, fm.ChemicalDependencyBenefitInpatient
	, fm.ChemicalDependencyBenefitIntensiveOutpatient
	, fm.ChemicalDependencyBenefitOutpatientED
	, fm.HospiceBenefit
	, fm.HealthPlanEmployeeFlag
	, fm.MaritalStatus
	, fm.HeightInches
	, fm.WeightLbs
	, fm.CustID
	, fm.BaseBatchID
	, fm.CurrentBatchID
	, fm.MemberKey
	, fm.CompanyKey
	, fm.PartyKey
	, fm.SubgroupKey
	, fm.PlanGroup
	, fm.BrandingName
	, fm.CmOrgRegion
	, fm.LOB -- added as NULL as there is no column in FinalMemberTemporary table.
	, NULL as countyname -- added as NULL as there is no column in FinalMemberTemporary table.
	, NULL as RiskGroupID -- added as NULL as there is no column in FinalMemberTemporary table.
	, NULL as PersonalHarm -- added as NULL as there is no column in FinalMemberTemporary table.
	, NULL as datasource -- added as NULL as there is no column in FinalMemberTemporary table.
	, NULL as LoadDate -- added as NULL as there is no column in FinalMemberTemporary table.
	, NULL as ClientLoadDT -- added as NULL as there is no column in FinalMemberTemporary table.
	, NULL as GrpInitvCd -- added as NULL as there is no column in FinalMemberTemporary table.
	, NULL as DentalCM -- added as NULL as there is no column in FinalMemberTemporary table.
	, NULL as NewDirSvcCd -- added as NULL as there is no column in FinalMemberTemporary table.
	, NULL as COBCD
	, NULL as SRCOICID
	, NULL as EmpLocCd
	, NULL as ValBasedProg
from FinalMemberTemporary fm