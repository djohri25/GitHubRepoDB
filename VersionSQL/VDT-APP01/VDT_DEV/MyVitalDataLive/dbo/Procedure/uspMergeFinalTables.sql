/****** Object:  Procedure [dbo].[uspMergeFinalTables]    Committed by VersionSQL https://www.versionsql.com ******/

/*=====================================================================================================
-- Author:		
-- Create date: 
-- MODIFIED: 
-- Description:	Merges data between two servers(APP - RPT)
 ===========================================================================================================*/

CREATE PROCEDURE [dbo].[uspMergeFinalTables] 

AS 
BEGIN

SET NOCOUNT ON;
SET XACT_ABORT ON

--Declare 
--	  @SourceCount int =0
--	, @TargetCount int=0
--	, @InsertCount int
--	, @UpdateCount int
--	, @ProcessedNotes VARCHAR(255)
--	, @SourceFile VARCHAR(255)
--	, @dbname varchar(100)
--	, @ClientName varchar(100)='ABCBS'
--	, @IndexName varchar(1000)
--	, @ColumnNames varchar(1000)
--	, @MySQL varchar(max)


--IF (@filetype = 'Member') 


BEGIN



	BEGIN TRANSACTION MEMBER

		MERGE  [MyVitalDataUAT].dbo.[FinalMemberETL] AS TARGET
		USING 
		 ( SELECT [RecordID]
				,[MVDID]
				,[MemberID]
				,[MemberFirstName]
				,[MemberLastName]
				,[MemberMiddleName]
				,[Gender]
				,[DateOfBirth]
				,[SSN]
				,[Relationship]
				,[SubscriberID]
				,[Address1]
				,[Address2]
				,[City]
				,[State]
				,[Zipcode]
				,[Race]
				,[Ethnicity]
				,[CurrentCoPayLevel]
				,[Suffix]
				,[HomePhone]
				,[WorkPhone]
				,[Fax]
				,[Email]
				,[Language]
				,[SpokenLanguage]
				,[WrittenLanguage]
				,[OtherLanguage]
				,[DentalBenefit]
				,[DrugBenefit]
				,[MentalHealthBenefitInpatient]
				,[MentalHealthBenefitIntensiveOutpatient]
				,[MentalHealthBenefitOutpatientED]
				,[ChemicalDependencyBenefitInpatient]
				,[ChemicalDependencyBenefitIntensiveOutpatient]
				,[ChemicalDependencyBenefitOutpatientED]
				,[HospiceBenefit]
				,[HealthPlanEmployeeFlag]
				,[MaritalStatus]
				,[HeightInches]
				,[WeightLbs]
				,[CustID]
				,[BaseBatchID]
				,[CurrentBatchID]
				,[MemberKey]
				,[CompanyKey]
				,[PartyKey]
				,[SubgroupKey]
				,[PlanGroup]
				,[BrandingName]
				,[CmOrgRegion]
				,[countyname]
				,[RiskGroupID]
				,[LOB]
				,PersonalHarm
				,DataSource
				,LoadDate
				,ClientLoadDT
			  FROM [VD-RPT02].[BatchImportABCBS].[dbo].[FinalMember] 
		) AS SOURCE 
	
		ON (
				 TARGET.MemberID=SOURCE.MemberID	 		
			) 
	   
WHEN MATCHED 		
THEN 
UPDATE SET 
        TARGET.[MVDID]=SOURCE.[MVDID]
	  , TARGET.[MemberFirstName]= SOURCE.[MemberFirstName]
      , TARGET.[MemberLastName]= SOURCE.[MemberLastName]
      , TARGET.[MemberMiddleName]= SOURCE.[MemberMiddleName]
      , TARGET.[Gender]= SOURCE.[Gender]
      , TARGET.[DateOfBirth]= SOURCE.[DateOfBirth]
      , TARGET.[SSN]= SOURCE.[SSN]
      , TARGET.[Relationship]= SOURCE.[Relationship]
      , TARGET.[SubscriberID]= SOURCE.[SubscriberID]
      , TARGET.[Address1]= SOURCE.[Address1]
      , TARGET.[Address2]= SOURCE.[Address2]
      , TARGET.[City]= SOURCE.[City]
      , TARGET.[State]= SOURCE.[State]
      , TARGET.[Zipcode]= SOURCE.[Zipcode]
      , TARGET.[Race]= SOURCE.[Race]
      , TARGET.[Ethnicity]= SOURCE.[Ethnicity]
      , TARGET.[CurrentCoPayLevel]= SOURCE.[CurrentCoPayLevel]
      , TARGET.[Suffix]= SOURCE.[Suffix]
      , TARGET.[HomePhone]= SOURCE.[HomePhone]
      , TARGET.[WorkPhone]= SOURCE.[WorkPhone]
      , TARGET.[Fax]= SOURCE.[Fax]
      , TARGET.[Email]= SOURCE.[Email]
      , TARGET.[Language]= SOURCE.[Language]
      , TARGET.[SpokenLanguage]= SOURCE.[SpokenLanguage]
      , TARGET.[WrittenLanguage]= SOURCE.[WrittenLanguage]
      , TARGET.[OtherLanguage]= SOURCE.[OtherLanguage]
      , TARGET.[DentalBenefit]= SOURCE.[DentalBenefit]
      , TARGET.[DrugBenefit]= SOURCE.[DrugBenefit]
      , TARGET.[MentalHealthBenefitInpatient]= SOURCE.[MentalHealthBenefitInpatient]
      , TARGET.[MentalHealthBenefitIntensiveOutpatient]= SOURCE.[MentalHealthBenefitIntensiveOutpatient]
      , TARGET.[MentalHealthBenefitOutpatientED]= SOURCE.[MentalHealthBenefitOutpatientED]
      , TARGET.[ChemicalDependencyBenefitInpatient]= SOURCE.[ChemicalDependencyBenefitInpatient]
      , TARGET.[ChemicalDependencyBenefitIntensiveOutpatient]= SOURCE.[ChemicalDependencyBenefitIntensiveOutpatient]
      , TARGET.[ChemicalDependencyBenefitOutpatientED]= SOURCE.[ChemicalDependencyBenefitOutpatientED]
      , TARGET.[HospiceBenefit]= SOURCE.[HospiceBenefit]
      , TARGET.[HealthPlanEmployeeFlag]= SOURCE.[HealthPlanEmployeeFlag]
      , TARGET.[MaritalStatus]= SOURCE.[MaritalStatus]
      , TARGET.[HeightInches]= SOURCE.[HeightInches]
      , TARGET.[WeightLbs]= SOURCE.[WeightLbs]
	  , TARGET.[CustID]= SOURCE.[CustID]
	  , TARGET.[BaseBatchID]= SOURCE.[BaseBatchID]
	  , TARGET.[CurrentBatchID]= SOURCE.[CurrentBatchID]
	  , TARGET.[Plangroup]= SOURCE.[Plangroup]
	  , TARGET.[Subgroupkey]=SOURCE.[Subgroupkey]
	  , TARGET.[CompanyKey]	= SOURCE.[CompanyKey]
	  , TARGET.Memberkey=SOURCE.Memberkey
	  , TARGET.Partykey=SOURCE.Partykey
	  , TARGET.[CmOrgRegion]	= SOURCE.[CmOrgRegion]
	  , TARGET.[BrandingName]	= SOURCE.[BrandingName]
	  , TARGET.[countyname]	= SOURCE.[countyname]
	  , TARGET.RiskGroupID	= SOURCE.RiskGroupID
	  , TARGET.[LOB]	= SOURCE.[LOB]
	  , TARGET.PersonalHarm=SOURCE.PersonalHarm
	  , TARGET.Datasource=SOURCE.Datasource
	  , TARGET.LoadDate=SOURCE.LoadDate
	  , TARGET.ClientLoadDT=SOURCE.ClientLoadDT

WHEN NOT MATCHED BY TARGET THEN 
INSERT    (		 [RecordID]
                ,[MVDID]
				,[MemberID]
				,[MemberFirstName]
				,[MemberLastName]
				,[MemberMiddleName]
				,[Gender]
				,[DateOfBirth]
				,[SSN]
				,[Relationship]
				,[SubscriberID]
				,[Address1]
				,[Address2]
				,[City]
				,[State]
				,[Zipcode]
				,[Race]
				,[Ethnicity]
				,[CurrentCoPayLevel]
				,[Suffix]
				,[HomePhone]
				,[WorkPhone]
				,[Fax]
				,[Email]
				,[Language]
				,[SpokenLanguage]
				,[WrittenLanguage]
				,[OtherLanguage]
				,[DentalBenefit]
				,[DrugBenefit]
				,[MentalHealthBenefitInpatient]
				,[MentalHealthBenefitIntensiveOutpatient]
				,[MentalHealthBenefitOutpatientED]
				,[ChemicalDependencyBenefitInpatient]
				,[ChemicalDependencyBenefitIntensiveOutpatient]
				,[ChemicalDependencyBenefitOutpatientED]
				,[HospiceBenefit]
				,[HealthPlanEmployeeFlag]
				,[MaritalStatus]
				,[HeightInches]
				,[WeightLbs]
				,[CustID]
				,[BaseBatchID]
				,[CurrentBatchID]
				,[MemberKey]
				,[CompanyKey]
				,[PartyKey]
				,[SubgroupKey]
				,[PlanGroup]
				,[BrandingName]
				,[CmOrgRegion]
				,[countyname]
				,[RiskGroupID]
				,[LOB]
				,PersonalHarm
				,DataSource
				,LoadDate
				,ClientLoadDT
		  )

     VALUES
          ( SOURCE.[RecordID]
		   ,SOURCE.[MVDID]
           ,SOURCE.[MemberID]
           ,SOURCE.[MemberFirstName]
           ,SOURCE.[MemberLastName]
           ,SOURCE.[MemberMiddleName]
           ,SOURCE.[Gender]
           ,SOURCE.[DateOfBirth]
           ,SOURCE.[SSN]
           ,SOURCE.[Relationship]
           ,SOURCE.[SubscriberID]
           ,SOURCE.[Address1]
           ,SOURCE.[Address2]
           ,SOURCE.[City]
           ,SOURCE.[State]
           ,SOURCE.[Zipcode]
           ,SOURCE.[Race]
           ,SOURCE.[Ethnicity]
           ,SOURCE.[CurrentCoPayLevel]
           ,SOURCE.[Suffix]
           ,SOURCE.[HomePhone]
           ,SOURCE.[WorkPhone]
           ,SOURCE.[Fax]
           ,SOURCE.[Email]
           ,SOURCE.[Language]
           ,SOURCE.[SpokenLanguage]
           ,SOURCE.[WrittenLanguage]
           ,SOURCE.[OtherLanguage]
           ,SOURCE.[DentalBenefit]
           ,SOURCE.[DrugBenefit]
           ,SOURCE.[MentalHealthBenefitInpatient]
           ,SOURCE.[MentalHealthBenefitIntensiveOutpatient]
           ,SOURCE.[MentalHealthBenefitOutpatientED]
           ,SOURCE.[ChemicalDependencyBenefitInpatient]
           ,SOURCE.[ChemicalDependencyBenefitIntensiveOutpatient]
           ,SOURCE.[ChemicalDependencyBenefitOutpatientED]
           ,SOURCE.[HospiceBenefit]
           ,SOURCE.[HealthPlanEmployeeFlag]
           ,SOURCE.[MaritalStatus]
           ,SOURCE.[HeightInches]
           ,SOURCE.[WeightLbs]
           ,SOURCE.[CustID]
           ,SOURCE.[BaseBatchID]
		   ,SOURCE.[CurrentBatchID]
		   ,SOURCE.[MemberKey]
		   ,SOURCE.[CompanyKey]
		   ,SOURCE.[PartyKey]
		   ,SOURCE.[SubgroupKey]
		   ,SOURCE.[PlanGroup]
		   ,SOURCE.[BrandingName]
		   ,SOURCE.[CmOrgRegion]
		   ,SOURCE.[countyname]
		   ,SOURCE.[RiskGroupID]
		   ,SOURCE.lob
		   ,SOURCE.PersonalHarm
		   ,SOURCE.DataSource
		   ,SOURCE.LoadDate
		   ,SOURCE.ClientLoadDT				  
		   );

	IF @@ERROR > 0

	ROLLBACK TRANSACTION MEMBER
	ELSE 
	COMMIT TRANSACTION MEMBER

 
