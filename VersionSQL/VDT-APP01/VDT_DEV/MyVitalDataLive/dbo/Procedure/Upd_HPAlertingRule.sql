/****** Object:  Procedure [dbo].[Upd_HPAlertingRule]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/01/2008
-- Description:	 Updates an instance of AlertingRule
-- =============================================
CREATE PROCEDURE [dbo].[Upd_HPAlertingRule]
	@ID int,
	@Name varchar(50),
	@Description varchar(500),
	@CustomerId int,
	@DiseaseList varchar(max) = null,
	@FacilityList  varchar(max) = null,
	@HealthPlanTypeList varchar(max) = null,
	@HealthPlanList varchar(max) = null,
	@EmployerList varchar(max) = null,
	@AgentList varchar(max) = null,
	@CountyList varchar(max) = null,
	@AlertGroup varchar(max),
	@ChiefComplaintList varchar(max) = null,
	@CopcList varchar(max) = null,
	@DMList varchar(max) = null,
	@DiagnosisList varchar(max) = null,
	@inCM int,
	@inNarcoticLockdown int,
	@Active bit,
	@AnyFacility bit,
	@AnyDisease bit,
	@AnyEmployer bit,
	@AnyHealthPlan bit,
	@AnyHealthPlanType bit,
	@AnyCounty bit,
	@AnyChiefComplaint bit,
	@AnyDM bit,
	@AnyDiagnosis bit,
	@AnyCOPC bit = 0,
	@DiagnosisAllOther bit,
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;

	declare @tempId varchar(50)

	-- holds the result of values split from the input strings
	create table #temp (data varchar(50), isProcessed bit default(0))

	if not exists(select Name from HPAlertRule where Name = @Name and Cust_Id = @CustomerId and Rule_ID <> @ID)
	begin
		-- update record in main rule table
		update dbo.HPAlertRule set
			Cust_Id = @CustomerId,
			Name = @Name,
			Description = @Description,
			Active = @Active,
			AnyFacility = @AnyFacility,
			AnyDisease = @AnyDisease,
			AnyEmployer = @AnyEmployer,
			AnyHealthPlan = @AnyHealthPlan,
			AnyHealthPlanType = @AnyHealthPlanType,
			AnyCounty = @AnyCounty,
			AnyChiefComplaint = @AnyChiefComplaint,
			AnyDiseaseManagement = @AnyDM,
			AnyDiagnosis = @AnyDiagnosis,
			AnyCOPC = @AnyCOPC,
			AllOtherDiagnosis = @DiagnosisAllOther,
			InCaseManagement = @InCM,
			InNarcoticLockdown = @InNarcoticLockdown
		where Rule_ID = @Id

		-- insert records into tables related to the rule
		-- clear all related records first and insert the new set of relations
		-- DISEASE
		delete from Link_HPRuleDisease where Rule_Id = @Id
		if(len(isnull(@DiseaseList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@DiseaseList,',')

			-- insert records into Rule_Disease relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleDisease (Rule_ID, Disease_ID)
					values (@ID, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- FACILITY
		delete from Link_HPRuleFacility where Rule_Id = @Id
		if(len(isnull(@FacilityList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@FacilityList,',')

			-- insert records into Rule_Facility relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleFacility (Rule_ID, Facility_ID)
					values (@ID, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- HEALTH PLAN TYPE
		delete from Link_HPRuleHealthPlanType where Rule_Id = @Id
		if(len(isnull(@HealthPlanTypeList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@HealthPlanTypeList,',')

			-- insert records into Rule_HealthPlanType relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleHealthPlanType (Rule_ID, HealthPlanType_ID)
					values (@ID, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- HEALTH PLAN
		delete from Link_HPRuleHealthPlan where Rule_Id = @Id
		if(len(isnull(@HealthPlanList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@HealthPlanList,',')

			-- insert records into Rule_HealthPlan relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleHealthPlan (Rule_ID, HealthPlan_ID)
					values (@ID, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- EMPLOYER
		delete from Link_HPRuleEmployer where Rule_Id = @Id
		if(len(isnull(@EmployerList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@EmployerList,',')

			-- insert records into Rule_Employer relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleEmployer (Rule_ID, Employer_ID)
					values (@ID, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- AGENT
		delete from Link_HPRuleAgent where Rule_Id = @Id
		if(len(isnull(@AgentList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@AgentList,',')

			-- insert records into Rule_Agent relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleAgent (Rule_ID, Agent_ID)
					values (@ID, @tempId)

				delete from #temp where data = @tempId
			end
		end

		-- COUNTY
		delete from Link_HPRuleCounty where Rule_Id = @Id
		if(len(isnull(@CountyList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@CountyList,',')

			-- insert records into Rule_County relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleCounty (Rule_ID, County_ID)
					values (@ID, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- ALERT GROUP
		delete from Link_HPRuleAlertGroup where Rule_Id = @Id
		if(len(isnull(@AlertGroup,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@AlertGroup,',')

			-- insert records into Rule_AlertGroup relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleAlertGroup (Rule_ID, AlertGroup_ID)
					values (@ID, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- CHIEF COMPLAINT
		delete from Link_HPRuleChiefComplaint where Rule_Id = @Id
		if(len(isnull(@ChiefComplaintList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@ChiefComplaintList,',')

			-- insert records into Rule_ChiefComplaint relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleChiefComplaint (Rule_ID, ChiefComplaint_ID)
					values (@ID, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- COPC FACILITY
		delete from Link_HPRuleCopcFacility where Rule_Id = @Id
		if(len(isnull(@CopcList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@CopcList,',')

			-- insert records into Rule_CopcFacility relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleCopcFacility (Rule_ID, CopcFacility_ID)
					values (@ID, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp
		
		-- DISEASE MANAGEMENT
		delete from Link_HPRuleDiseaseManagement where Rule_Id = @Id
		if(len(isnull(@DMList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@DMList,',')

			-- insert records into Rule_DM relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleDiseaseManagement (Rule_ID, DM_ID)
					values (@ID, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- DIAGNOSIS
		delete from Link_HPRuleDiagnosis where Rule_Id = @Id
		if(len(isnull(@DiagnosisList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@DiagnosisList,',')

			-- insert records into Rule_DM relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleDiagnosis (Rule_ID, Diagnosis_ID)
					values (@ID, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		select @result = 0
	end
	else
	begin
		-- Rule name is alread used in different rule
		select @result = -1
	end
	
	drop table #temp	
END