END


--if @filetype = 'Provider'

 BEGIN
 BEGIN TRANSACTION PROVIDER

 TRUNCATE TABLE [MyVitalDataUAT].[dbo].[FinalProvider]

 MERGE  [MyVitalDataUAT].[dbo].[FinalProvider] AS TARGET
 USING (

 SELECT [RecordID]
      ,[ProviderID]
      ,[ProviderFirstName]
      ,[ProviderLastName]
      ,[ServiceAddress1]
      ,[ServiceAddress2]
      ,[ServiceCity]
      ,[ServiceState]
      ,[ServiceZip]
      ,[ServicePhone]
      ,[ServiceFax]
      ,[ServiceStatus]
      ,[Gender]
      ,[LicenseNumber]
      ,[LicenseState]
      ,[LicenseExpDate]
      ,[ServiceLocationID]
      ,[BusinessName]
      ,[BusinessAddress1]
      ,[BusinessAddress2]
      ,[BusinessCity]
      ,[BusinessState]
      ,[BusinessZip]
      ,[TPI]
      ,[ProviderType]
      ,[TIN]
      ,[BusinessUnitID]
      ,[BusinessFax]
      ,[AffiliationID]
      ,[AffiliationSDA]
      ,[AffiliationEffectiveDate]
      ,[AffiliationTerminationDate]
      ,[ServiceEffectiveDate]
      ,[ServiceTerminationDate]
      ,[NPI]
      ,[AdditionalNPI]
      ,[Ethnicity]
      ,[Language1]
      ,[Language2]
      ,[Language3]
      ,[CountyName]
      ,[CountyCode]
      ,[InNetwork]
      ,[PCPIndicator]
      ,[Taxonomy1]
      ,[Taxonomy2]
      ,[Taxonomy3]
      ,[Taxonomy4]
      ,[Taxonomy5]
      ,[Taxonomy6]
      ,[Taxonomy7]
      ,[Taxonomy8]
      ,[Taxonomy9]
      ,[Taxonomy10]
      ,[CustID]
      ,[BaseBatchID]
      ,[CurrentBatchID]
      ,[LoadDate]
      ,[ProviderSpecialty]
      ,[ProviderTPI]
  FROM [VD-RPT02].BatchImportABCBS.[dbo].[FinalProvider] ) AS SOURCE
ON (
		TARGET.[ProviderID] = SOURCE.[ProviderID] 
			and TARGET.[NPI]=SOURCE.[NPI] 
			and TARGET.[TIN]=SOURCE.[TIN]
			and TARGET.[CurrentBatchID] = SOURCE.[CurrentBatchID]
	) 

--WHEN MATCHED 


--THEN 
--UPDATE SET 
--   TARGET.[ProviderFirstName]= SOURCE.ProviderFirstName
--      , TARGET.[ProviderLastName]= SOURCE.ProviderLastName
--      , TARGET.[ServiceAddress1]= SOURCE.ServiceAddress1
--      , TARGET.[ServiceAddress2]= SOURCE.ServiceAddress2
--      , TARGET.[ServiceCity]= SOURCE.ServiceCity
--      , TARGET.[ServiceState]= SOURCE.ServiceState
--      , TARGET.[ServiceZip]= SOURCE.ServiceZip
--      , TARGET.[ServicePhone]= SOURCE.ServicePhone
--      , TARGET.[ServiceFax]= SOURCE.ServiceFax
--      , TARGET.[ServiceStatus]= SOURCE.ServiceStatus
--      , TARGET.[Gender]= SOURCE.Gender
--      , TARGET.[LicenseNumber]= SOURCE.LicenseNumber
--      , TARGET.[LicenseState]= SOURCE.LicenseState
--      , TARGET.[LicenseExpDate]= SOURCE.LicenseExpDate
--      , TARGET.[ServiceLocationID]= SOURCE.ServiceLocationID
--      , TARGET.[BusinessName]= SOURCE.BusinessName
--      , TARGET.[BusinessAddress1]= SOURCE.BusinessAddress1
--      , TARGET.[BusinessAddress2]= SOURCE.BusinessAddress2
--      , TARGET.[BusinessCity]= SOURCE.BusinessCity
--      , TARGET.[BusinessState]= SOURCE.BusinessState
--      , TARGET.[BusinessZip]= SOURCE.BusinessZip
--      , TARGET.[TPI]= SOURCE.TPI
--      , TARGET.[ProviderType]= SOURCE.ProviderType
--      , TARGET.[TIN]= SOURCE.TIN
--      , TARGET.[BusinessUnitID]= SOURCE.BusinessUnitID
--      , TARGET.[BusinessFax]= SOURCE.BusinessFax
--      , TARGET.[AffiliationID]= SOURCE.AffiliationID
--      , TARGET.[AffiliationSDA]= SOURCE.AffiliationSDA
--      , TARGET.[AffiliationEffectiveDate]= SOURCE.AffiliationEffectiveDate
--      , TARGET.[AffiliationTerminationDate]= SOURCE.AffiliationTerminationDate
--      , TARGET.[ServiceEffectiveDate]= SOURCE.ServiceEffectiveDate
--      , TARGET.[ServiceTerminationDate]= SOURCE.ServiceTerminationDate
--      , TARGET.[AdditionalNPI]= SOURCE.AdditionalNPI
--      , TARGET.[Ethnicity]= SOURCE.Ethnicity
--      , TARGET.[Language1]= SOURCE.Language1
--      , TARGET.[Language2]= SOURCE.Language2
--      , TARGET.[Language3]= SOURCE.Language3
--      , TARGET.[CountyName]= SOURCE.CountyName
--      , TARGET.[CountyCode]= SOURCE.CountyCode
--      , TARGET.[InNetwork]= SOURCE.InNetwork
--      , TARGET.[PCPIndicator]= SOURCE.PCPIndicator
--      , TARGET.[Taxonomy1]= SOURCE.Taxonomy1
--      , TARGET.[Taxonomy2]= SOURCE.Taxonomy2
--      , TARGET.[Taxonomy3]= SOURCE.Taxonomy3
--      , TARGET.[Taxonomy4]= SOURCE.Taxonomy4
--      , TARGET.[Taxonomy5]= SOURCE.Taxonomy5
--      , TARGET.[Taxonomy6]= SOURCE.Taxonomy6
--      , TARGET.[Taxonomy7]= SOURCE.Taxonomy7
--      , TARGET.[Taxonomy8]= SOURCE.Taxonomy8
--      , TARGET.[Taxonomy9]= SOURCE.Taxonomy9
--      , TARGET.[Taxonomy10]= SOURCE.Taxonomy10
--	  ,TARGET.[BaseBatchID] = SOURCE.[BaseBatchID]
--      ,TARGET.[CurrentBatchID] = SOURCE.[CurrentBatchID]
--      ,TARGET.[LoadDate] = SOURCE.[LoadDate]
--      ,TARGET.[ProviderSpecialty] = SOURCE.[ProviderSpecialty]
--      ,TARGET.[ProviderTPI] = SOURCE.[ProviderTPI]

WHEN NOT MATCHED BY TARGET THEN 
INSERT     ([ProviderID]
           ,[ProviderFirstName]
           ,[ProviderLastName]
           ,[ServiceAddress1]
           ,[ServiceAddress2]
           ,[ServiceCity]
           ,[ServiceState]
           ,[ServiceZip]
           ,[ServicePhone]
           ,[ServiceFax]
           ,[ServiceStatus]
           ,[Gender]
           ,[LicenseNumber]
           ,[LicenseState]
           ,[LicenseExpDate]
           ,[ServiceLocationID]
           ,[BusinessName]
           ,[BusinessAddress1]
           ,[BusinessAddress2]
           ,[BusinessCity]
           ,[BusinessState]
           ,[BusinessZip]
           ,[TPI]
           ,[ProviderType]
           ,[TIN]
           ,[BusinessUnitID]
           ,[BusinessFax]
           ,[AffiliationID]
           ,[AffiliationSDA]
           ,[AffiliationEffectiveDate]
           ,[AffiliationTerminationDate]
           ,[ServiceEffectiveDate]
           ,[ServiceTerminationDate]
           ,[NPI]
           ,[AdditionalNPI]
           ,[Ethnicity]
           ,[Language1]
           ,[Language2]
           ,[Language3]
           ,[CountyName]
           ,[CountyCode]
           ,[InNetwork]
           ,[PCPIndicator]
           ,[Taxonomy1]
           ,[Taxonomy2]
           ,[Taxonomy3]
           ,[Taxonomy4]
           ,[Taxonomy5]
           ,[Taxonomy6]
           ,[Taxonomy7]
           ,[Taxonomy8]
           ,[Taxonomy9]
           ,[Taxonomy10]
           ,[CustID]
           ,[BaseBatchID]
           ,[CurrentBatchID]
		   ,[LoadDate]
		   ,[ProviderSpecialty]
		   ,[ProviderTPI])
     VALUES           
	 	   (Source.[ProviderID]
           ,Source.[ProviderFirstName]
           ,Source.[ProviderLastName]
           ,Source.[ServiceAddress1]
           ,Source.[ServiceAddress2]
           ,Source.[ServiceCity]
           ,Source.[ServiceState]
           ,Source.[ServiceZip]
           ,Source.[ServicePhone]
           ,Source.[ServiceFax]
           ,Source.[ServiceStatus]
           ,Source.[Gender]
           ,Source.[LicenseNumber]
           ,Source.[LicenseState]
           ,Source.[LicenseExpDate]
           ,Source.[ServiceLocationID]
           ,Source.[BusinessName]
           ,Source.[BusinessAddress1]
           ,Source.[BusinessAddress2]
           ,Source.[BusinessCity]
           ,Source.[BusinessState]
           ,Source.[BusinessZip]
           ,Source.[TPI]
           ,Source.[ProviderType]
           ,Source.[TIN]
           ,Source.[BusinessUnitID]
           ,Source.[BusinessFax]
           ,Source.[AffiliationID]
           ,Source.[AffiliationSDA]
           ,Source.[AffiliationEffectiveDate]
           ,Source.[AffiliationTerminationDate]
           ,Source.[ServiceEffectiveDate]
           ,Source.[ServiceTerminationDate]
           ,Source.[NPI]
           ,Source.[AdditionalNPI]
           ,Source.[Ethnicity]
           ,Source.[Language1]
           ,Source.[Language2]
           ,Source.[Language3]
           ,Source.[CountyName]
           ,Source.[CountyCode]
           ,Source.[InNetwork]
           ,Source.[PCPIndicator]
           ,Source.[Taxonomy1]
           ,Source.[Taxonomy2]
           ,Source.[Taxonomy3]
           ,Source.[Taxonomy4]
           ,Source.[Taxonomy5]
           ,Source.[Taxonomy6]
           ,Source.[Taxonomy7]
           ,Source.[Taxonomy8]
           ,Source.[Taxonomy9]
           ,Source.[Taxonomy10]
           ,Source.[CustID]
           ,Source.[BaseBatchID]
           ,Source.[CurrentBatchID]
		   ,SOURCE.[LoadDate]
           ,SOURCE.[ProviderSpecialty]
           ,SOURCE.[ProviderTPI]);


if @@ERROR>0 Rollback transaction Provider
ELSE
Commit transaction Provider
 
End


--IF (@filetype = 'Eligibility')

BEGIN
	BEGIN TRANSACTION Eligibility
	
	DELETE FROM MyVitalDataUAT.dbo.FinalEligibilityETL
	where MemberKey IN (Select MemberKey from [VD-RPT02].[BatchImportABCBS].[dbo].[FinalEligibility] where CurrentBatchID IN
	(SELECT max(CurrentBatchID) from [VD-RPT02].[BatchImportABCBS].[dbo].[FinalEligibility]))
	    
	MERGE  MyVitalDataUAT.dbo.FinalEligibilityETL AS TARGET
	USING 
	(

		SELECT [RecordID]
				,[MVDID]
				,[MemberID]
				,[LOB]
				,[BabyID]
				,[MomID]
				,[MemberFirstName]
				,[MemberLastName]
				,[MemberMiddleName]
				,[MemberEffectiveDate]
				,[MemberTerminationDate]
				,[HealthPlanEmployeeFlag]
				,[CurrentCoPaylevel]
				,[PCPNPI]
				,[CategoryCode]
				,[CountyName]
				,[RiskGroupId]
				,[PayorTypeId]
				,[BenefitGroup]
				,[PlanGroup]
				,[PlanIdentifier]
				,[PlanMetalLevel]
				,[PlanPremiumAmount]
				,[EnrollMaintainTypeCode]
				,[RateAreaIdentifier]
				,[Product]
				,[EligibleMedicalBenefit]
				,[EligibleRxBenefit]
				,[EligibleVisionBenefit]
				,[EligibleDentalBenefit]
				,[GestationAge]
				,[Birthweight]
				,[PreviousPlan]
				,[DisenrollmentReason]
				,[SDA]
				,[Perinate]
				,[Pregnant]
				,[CustID]
				,[BaseBatchID]
				,[CurrentBatchID]
				,[PartyKey]
				,[MemberKey]
				,[CompanyKey]
				,[SubgroupKey]
				,[PersonalHarm]
				,[FakeSpanInd]
				,[SpanVoidInd]
				,[BrandingName]
				,[CmOrgRegion]
				,[DataSource]
				,[LoadDate]
				,[ClientLoadDT]
				,[RiderKey]
			FROM [VD-RPT02].[BatchImportABCBS].[dbo].[FinalEligibility]			
	) AS SOURCE 			
	ON (
			TARGET.[MemberKey]	= SOURCE.[MemberKey]	
		and TARGET.[MemberID] = SOURCE.[MemberID]	
		and TARGET.[MVDID] = SOURCE.[MVDID]
				  
		) 
			
			 	
				--WHEN MATCHED 	
				--THEN 
				--UPDATE SET 
						
   	--				    TARGET.MVDID=SOURCE.MVDID
				--	  , TARGET.[MemberID]	= SOURCE.[MemberID]
				--	  , TARGET.[LOB] = SOURCE.LOB 
				--	  , TARGET.[BabyID] = SOURCE.BabyID
				--	  , TARGET.[MomID] = SOURCE.MomID
				--	  , TARGET.[MemberFirstName] = SOURCE.MemberFirstName
				--	  , TARGET.[MemberLastName] = SOURCE.MemberLastName
				--	  , TARGET.[MemberMiddleName] = SOURCE.MemberMiddleName
				--	  , TARGET.[MemberEffectiveDate]=SOURCE.[MemberEffectiveDate] 
				--	  , TARGET.[MemberTerminationDate] = SOURCE.MemberTerminationDate
				--	  , TARGET.[HealthPlanEmployeeFlag] = SOURCE.HealthPlanEmployeeFlag
				--	  , TARGET.[CurrentCoPaylevel] = SOURCE.CurrentCoPaylevel
				--	  , TARGET.[PCPNPI] = SOURCE.PCPNPI
				--	  , TARGET.[CategoryCode] = SOURCE.CategoryCode
				--	  , TARGET.[CountyName] = SOURCE.CountyName
				--	  , TARGET.[RiskGroupId] = SOURCE.RiskGroupId
				--	  , TARGET.[PayorTypeId] = SOURCE.PayorTypeId
				--	  , TARGET.[BenefitGroup] = SOURCE.BenefitGroup
				--	  , TARGET.[PlanGroup] = SOURCE.PlanGroup
				--	  , TARGET.[PlanIdentifier] = SOURCE.PlanIdentifier
				--	  , TARGET.[PlanMetalLevel] = SOURCE.PlanMetalLevel
				--	  , TARGET.[PlanPremiumAmount] = SOURCE.PlanPremiumAmount
				--	  , TARGET.[EnrollMaintainTypeCode] = SOURCE.EnrollMaintainTypeCode
				--	  , TARGET.[RateAreaIdentifier] = SOURCE.RateAreaIdentifier
				--	  , TARGET.[Product] = SOURCE.Product
				--	  , TARGET.[EligibleMedicalBenefit] = SOURCE.EligibleMedicalBenefit
				--	  , TARGET.[EligibleRxBenefit] = SOURCE.EligibleRxBenefit
				--	  , TARGET.[EligibleVisionBenefit] = SOURCE.EligibleVisionBenefit
				--	  , TARGET.[EligibleDentalBenefit] = SOURCE.[EligibleDentalBenefit]
				--	  , TARGET.[GestationAge] = SOURCE.GestationAge
				--	  , TARGET.[Birthweight] = SOURCE.Birthweight
				--	  , TARGET.[PreviousPlan] = SOURCE.PreviousPlan
				--	  , TARGET.[DisenrollmentReason] = SOURCE.DisenrollmentReason
				--	  , TARGET.[SDA] = SOURCE.SDA
				--	  , TARGET.[Perinate] = SOURCE.Perinate
				--	  , TARGET.[Pregnant] = SOURCE.Pregnant
				--	  , TARGET.[CurrentBatchID]= SOURCE.[CurrentBatchID]
				--	  , TARGET.[PartyKey]	= SOURCE.[PartyKey]
				--	  , TARGET.[MemberKey]	= SOURCE.[MemberKey]
				--	  , TARGET.[CompanyKey]	= SOURCE.[CompanyKey]
				--	  , TARGET.[SubgroupKey] = SOURCE.[SubgroupKey]
				--	  , TARGET.[PersonalHarm]= SOURCE.[PersonalHarm]
				--	  , TARGET.[FakeSpanInd]= SOURCE.[FakeSpanInd]
				--	  , TARGET.[SpanVoidInd]= SOURCE.[SpanVoidInd]
				--	  , TARGET.[BrandingName]= SOURCE.[BrandingName]
				--	  , TARGET.[CmOrgRegion]= SOURCE.[CmOrgRegion]
				--	  , TARGET.[DataSource]= SOURCE.[DataSource]
				--	  , TARGET.[LoadDate]= SOURCE.[LoadDate]
				--	  , TARGET.[ClientLoadDT]= SOURCE.[ClientLoadDT]
				--	  , TARGET.[RiderKey]= SOURCE.[RiderKey]

				WHEN NOT MATCHED BY TARGET THEN 
					INSERT
					 (	   [MVDID]
						  ,[MemberID]
						  ,[LOB]
						  ,[BabyID]
						  ,[MomID]
						  ,[MemberFirstName]
						  ,[MemberLastName]
						  ,[MemberMiddleName]
						  ,[MemberEffectiveDate]
						  ,[MemberTerminationDate]
						  ,[HealthPlanEmployeeFlag]
						  ,[CurrentCoPaylevel]
						  ,[PCPNPI]
						  ,[CategoryCode]
						  ,[CountyName]
						  ,[RiskGroupId]
						  ,[PayorTypeId]
						  ,[BenefitGroup]
						  ,[PlanGroup]
						  ,[PlanIdentifier]
						  ,[PlanMetalLevel]
						  ,[PlanPremiumAmount]
						  ,[EnrollMaintainTypeCode]
						  ,[RateAreaIdentifier]
						  ,[Product]
						  ,[EligibleMedicalBenefit]
						  ,[EligibleRxBenefit]
						  ,[EligibleVisionBenefit]
						  ,[EligibleDentalBenefit]
						  ,[GestationAge]
						  ,[Birthweight]
						  ,[PreviousPlan]
						  ,[DisenrollmentReason]
						  ,[SDA]
						  ,[Perinate]
						  ,[Pregnant]
						  ,[CustID]
						  ,[BaseBatchID]
						  ,[CurrentBatchID]
						  ,[PartyKey]
						  ,[MemberKey]
						  ,[CompanyKey]
						  ,[SubgroupKey]
						  ,[PersonalHarm]
						  ,[FakeSpanInd]
						  ,[SpanVoidInd]
						  ,[BrandingName]
						  ,[CmOrgRegion]
						  ,[DataSource]
						  ,[LoadDate]
						  ,[ClientLoadDT]
						  ,[RiderKey]
						  )
					 VALUES           
						 ( Source.[MVDID]
						  ,Source.[MemberID]
						  ,Source.[LOB]
						  ,Source.[BabyID]
						  ,Source.[MomID]
						  ,Source.[MemberFirstName]
						  ,Source.[MemberLastName]
						  ,Source.[MemberMiddleName]
						  ,Source.[MemberEffectiveDate]
						  ,Source.[MemberTerminationDate]
						  ,Source.[HealthPlanEmployeeFlag]
						  ,Source.[CurrentCoPaylevel]
						  ,Source.[PCPNPI]
						  ,Source.[CategoryCode]
						  ,Source.[CountyName]
						  ,Source.[RiskGroupId]
						  ,Source.[PayorTypeId]
						  ,Source.[BenefitGroup]
						  ,Source.[PlanGroup]
						  ,Source.[PlanIdentifier]
						  ,Source.[PlanMetalLevel]
						  ,Source.[PlanPremiumAmount]
						  ,Source.[EnrollMaintainTypeCode]
						  ,Source.[RateAreaIdentifier]
						  ,Source.[Product]
						  ,Source.[EligibleMedicalBenefit]
						  ,Source.[EligibleRxBenefit]
						  ,Source.[EligibleVisionBenefit]
						  ,Source.[EligibleDentalBenefit]
						  ,Source.[GestationAge]
						  ,Source.[Birthweight]
						  ,Source.[PreviousPlan]
						  ,Source.[DisenrollmentReason]
						  ,Source.[SDA]
						  ,Source.[Perinate]
						  ,Source.[Pregnant]
						  ,Source.[CustID]
						  ,Source.[BaseBatchID]
						  ,Source.[CurrentBatchID]
						  ,source.[PartyKey]
						  ,source.[MemberKey]
						  ,source.[CompanyKey]
						  ,source.[SubgroupKey]
						  ,source.[PersonalHarm]
						  ,source.[FakeSpanInd]
						  ,source.[SpanVoidInd]
						  ,source.[BrandingName]
						  ,source.[CmOrgRegion]
						  ,source.[DataSource]
						  ,source.[LoadDate]
						  ,source.[ClientLoadDT]
						  ,source.[RiderKey]
					 );


   if @@ERROR>0 
	Rollback transaction Eligibility
    ELSE
	COMMIT TRANSACTION Eligibility

END


--IF (@filetype = 'RX')

BEGIN
BEGIN TRANSACTION RX

DELETE FROM MyVitalDataUAT.dbo.FinalRX
	where claimkey IN (Select claimkey from [VD-RPT02].[BatchImportABCBS].[dbo].[FinalRX] where CurrentBatchID IN
	(SELECT max(CurrentBatchID) from [VD-RPT02].[BatchImportABCBS].[dbo].[FinalRX]))

 MERGE  MyVitalDataUAT.dbo.FinalRX AS TARGET
	USING
	 (
		SELECT [RecordID]
			  ,[MVDID]
			  ,[ClaimNumber]
			  ,[ClaimStatus]
			  ,[PaidClaimAuthNum]
			  ,[MemberID]
			  ,[MemberLastName]
			  ,[MemberFirstName]
			  ,[MemberMiddleName]
			  ,[Gender]
			  ,[DateOfBirth]
			  ,[ZipCode]
			  ,[SSN]
			  ,[SubscriberID]
			  ,[ClaimProcessingDate]
			  ,[ServiceDate]
			  ,[RefillCode]
			  ,[CompoundCode]
			  ,[ProductServiceQualifier]
			  ,[NDCCode]
			  ,[MetricDecimalQuantity]
			  ,[DaysSupply]
			  ,[DispenseAsWritten]
			  ,[WrittenDate]
			  ,[RefillsAuthorizedCount]
			  ,[DrugProductName]
			  ,[DrugProductDesc]
			  ,[DrugTier]
			  ,[GenericProductID]
			  ,[GenericProductName]
			  ,[AHFSCode]
			  ,[DrugDEAClassCode]
			  ,[RXOTCCode]
			  ,[MultiSourceIndicator]
			  ,[DrugStrength]
			  ,[DrugStrengthUnitOfMeasure]
			  ,[SubmittingPharmacyID]
			  ,[PharmIDQualifier]
			  ,[PharmacyName]
			  ,[PharmacyStoreNum]
			  ,[PrescriberID]
			  ,[PrescriberIDQualifier]
			  ,[PrescriberName]
			  ,[RejectCode1Description]
			  ,[DiagnosisCode]
			  ,[DiagnosisCodeQualifier]
			  ,[DrugConflictCode1]
			  ,[RXReferenceNumber]
			  ,[BilledAmount]
			  ,[CoveredAmount]
			  ,[PaidAmount]
			  ,ClaimLinenumber   
			  ,[CustID]
			  ,[BaseBatchID]
			  ,[CurrentBatchID]
			  ,[PartyKey]
			  ,[MemberKey]
			  ,[CompanyKey]
			  ,[SubgroupKey]
			  ,[PlanGroup]
			  ,[LOB]
			  ,[claimkey]
			  ,[NdcPhiSensInd]
			  ,[DiagPhiSensInd]
			  ,[DataSource]
			  ,[LoadDate]
			  ,[ClientLoadDT]
	  FROM [VD-RPT02].[BatchImportABCBS].[dbo].[FinalRX] 
	  )	 AS SOURCE 
	ON (
			TARGET.[ClaimKey]=SOURCE.[ClaimKey]	
		) 
	--WHEN MATCHED 
	--THEN 
	--UPDATE SET 
 --  			TARGET.MVDID = SOURCE.MVDID
	--	  , TARGET.[ClaimNumber] = SOURCE.[ClaimNumber]
 --  		  , TARGET.[ClaimStatus] = SOURCE.[ClaimStatus]
	--	  , TARGET.[PaidClaimAuthNum] = SOURCE.PaidClaimAuthNum
	--	  , TARGET.[MemberID] = SOURCE.MemberID
	--	  , TARGET.[MemberLastName] = SOURCE.MemberLastName
	--	  , TARGET.[MemberFirstName] = SOURCE.MemberFirstName
	--	  , TARGET.[MemberMiddleName] = SOURCE.MemberMiddleName
	--	  , TARGET.[Gender] = SOURCE.Gender
	--	  , TARGET.[DateOfBirth] = SOURCE.DateOfBirth
	--	  , TARGET.[ZipCode] = SOURCE.ZipCode
	--	  , TARGET.[SSN] = SOURCE.SSN
	--	  , TARGET.[SubscriberID] = SOURCE.SubscriberID
	--	  , TARGET.[ClaimProcessingDate] = SOURCE.ClaimProcessingDate
	--	  , TARGET.[ServiceDate] = SOURCE.ServiceDate
	--	  , TARGET.[RefillCode] = SOURCE.RefillCode
	--	  , TARGET.[CompoundCode] = SOURCE.CompoundCode
	--	  , TARGET.[ProductServiceQualifier] = SOURCE.ProductServiceQualifier
	--	  , TARGET.[NDCCode] = SOURCE.NDCCode
	--	  , TARGET.[MetricDecimalQuantity] = SOURCE.MetricDecimalQuantity
	--	  , TARGET.[DaysSupply] = SOURCE.DaysSupply
	--	  , TARGET.[DispenseAsWritten] = SOURCE.DispenseAsWritten
	--	  , TARGET.[WrittenDate] = SOURCE.WrittenDate
	--	  , TARGET.[RefillsAuthorizedCount] = SOURCE.RefillsAuthorizedCount
	--	  , TARGET.[DrugProductName] = SOURCE.DrugProductName
	--	  , TARGET.[DrugProductDesc] = SOURCE.DrugProductDesc
	--	  , TARGET.[DrugTier] = SOURCE.DrugTier
	--	  , TARGET.[GenericProductID] = SOURCE.GenericProductID
	--	  , TARGET.[GenericProductName] = SOURCE.GenericProductName
	--	  , TARGET.[AHFSCode] = SOURCE.AHFSCode
	--	  , TARGET.[DrugDEAClassCode] = SOURCE.DrugDEAClassCode
	--	  , TARGET.[RXOTCCode] = SOURCE.RXOTCCode
	--	  , TARGET.[MultiSourceIndicator] = SOURCE.MultiSourceIndicator
	--	  , TARGET.[DrugStrength] = SOURCE.DrugStrength
	--	  , TARGET.[DrugStrengthUnitOfMeasure] = SOURCE.DrugStrengthUnitOfMeasure
	--	  , TARGET.[SubmittingPharmacyID] = SOURCE.SubmittingPharmacyID
	--	  , TARGET.[PharmIDQualifier] = SOURCE.PharmIDQualifier
	--	  , TARGET.[PharmacyName] = SOURCE.PharmacyName
	--	  , TARGET.[PharmacyStoreNum] = SOURCE.PharmacyStoreNum
	--	  , TARGET.[PrescriberID] = SOURCE.PrescriberID
	--	  , TARGET.[PrescriberIDQualifier] = SOURCE.PrescriberIDQualifier
	--	  , TARGET.[PrescriberName] = SOURCE.PrescriberName
	--	  , TARGET.[RejectCode1Description] = SOURCE.RejectCode1Description
	--	  , TARGET.[DiagnosisCode] = SOURCE.DiagnosisCode
	--	  , TARGET.[DiagnosisCodeQualifier] = SOURCE.DiagnosisCodeQualifier
	--	  , TARGET.[DrugConflictCode1] = SOURCE.DrugConflictCode1
	--	  , TARGET.[BilledAmount] = SOURCE.BilledAmount
	--	  , TARGET.[CoveredAmount] = SOURCE.CoveredAmount
	--	  , TARGET.[PaidAmount] = SOURCE.PaidAmount
	--	  , TARGET.[CurrentBatchID]= SOURCE.[CurrentBatchID]
	--	  , TARGET.[NdcPhiSensInd] = SOURCE.[NdcPhiSensInd]
	--	  , TARGET.[DiagPhiSensInd]= SOURCE.[DiagPhiSensInd]
	--	  , TARGET.[PlanGroup]= SOURCE.[PlanGroup]
	--	  , TARGET.[SubgroupKey]= SOURCE.[SubgroupKey]
	--	  , TARGET.[MemberKey]= SOURCE.[MemberKey]
	--	  , TARGET.[CompanyKey]= SOURCE.[CompanyKey]
	--	  , TARGET.[PartyKey]= SOURCE.[PartyKey]
	--	  , TARGET.[LOB]= SOURCE.[LOB]
	--	  , TARGET.[DataSource]=SOURCE.[DataSource]
	--	  , TARGET.[LoadDate]=SOURCE.[LoadDate]
	--	  , TARGET.[ClientLoadDT]=SOURCE.[ClientLoadDT]


	WHEN NOT MATCHED BY TARGET THEN 
	INSERT([MVDID]
		  ,[ClaimNumber]
		  ,[ClaimStatus]
		  ,[PaidClaimAuthNum]
		  ,[MemberID]
		  ,[MemberLastName]
		  ,[MemberFirstName]
		  ,[MemberMiddleName]
		  ,[Gender]
		  ,[DateOfBirth]
		  ,[ZipCode]
		  ,[SSN]
		  ,[SubscriberID]
		  ,[ClaimProcessingDate]
		  ,[ServiceDate]
		  ,[RefillCode]
		  ,[CompoundCode]
		  ,[ProductServiceQualifier]
		  ,[NDCCode]
		  ,[MetricDecimalQuantity]
		  ,[DaysSupply]
		  ,[DispenseAsWritten]
		  ,[WrittenDate]
		  ,[RefillsAuthorizedCount]
		  ,[DrugProductName]
		  ,[DrugProductDesc]
		  ,[DrugTier]
		  ,[GenericProductID]
		  ,[GenericProductName]
		  ,[AHFSCode]
		  ,[DrugDEAClassCode]
		  ,[RXOTCCode]
		  ,[MultiSourceIndicator]
		  ,[DrugStrength]
		  ,[DrugStrengthUnitOfMeasure]
		  ,[SubmittingPharmacyID]
		  ,[PharmIDQualifier]
		  ,[PharmacyName]
		  ,[PharmacyStoreNum]
		  ,[PrescriberID]
		  ,[PrescriberIDQualifier]
		  ,[PrescriberName]
		  ,[RejectCode1Description]
		  ,[DiagnosisCode]
		  ,[DiagnosisCodeQualifier]
		  ,[DrugConflictCode1]
		  ,[RXReferenceNumber]
		  ,[BilledAmount]
		  ,[CoveredAmount]
		  ,[PaidAmount]
		  ,[CustID]
		  ,[BaseBatchID]
		  ,[CurrentBatchID]
		  ,ClaimLinenumber
		--added 0712 Luna 
		  ,[PartyKey]
		  ,[MemberKey]
		  ,[CompanyKey]
		  ,[SubgroupKey]
		  ,[PlanGroup]
		  ,[LOB]
		  ,[claimkey]
		  ,[NdcPhiSensInd]
		  ,[DiagPhiSensInd]
		  ,[DataSource]
		  ,[LoadDate]
		  ,[ClientLoadDT]
		  )
		 VALUES           
		 ( SOURCE.[MVDID]
		  ,SOURCE.[ClaimNumber]
		  ,SOURCE.[ClaimStatus]
		  ,SOURCE.[PaidClaimAuthNum]
		  ,SOURCE.[MemberID]
		  ,SOURCE.[MemberLastName]
		  ,SOURCE.[MemberFirstName]
		  ,SOURCE.[MemberMiddleName]
		  ,SOURCE.[Gender]
		  ,SOURCE.[DateOfBirth]
		  ,SOURCE.[ZipCode]
		  ,SOURCE.[SSN]
		  ,SOURCE.[SubscriberID]
		  ,SOURCE.[ClaimProcessingDate]
		  ,SOURCE.[ServiceDate]
		  ,SOURCE.[RefillCode]
		  ,SOURCE.[CompoundCode]
		  ,SOURCE.[ProductServiceQualifier]
		  ,SOURCE.[NDCCode]
		  ,SOURCE.[MetricDecimalQuantity]
		  ,SOURCE.[DaysSupply]
		  ,SOURCE.[DispenseAsWritten]
		  ,SOURCE.[WrittenDate]
		  ,SOURCE.[RefillsAuthorizedCount]
		  ,SOURCE.[DrugProductName]
		  ,SOURCE.[DrugProductDesc]
		  ,SOURCE.[DrugTier]
		  ,SOURCE.[GenericProductID]
		  ,SOURCE.[GenericProductName]
		  ,SOURCE.[AHFSCode]
		  ,SOURCE.[DrugDEAClassCode]
		  ,SOURCE.[RXOTCCode]
		  ,SOURCE.[MultiSourceIndicator]
		  ,SOURCE.[DrugStrength]
		  ,SOURCE.[DrugStrengthUnitOfMeasure]
		  ,SOURCE.[SubmittingPharmacyID]
		  ,SOURCE.[PharmIDQualifier]
		  ,SOURCE.[PharmacyName]
		  ,SOURCE.[PharmacyStoreNum]
		  ,SOURCE.[PrescriberID]
		  ,SOURCE.[PrescriberIDQualifier]
		  ,SOURCE.[PrescriberName]
		  ,SOURCE.[RejectCode1Description]
		  ,SOURCE.[DiagnosisCode]
		  ,SOURCE.[DiagnosisCodeQualifier]
		  ,SOURCE.[DrugConflictCode1]
		  ,SOURCE.[RXReferenceNumber]
		  ,SOURCE.[BilledAmount]
		  ,SOURCE.[CoveredAmount]
		  ,SOURCE.[PaidAmount]
		  ,SOURCE.[CustID]
		  ,SOURCE.[BaseBatchID]
		  ,SOURCE.[CurrentBatchID]
		  ,SOURCE.ClaimLinenumber
		  ,SOURCE.[PartyKey]
		  ,SOURCE.[MemberKey]
		  ,SOURCE.[CompanyKey]
		  ,SOURCE.[SubgroupKey]
		  ,SOURCE.[PlanGroup]
		  ,SOURCE.[LOB]
		  ,SOURCE.[claimkey]
		  ,SOURCE.[NdcPhiSensInd]
		  ,SOURCE.[DiagPhiSensInd]
		  ,SOURCE.[DataSource]
		  ,SOURCE.[LoadDate]
		  ,SOURCE.[ClientLoadDT]
		 );
	
	
    if @@ERROR>0 
	Rollback transaction RX
	ELSE
	Commit transaction RX



	END


-- FOR LAB, IT'S APPEND. SO JUST INSERT
--if @filetype = 'Lab'

BEGIN

	BEGIN TRANSACTION lab

	TRUNCATE TABLE MyVitaDataUAT.dbo.FinalLab

	INSERT INTO MyVitalDataUAT.dbo.[FinalLab] 
		(
				[MVDID]
				,[MemberID]
				,[MemberLastName]
				,[MemberFirstName]
				,[MemberMiddleName]
				,[OrderDate]
				,[OrderingPhysicianNPI]
				,[OrderingPhysicianName]
				,[OrderName]
				,[OrderCode]
				,[OrderCodingSystem]
				,[TestDate]
				,[TestName]
				,[TestCode]
				,[TestResult]
				,[ResultUnit]
				,[RefInterpretationFlag]
				,[ResultNote]
				,[ProviderID]
				,[ProviderName]
				,[CustID]
				,[BaseBatchID]
				,[CurrentBatchID]
				,LabDataSource
				,ReferenceRange
				,SequenceNum
				,PartyKey
				,MemberKey
				,[CreateDate]
				,[UpdateDate]
				,[ResultHistID]
				,[LOB]
				,[LoadDate]
		)

		SELECT	
				[MVDID]
			,[MemberID]
			,[MemberLastName]
			,[MemberFirstName]
			,[MemberMiddleName]
			,[OrderDate]
			,[OrderingPhysicianNPI]
			,[OrderingPhysicianName]
			,[OrderName]
			,[OrderCode]
			,[OrderCodingSystem]
			,[TestDate]
			,[TestName]
			,[TestCode]
			,[TestResult]
			,[ResultUnit]
			,[RefInterpretationFlag]
			,[ResultNote]
			,[ProviderID]
			,[ProviderName]
			,[CustID]
			,[BaseBatchID]
			,[CurrentBatchID]
			,[LabDataSource] 
			,[ReferenceRange] 
			,[SequenceNum]
			,[PartyKey]
			,[MemberKey]
			,[CreateDate]
			,[UpdateDate]
			,[ResultHistID]
			,[LOB]
			,[LoadDate]
		FROM [VD-RPT02].[BatchImportABCBS].[dbo].[FinalLab] 
	
		
    if @@ERROR>0 
	Rollback transaction Lab
	ELSE
	Commit transaction Lab

END

 
--IF @filetype = 'ClaimsHeader'

BEGIN

BEGIN TRANSACTION ClaimsHeader
	
	DELETE FROM MyVitalDataUAT.dbo.FinalClaimsHeader
	where ClaimNumber IN (Select ClaimNumber from [VD-RPT02].[BatchImportABCBS].[dbo].[FinalClaimsHeader] where CurrentBatchID IN
	(SELECT max(CurrentBatchID) from [VD-RPT02].[BatchImportABCBS].[dbo].[FinalClaimsHeader]))

	MERGE  MyVitalDataUAT.dbo.[FinalClaimsHeader] AS TARGET
	USING (
	SELECT [RecordID]
		  ,[MVDID]
		  ,[ClaimNumber]
		  ,[MemberID]
		  ,[MemberLastName]
		  ,[MemberFirstName]
		  ,[MemberMiddleName]
		  ,[PatientDob]
		  ,[PatientGender]
		  ,[BillType]
		  ,[PlaceOfService]
		  ,[StatementFromDate]
		  ,[StatementThroughDate]
		  ,[ReasonCode]
		  ,[AdjustmentCode]
		  ,[AdmissionSource]
		  ,[AdmissionType]
		  ,[EmergencyIndicator]
		  ,[NetworkIndicator]
		  ,[AdmissionDate]
		  ,[DischargeDate]
		  ,[CoveredDays]
		  ,[DischargeStatusCode]
		  ,[DRG]
		  ,[FeeScheduleCode]
		  ,[ProcessDate]
		  ,[PaidDate]
		  ,[BilledAmount]
		  ,[NonCoveredAmount]
		  ,[CoPayAmount]
		  ,[COBAmount]
		  ,[WithholdAmount]
		  ,[DiscountAmount]
		  ,[DeductibleAmount]
		  ,[CoInsuranceAmount]
		  ,[TotalPaidAmount]
		  ,[RefundAmount]
		  ,[ReceivedDate]
		  ,[ClaimStatus]
		  ,[AuthorizationNumber]
		  ,[CheckNumber]
		  ,[CheckDate]
		  ,[RenderingProviderNPI]
		  ,[AttendingProviderNPI]
		  ,[OperatingProviderNPI]
		  ,[OtherProviderNPI]
		  ,[BillingProviderNPI]
		  ,[Taxonomy]
		  ,[FacilityTIN]
		  ,[AllowedAmount]
		  ,[CustID]
		  ,[BaseBatchID]
		  ,[CurrentBatchID]
		  ,[PartyKey]
		  ,[MemberKey]
		  ,[CompanyKey]
		  ,[SubgroupKey]
		  ,[PlanGroup]
		  ,[LOB]
		  ,[DataSource]
		  ,[LoadDate]
		  ,[ClientLoadDT]
	  FROM [VD-RPT02].BatchImportABCBS.[dbo].[FinalClaimsHeader] 
	) AS SOURCE 
		ON    
		(	TARGET.[ClaimNumber]=SOURCE.[ClaimNumber]  ) 
			
--WHEN MATCHED 

--THEN 
--UPDATE SET 
--		TARGET.MVDID=SOURCE.MVDID
--   	  , TARGET.[MemberID] = SOURCE.MemberID
--      , TARGET.[MemberLastName] = SOURCE.MemberLastName
--      , TARGET.[MemberFirstName] = SOURCE.MemberFirstName
--      , TARGET.[MemberMiddleName] = SOURCE.MemberMiddleName
--      , TARGET.[PatientDob] = SOURCE.PatientDob
--      , TARGET.[PatientGender] = SOURCE.PatientGender
--      , TARGET.[BillType] = SOURCE.BillType
--      , TARGET.[PlaceOfService] = SOURCE.PlaceOfService
--      , TARGET.[StatementFromDate] = SOURCE.StatementFromDate
--      , TARGET.[StatementThroughDate] = SOURCE.StatementThroughDate
--      , TARGET.[ReasonCode] = SOURCE.ReasonCode
--      , TARGET.[AdjustmentCode] = SOURCE.AdjustmentCode
--      , TARGET.[AdmissionSource] = SOURCE.AdmissionSource
--      , TARGET.[AdmissionType] = SOURCE.AdmissionType
--      , TARGET.[EmergencyIndicator] = SOURCE.EmergencyIndicator
--      , TARGET.[NetworkIndicator] = SOURCE.NetworkIndicator
--      , TARGET.[AdmissionDate] = SOURCE.AdmissionDate
--      , TARGET.[DischargeDate] = SOURCE.DischargeDate
--      , TARGET.[CoveredDays] = SOURCE.CoveredDays
--      , TARGET.[DischargeStatusCode] = SOURCE.DischargeStatusCode
--      , TARGET.[DRG] = SOURCE.DRG
--      , TARGET.[FeeScheduleCode] = SOURCE.FeeScheduleCode
--      , TARGET.[ProcessDate] = SOURCE.ProcessDate
--      , TARGET.[PaidDate] = SOURCE.PaidDate
--      , TARGET.[BilledAmount] = SOURCE.BilledAmount
--      , TARGET.[NonCoveredAmount] = SOURCE.NonCoveredAmount
--      , TARGET.[CoPayAmount] = SOURCE.CoPayAmount
--      , TARGET.[COBAmount] = SOURCE.COBAmount
--      , TARGET.[WithholdAmount] = SOURCE.WithholdAmount
--      , TARGET.[DiscountAmount] = SOURCE.DiscountAmount
--      , TARGET.[DeductibleAmount] = SOURCE.DeductibleAmount
--      , TARGET.[CoInsuranceAmount] = SOURCE.CoInsuranceAmount
--      , TARGET.[TotalPaidAmount] = SOURCE.TotalPaidAmount
--      , TARGET.[RefundAmount] = SOURCE.RefundAmount
--      , TARGET.[ReceivedDate] = SOURCE.ReceivedDate
--      , TARGET.[ClaimStatus] = SOURCE.ClaimStatus
--      , TARGET.[AuthorizationNumber] = SOURCE.AuthorizationNumber
--      , TARGET.[CheckNumber] = SOURCE.CheckNumber
--      , TARGET.[CheckDate] = SOURCE.CheckDate
--      , TARGET.[RenderingProviderNPI] = SOURCE.RenderingProviderNPI
--      , TARGET.[AttendingProviderNPI] = SOURCE.AttendingProviderNPI
--      , TARGET.[OperatingProviderNPI] = SOURCE.OperatingProviderNPI
--      , TARGET.[OtherProviderNPI] = SOURCE.OtherProviderNPI
--      , TARGET.[BillingProviderNPI] = SOURCE.BillingProviderNPI
--      , TARGET.[Taxonomy] = SOURCE.Taxonomy
--      , TARGET.[FacilityTIN] = SOURCE.FacilityTIN
--	  , TARGET.[CurrentBatchID]=SOURCE.[CurrentBatchID]
--	  , TARGET.[AllowedAmount] = SOURCE.[AllowedAmount]
--	  , TARGET.[DataSource] = SOURCE.[DataSource]
--	  , TARGET.[LOB]= SOURCE.[LOB]
--	  , TARGET.[PartyKey]= SOURCE.[PartyKey]
--	  , TARGET.[MemberKey]	= SOURCE.[MemberKey]
--	  , TARGET.[SubgroupKey]	= SOURCE.[SubgroupKey]
--	  , TARGET.[CompanyKey]	= SOURCE.[CompanyKey]
--	  , TARGET.[PlanGroup]	= SOURCE.[PlanGroup]
--	  , TARGET.[LoadDate]	= SOURCE.[LoadDate]
--	  , TARGET.[ClientLoadDT]	= SOURCE.[ClientLoadDT]
	 
WHEN NOT MATCHED BY TARGET THEN 
	INSERT([MVDID]
      ,[ClaimNumber]
      ,[MemberID]
      ,[MemberLastName]
      ,[MemberFirstName]
      ,[MemberMiddleName]
      ,[PatientDob]
      ,[PatientGender]
      ,[BillType]
      ,[PlaceOfService]
      ,[StatementFromDate]
      ,[StatementThroughDate]
      ,[ReasonCode]
      ,[AdjustmentCode]
      ,[AdmissionSource]
      ,[AdmissionType]
      ,[EmergencyIndicator]
      ,[NetworkIndicator]
      ,[AdmissionDate]
      ,[DischargeDate]
      ,[CoveredDays]
      ,[DischargeStatusCode]
      ,[DRG]
      ,[FeeScheduleCode]
      ,[ProcessDate]
      ,[PaidDate]
      ,[BilledAmount]
      ,[NonCoveredAmount]
      ,[CoPayAmount]
      ,[COBAmount]
      ,[WithholdAmount]
      ,[DiscountAmount]
      ,[DeductibleAmount]
      ,[CoInsuranceAmount]
      ,[TotalPaidAmount]
      ,[RefundAmount]
      ,[ReceivedDate]
      ,[ClaimStatus]
      ,[AuthorizationNumber]
      ,[CheckNumber]
      ,[CheckDate]
      ,[RenderingProviderNPI]
      ,[AttendingProviderNPI]
      ,[OperatingProviderNPI]
      ,[OtherProviderNPI]
      ,[BillingProviderNPI]
      ,[Taxonomy]
      ,[FacilityTIN]
	  ,[AllowedAmount]
      ,[CustID]
      ,[BaseBatchID]
      ,[CurrentBatchID]
	  ,[PartyKey]
	  ,[MemberKey]
	  ,[CompanyKey]
	  ,[SubgroupKey]
	  ,[PlanGroup]
	  ,[LOB]
	  ,[DataSource]
	  ,[LoadDate]
	  ,[ClientLoadDT]
	  )
     VALUES           
	 ( Source.[MVDID]
      ,Source.[ClaimNumber]
      ,Source.[MemberID]
      ,Source.[MemberLastName]
      ,Source.[MemberFirstName]
      ,Source.[MemberMiddleName]
      ,Source.[PatientDob]
      ,Source.[PatientGender]
      ,Source.[BillType]
      ,Source.[PlaceOfService]
      ,Source.[StatementFromDate]
      ,Source.[StatementThroughDate]
      ,Source.[ReasonCode]
      ,Source.[AdjustmentCode]
      ,Source.[AdmissionSource]
      ,Source.[AdmissionType]
      ,Source.[EmergencyIndicator]
      ,Source.[NetworkIndicator]
      ,Source.[AdmissionDate]
      ,Source.[DischargeDate]
      ,Source.[CoveredDays]
      ,Source.[DischargeStatusCode]
      ,Source.[DRG]
      ,Source.[FeeScheduleCode]
      ,Source.[ProcessDate]
      ,Source.[PaidDate]
      ,Source.[BilledAmount]
      ,Source.[NonCoveredAmount]
      ,Source.[CoPayAmount]
      ,Source.[COBAmount]
      ,Source.[WithholdAmount]
      ,Source.[DiscountAmount]
      ,Source.[DeductibleAmount]
      ,Source.[CoInsuranceAmount]
      ,Source.[TotalPaidAmount]
      ,Source.[RefundAmount]
      ,Source.[ReceivedDate]
      ,Source.[ClaimStatus]
      ,Source.[AuthorizationNumber]
      ,Source.[CheckNumber]
      ,Source.[CheckDate]
      ,Source.[RenderingProviderNPI]
      ,Source.[AttendingProviderNPI]
      ,Source.[OperatingProviderNPI]
      ,Source.[OtherProviderNPI]
      ,Source.[BillingProviderNPI]
      ,Source.[Taxonomy]
      ,Source.[FacilityTIN]
	  ,SOURCE.[AllowedAmount]
      ,Source.[CustID]
      ,Source.[BaseBatchID]
      ,Source.[CurrentBatchID]
	  ,source.[PartyKey]
	  ,source.[MemberKey]
	  ,source.[CompanyKey]
	  ,source.[SubgroupKey]
	  ,source.[PlanGroup]
	  ,source.[LOB]
	  ,source.[DataSource]
	  ,source.[LoadDate]
	  ,source.[ClientLoadDT]
	  );
	  
	  if @@ERROR>0 
	  Rollback Transaction ClaimsHeader
	  ELSE
	  Commit transaction ClaimsHeader

END 

--if @filetype = 'ClaimsHeaderCode'
begin

BEGIN TRANSACTION ClaimsHeaderCode

DELETE FROM MyVitalDataUAT.dbo.FinalClaimsHeaderCode
	where ClaimNumber IN (Select ClaimNumber from [VD-RPT02].[BatchImportABCBS].[dbo].[FinalClaimsHeaderCode] where CurrentBatchID IN
	(SELECT max(CurrentBatchID) from [VD-RPT02].[BatchImportABCBS].[dbo].[FinalClaimsHeaderCode]))

MERGE  MyVitalDataUAT.dbo.[FinalClaimsHeaderCode] AS TARGET
USING (

SELECT [RecordID]
      ,[MVDID]
	  --,[MemberID]
      ,[ClaimNumber]
      ,[ICDVersion]
      ,[CodeType]
      ,[CodeValue]
      ,[SequenceNumber]
      ,[PresentOnAdmissionFlag]
      ,[AdmittingDiagnosisFlag]
      ,[DischargeDiagnosisFlag]
      ,[DiagnosisIndicator]
      ,[DateFrom]
      ,[DateThrough]
      ,[Amount]
      ,[CustID]
	  ,PrimaryIndicator   --Added
      ,[BaseBatchID]
	  ,[CurrentBatchID]
	  ,[PhiSensInd] 
	  ,[LoadDate]
	  ,[ClientLoadDT]
  FROM [VD-RPT02].BatchImportABCBS.[dbo].[FinalClaimsHeaderCode] 
  ) AS SOURCE 
ON (    TARGET.[ClaimNumber]=SOURCE.[ClaimNumber] 
		
		) 

--WHEN MATCHED 
	      
--THEN 
--UPDATE SET 
--   		TARGET.[MVDID] = SOURCE.[MVDID]
--      , TARGET.[ICDVersion] = SOURCE.ICDVersion
--      , TARGET.[CodeType] = SOURCE.CodeType
--      , TARGET.[CodeValue] = SOURCE.CodeValue
--      , TARGET.[SequenceNumber] = SOURCE.SequenceNumber      
--	  , TARGET.[PresentOnAdmissionFlag] = SOURCE.PresentOnAdmissionFlag
--      , TARGET.[AdmittingDiagnosisFlag] = SOURCE.AdmittingDiagnosisFlag
--      , TARGET.[DischargeDiagnosisFlag] = SOURCE.DischargeDiagnosisFlag
--      , TARGET.[DiagnosisIndicator] = SOURCE.DiagnosisIndicator
--      , TARGET.[DateFrom] = SOURCE.DateFrom
--      , TARGET.[DateThrough] = SOURCE.DateThrough
--      , TARGET.[Amount] = SOURCE.Amount
--	  , TARGET.[CurrentBatchID]= SOURCE.[CurrentBatchID]
--	  , TARGET.PrimaryIndicator= SOURCE.PrimaryIndicator
--	  , TARGET.[PhiSensInd] = SOURCE.[PhiSensInd]
--	  , TARGET.[LoadDate] = SOURCE.[LoadDate]
--	  , TARGET.[ClientLoadDT] = SOURCE.[ClientLoadDT]
	   
	  
WHEN NOT MATCHED BY TARGET THEN 
	INSERT(	
		   [MVDID]	
		  ,[ClaimNumber]
		  ,[ICDVersion]
		  ,[CodeType]
		  ,[CodeValue]
		  ,[SequenceNumber]
		  ,[PresentOnAdmissionFlag]
		  ,[AdmittingDiagnosisFlag]
		  ,[DischargeDiagnosisFlag]
		  ,[DiagnosisIndicator]
		  ,[DateFrom]
		  ,[DateThrough]
		  ,[Amount]
		  ,[CustID]
		  ,[BaseBatchID]
		  ,[CurrentBatchID]
		  ,PrimaryIndicator--Added
		  ,PhiSensInd
		  ,LoadDate
		  ,ClientLoadDT
	  )
     
	 VALUES           
	 ( Source.[MVDID]	  
      ,Source.[ClaimNumber]
      ,Source.[ICDVersion]
      ,Source.[CodeType]
      ,Source.[CodeValue]
      ,Source.[SequenceNumber]
      ,Source.[PresentOnAdmissionFlag]
      ,Source.[AdmittingDiagnosisFlag]
      ,Source.[DischargeDiagnosisFlag]
      ,Source.[DiagnosisIndicator]
      ,Source.[DateFrom]
      ,Source.[DateThrough]
      ,Source.[Amount]
      ,Source.[CustID]
      ,Source.[BaseBatchID]
	  ,Source.[CurrentBatchID]
	  ,Source.PrimaryIndicator--Added
	  ,Source.PhiSensInd
	  ,Source.LoadDate
	  ,Source.ClientLoadDT
	  );

	if @@Error>0 
	rollback transaction ClaimsHeaderCode
	ELSE
	Commit transaction ClaimsHeaderCode

END 

--if @filetype = 'ClaimsDetail'

BEGIN

begin transaction ClaimsDetail

DELETE FROM MyVitalDataUAT.dbo.FinalClaimsDetail
	where ClaimNumber IN (Select ClaimNumber from [VD-RPT02].[BatchImportABCBS].[dbo].[FinalClaimsDetail] where CurrentBatchID IN
	(SELECT max(CurrentBatchID) from [VD-RPT02].[BatchImportABCBS].[dbo].[FinalClaimsDetail]))

	
MERGE  MyVitalDataUAT.dbo.[FinalClaimsDetail] AS TARGET
USING (

SELECT [RecordID]
      ,[MVDID]
      ,[ClaimNumber]
      ,[ClaimLinenumber]
      ,[MemberID]
      ,[ServiceFromDate]
      ,[ServiceThroughDate]
      ,[ServiceProviderNPI]
      ,[PlaceOfService]
      ,[AdjustmentCode]
      ,[ProcedureCode]
      ,[Mod1]
      ,[Mod2]
      ,[CPT2Mod]
      ,[RevenueCode]
      ,[ServiceUnits]
      ,[BilledAmount]
      ,[NonCoveredAmount]
      ,[AllowedAmount]
      ,[PaidAmount]
      ,[DRGCode]
      ,[OriginalClaimIndicator]
      ,[OriginalClaimNumber]
      ,[OriginalClaimLineNumber]
      ,[ServiceLocation]
      ,[ReasonCode]
      ,[CoveredDays]
      ,[FeeScheduleCode]
      ,[ProcessDate]
      ,[PaidDate]
      ,[ReceivedDate]
      ,[ClaimLineStatus]
      ,[AuthorizationNumber]
      ,[CustID]
      ,[BaseBatchID]
	  ,[CurrentBatchID]
	  ,PartyKey	 --added
	  ,MemberKey --added
      ,CompanyKey--added
	  ,PlanGroup --added
	  ,SubgroupKey--added
	  ,LOB -- added
	  ,[COBAmount]
      ,[CoInsuranceAmount]
      ,[CoPayAmount]
      ,[DeductibleAmount]
      ,[DiscountAmount]
      ,[WithholdAmount]
      ,[ReasonCode2]
      ,[ReasonCode3]
      ,[ReasonCode4]
      ,[ReasonCode5]
      ,[ReasonCode6]
	  ,[DataSource]
	  ,[PhiSensInd]
	  ,[LoadDate]
	  ,[ClientLoadDT]

  FROM [VD-RPT02].BatchImportABCBS.[dbo].[FinalClaimsDetail] 
  ) AS SOURCE 
ON   (     TARGET.[ClaimNumber]=SOURCE.[ClaimNumber] 		
	 )

--WHEN MATCHED 
 
--THEN 
--UPDATE SET 
--	    TARGET.[MVDID] = SOURCE.[MVDID]
--      , TARGET.[MemberID] = SOURCE.[MemberID]
--	  , TARGET.[ClaimLinenumber]=SOURCE.[ClaimLinenumber] 
--      , TARGET.[ServiceFromDate] = SOURCE.ServiceFromDate
--      , TARGET.[ServiceThroughDate] = SOURCE.ServiceThroughDate
--      , TARGET.[ServiceProviderNPI] = SOURCE.ServiceProviderNPI
--      , TARGET.[PlaceOfService] = SOURCE.PlaceOfService
--      , TARGET.[AdjustmentCode] = SOURCE.AdjustmentCode
--      , TARGET.[ProcedureCode] = SOURCE.ProcedureCode
--      , TARGET.[Mod1] = SOURCE.Mod1
--      , TARGET.[Mod2] = SOURCE.Mod2
--      , TARGET.[CPT2Mod] = SOURCE.CPT2Mod
--      , TARGET.[RevenueCode] = SOURCE.RevenueCode
--      , TARGET.[ServiceUnits] = SOURCE.ServiceUnits
--      , TARGET.[BilledAmount] = SOURCE.BilledAmount
--      , TARGET.[NonCoveredAmount] = SOURCE.NonCoveredAmount
--      , TARGET.[AllowedAmount] = SOURCE.AllowedAmount
--      , TARGET.[PaidAmount] = SOURCE.PaidAmount
--      , TARGET.[DRGCode] = SOURCE.DRGCode
--      , TARGET.[OriginalClaimIndicator] = SOURCE.OriginalClaimIndicator
--      , TARGET.[OriginalClaimNumber] = SOURCE.OriginalClaimNumber
--      , TARGET.[OriginalClaimLineNumber] = SOURCE.OriginalClaimLineNumber
--      , TARGET.[ServiceLocation] = SOURCE.ServiceLocation
--      , TARGET.[ReasonCode] = SOURCE.ReasonCode
--      , TARGET.[CoveredDays] = SOURCE.CoveredDays
--      , TARGET.[FeeScheduleCode] = SOURCE.FeeScheduleCode
--      , TARGET.[ProcessDate] = SOURCE.ProcessDate
--      , TARGET.[PaidDate] = SOURCE.PaidDate
--      , TARGET.[ReceivedDate] = SOURCE.ReceivedDate
--      , TARGET.[ClaimLineStatus] = SOURCE.ClaimLineStatus
--      , TARGET.[AuthorizationNumber] = SOURCE.AuthorizationNumber
--	  , TARGET.[CurrentBatchID]= SOURCE.[CurrentBatchID]
--	  , TARGET.[MemberKey]= SOURCE.MemberKey
--      , TARGET.[CompanyKey]= SOURCE.CompanyKey
--      , TARGET.[PlanGroup]= SOURCE.PlanGroup
--      , TARGET.[SubgroupKey]= SOURCE.SubgroupKey
--	  , TARGET.[COBAmount]= SOURCE.[COBAmount]
--      , TARGET.[CoInsuranceAmount] = SOURCE.[CoInsuranceAmount]
--      , TARGET.[CoPayAmount] = SOURCE.[CoPayAmount]
--      , TARGET.[DeductibleAmount] = SOURCE.[DeductibleAmount]
--      , TARGET.[DiscountAmount] = SOURCE.[DiscountAmount]
--      , TARGET.[WithholdAmount] = SOURCE.[WithholdAmount]
--      , TARGET.[ReasonCode2] = SOURCE.[ReasonCode2]
--      , TARGET.[ReasonCode3] = SOURCE.[ReasonCode3]
--	  , TARGET.[ReasonCode4] = SOURCE.[ReasonCode4]
--      , TARGET.[ReasonCode5] = SOURCE.[ReasonCode5]
--	  , TARGET.[ReasonCode6] = SOURCE.[ReasonCode6]
--	  , TARGET.[DataSource] = SOURCE.[DataSource]
--	  , TARGET.[PhiSensInd] = SOURCE.[PhiSensInd]


WHEN NOT MATCHED BY TARGET THEN 
	INSERT(	
	   [MVDID]
      ,[ClaimNumber]
      ,[ClaimLinenumber]
      ,[MemberID]
      ,[ServiceFromDate]
      ,[ServiceThroughDate]
      ,[ServiceProviderNPI]
      ,[PlaceOfService]
      ,[AdjustmentCode]
      ,[ProcedureCode]
      ,[Mod1]
      ,[Mod2]
      ,[CPT2Mod]
      ,[RevenueCode]
      ,[ServiceUnits]
      ,[BilledAmount]
      ,[NonCoveredAmount]
      ,[AllowedAmount]
      ,[PaidAmount]
      ,[DRGCode]
      ,[OriginalClaimIndicator]
      ,[OriginalClaimNumber]
      ,[OriginalClaimLineNumber]
      ,[ServiceLocation]
      ,[ReasonCode]
      ,[CoveredDays]
      ,[FeeScheduleCode]
      ,[ProcessDate]
      ,[PaidDate]
      ,[ReceivedDate]
      ,[ClaimLineStatus]
      ,[AuthorizationNumber]
      ,[CustID]
      ,[BaseBatchID]
	  ,[CurrentBatchID]
	  ,PartyKey	
	  ,MemberKey	
	  ,CompanyKey	
	  ,PlanGroup	
	  ,SubgroupKey
	  ,LOB
	  ,[COBAmount]
      ,[CoInsuranceAmount]
      ,[CoPayAmount]
      ,[DeductibleAmount]
      ,[DiscountAmount]
      ,[WithholdAmount]
      ,[ReasonCode2]
      ,[ReasonCode3]
      ,[ReasonCode4]
      ,[ReasonCode5]
      ,[ReasonCode6]
	  ,[DataSource]
	  ,[PhiSensInd]
	  ,[LoadDate]
	  ,[ClientLoadDT]
)
     VALUES           
	 ( Source.[MVDID]
      ,Source.[ClaimNumber]
      ,Source.[ClaimLinenumber]
      ,Source.[MemberID]
      ,Source.[ServiceFromDate]
      ,Source.[ServiceThroughDate]
      ,Source.[ServiceProviderNPI]
      ,Source.[PlaceOfService]
      ,Source.[AdjustmentCode]
      ,Source.[ProcedureCode]
      ,Source.[Mod1]
      ,Source.[Mod2]
      ,Source.[CPT2Mod]
      ,Source.[RevenueCode]
      ,Source.[ServiceUnits]
      ,Source.[BilledAmount]
      ,Source.[NonCoveredAmount]
      ,Source.[AllowedAmount]
      ,Source.[PaidAmount]
      ,Source.[DRGCode]
      ,Source.[OriginalClaimIndicator]
      ,Source.[OriginalClaimNumber]
      ,Source.[OriginalClaimLineNumber]
      ,Source.[ServiceLocation]
      ,Source.[ReasonCode]
      ,Source.[CoveredDays]
      ,Source.[FeeScheduleCode]
      ,Source.[ProcessDate]
      ,Source.[PaidDate]
      ,Source.[ReceivedDate]
      ,Source.[ClaimLineStatus]
      ,Source.[AuthorizationNumber]
      ,Source.[CustID]
      ,Source.[BaseBatchID]
	  ,Source.[CurrentBatchID]
	  ,Source.[PartyKey]
	  ,Source.[MemberKey]
	  ,Source.[CompanyKey]
	  ,Source.[PlanGroup]
	  ,Source.[SubgroupKey]
	  ,Source.[LOB]
	  ,Source.[COBAmount]
      ,Source.[CoInsuranceAmount]
      ,Source.[CoPayAmount]
      ,Source.[DeductibleAmount]
      ,Source.[DiscountAmount]
      ,Source.[WithholdAmount]
      ,Source.[ReasonCode2]
      ,Source.[ReasonCode3]
      ,Source.[ReasonCode4]
      ,Source.[ReasonCode5]
      ,Source.[ReasonCode6]
	  ,Source.[DataSource]
	  ,Source.[PhiSensInd]
	  ,Source.[LoadDate]
	  ,Source.[ClientLoadDT]
	  );

	if @@ERROR>0 
	rollback transaction ClaimsDetail
	ELSE
	Commit transaction ClaimsDetail

END 

--if @filetype = 'ClaimsDetailCode'
begin

BEGIN TRANSACTION ClaimsDetailCode

DELETE FROM MyVitalDataUAT.dbo.FinalClaimsDetailCode
	where ClaimNumber IN (Select ClaimNumber from [VD-RPT02].[BatchImportABCBS].[dbo].[FinalClaimsDetailCode] where CurrentBatchID IN
	(SELECT max(CurrentBatchID) from [VD-RPT02].[BatchImportABCBS].[dbo].[FinalClaimsDetailCode]))

MERGE  MyVitalDataUAT.dbo.[FinalClaimsDetailCode] AS TARGET
USING (

SELECT [RecordID]
      ,[MVDID]
      ,[ClaimNumber]
	  ,[ClaimLineNumber] -- added Luna 0715 per client's file resent
      ,[ICDVersion]
      ,[CodeType]
      ,[CodeValue]
      ,[SequenceNumber]
      ,[PresentOnAdmissionFlag]
      ,[AdmittingDiagnosisFlag]
      ,[DischargeDiagnosisFlag]
      ,[DiagnosisIndicator]
      ,[DateFrom]
      ,[DateThrough]
      ,[Amount]
      ,[CustID]
      ,[BaseBatchID]
	  ,[CurrentBatchID]
	  ,PrimaryIndicator   --Added
	  ,[PhiSensInd]
	  ,[LoadDate]
	  ,[ClientLoadDT]
  FROM [VD-RPT02].BatchImportABCBS.[dbo].[FinalClaimsDetailCode] 
  ) AS SOURCE 
ON    (	TARGET.[ClaimNumber]=SOURCE.[ClaimNumber] 
			
		) 

--WHEN MATCHED 
	      
--THEN 
--UPDATE SET 
   	  			
--		TARGET.[MVDID] = SOURCE.[MVDID]
--      , TARGET.[ICDVersion] = SOURCE.ICDVersion
--	  , TARGET.[CodeValue]=SOURCE.[CodeValue] 
--	  , TARGET.[CodeType]=SOURCE.[CodeType] 
--	  , TARGET.[SequenceNumber]=SOURCE.[SequenceNumber] 
--	  , TARGET.[ClaimLineNumber]=SOURCE.[ClaimLineNumber] 
--	  , TARGET.[PresentOnAdmissionFlag] = SOURCE.PresentOnAdmissionFlag
--      , TARGET.[AdmittingDiagnosisFlag] = SOURCE.AdmittingDiagnosisFlag
--      , TARGET.[DischargeDiagnosisFlag] = SOURCE.DischargeDiagnosisFlag
--      , TARGET.[DiagnosisIndicator] = SOURCE.DiagnosisIndicator
--      , TARGET.[DateFrom] = SOURCE.DateFrom
--      , TARGET.[DateThrough] = SOURCE.DateThrough
--      , TARGET.[Amount] = SOURCE.Amount
--	  , TARGET.[CurrentBatchID]= SOURCE.[CurrentBatchID]
--	  , TARGET.PrimaryIndicator= SOURCE.PrimaryIndicator
--	  , TARGET.[PhiSensInd]= SOURCE.[PhiSensInd]
--	  , TARGET.[LoadDate]= SOURCE.[LoadDate]
--	  , TARGET.[ClientLoadDT]= SOURCE.[ClientLoadDT]

WHEN NOT MATCHED BY TARGET THEN 
	INSERT(	
		[MVDID]
      ,[ClaimNumber]
	  ,[ClaimLineNumber] --added 0715 luna per client's file resend
      ,[ICDVersion]
      ,[CodeType]
      ,[CodeValue]
      ,[SequenceNumber]
      ,[PresentOnAdmissionFlag]
      ,[AdmittingDiagnosisFlag]
      ,[DischargeDiagnosisFlag]
      ,[DiagnosisIndicator]
      ,[DateFrom]
      ,[DateThrough]
      ,[Amount]
      ,[CustID]
      ,[BaseBatchID]
	  ,[CurrentBatchID]
	  ,PrimaryIndicator--Added
	  ,[PhiSensInd]
	  ,[LoadDate]
	  ,[ClientLoadDT]
	  )
     VALUES           
	 ( Source.[MVDID]
      ,Source.[ClaimNumber]
	  ,Source.[ClaimLineNumber] --added 0715 luna per client's file resend
      ,Source.[ICDVersion]
      ,Source.[CodeType]
      ,Source.[CodeValue]
      ,Source.[SequenceNumber]
      ,Source.[PresentOnAdmissionFlag]
      ,Source.[AdmittingDiagnosisFlag]
      ,Source.[DischargeDiagnosisFlag]
      ,Source.[DiagnosisIndicator]
      ,Source.[DateFrom]
      ,Source.[DateThrough]
      ,Source.[Amount]
      ,Source.[CustID]
      ,Source.[BaseBatchID]
	  ,Source.[CurrentBatchID]
	  ,Source.PrimaryIndicator--Added
	  ,Source.[PhiSensInd]
	  ,Source.[LoadDate]
	  ,Source.[ClientLoadDT]);

	if @@ERROR>0 
	rollback transaction ClaimsDetailCode
	else
	Commit transaction ClaimsDetailCode

END 


END 