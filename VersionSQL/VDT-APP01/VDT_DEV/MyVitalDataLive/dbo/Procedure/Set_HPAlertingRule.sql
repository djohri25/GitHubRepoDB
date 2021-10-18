/****** Object:  Procedure [dbo].[Set_HPAlertingRule]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/01/2008
-- Description:	 Creates an instance of AlertingRule
--		@DiseaseList, @FacilityList etc - are the lists of comma separated items
-- =============================================
CREATE PROCEDURE [dbo].[Set_HPAlertingRule]
	@Name varchar(50),
	@Description varchar(500),
	@CustomerId int,
	@DiseaseList varchar(max) = null,
	@FacilityList  varchar(max) = null,
	@HealthPlanTypeList varchar(max) = null,
	@HealthPlanList varchar(max) = null,
	@EmployerList varchar(max) = null,
	@AgentList varchar(max),
	@CountyList varchar(max) = null,
	@AlertGroup varchar(max),
	@ChiefComplaintList varchar(max) = null,
	@CopcList varchar(max),	
	@DMList varchar(max),
	@DiagnosisList varchar(max),
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
	@IsNoteAlertRule bit = 0,
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;

	declare @ruleId int, @tempId varchar(50)

	-- holds the result of values split from the input strings
	create table #temp (data varchar(50), isProcessed bit default(0))

	if not exists(select Name from HPAlertRule where Name = @Name and Cust_Id = @CustomerId)
	begin
		-- create record in main rule table
		insert into dbo.HPAlertRule (Cust_Id,Name,Description,Active,AnyFacility,AnyDisease,
			AnyEmployer,AnyHealthPlan,AnyHealthPlanType,AnyCounty,AnyChiefComplaint,AnyDiseaseManagement,AnyDiagnosis,AllOtherDiagnosis,
			InCaseManagement,InNarcoticLockdown,AnyCOPC,IsNoteAlertRule)
		values(@CustomerId, @Name, @Description, @Active, @AnyFacility,@AnyDisease,
			@AnyEmployer,@AnyHealthPlan,@AnyHealthPlanType,@AnyCounty,@AnyChiefComplaint,@AnyDM,@AnyDiagnosis,@DiagnosisAllOther,
			@InCM,@InNarcoticLockdown,@AnyCOPC,@IsNoteAlertRule)

		-- get autogenerated ID for the rule
		select @ruleId = @@IDENTITY

		-- insert records into tables related to the rule
		-- DISEASE
		if(len(isnull(@DiseaseList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@DiseaseList,',')

			-- insert records into Rule_Disease relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleDisease (Rule_ID, Disease_ID)
					values (@ruleId, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- FACILITY
		if(len(isnull(@FacilityList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@FacilityList,',')

			-- insert records into Rule_Facility relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleFacility (Rule_ID, Facility_ID)
					values (@ruleId, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- HEALTH PLAN TYPE
		if(len(isnull(@HealthPlanTypeList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@HealthPlanTypeList,',')

			-- insert records into Rule_HealthPlanType relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleHealthPlanType (Rule_ID, HealthPlanType_ID)
					values (@ruleId, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- HEALTH PLAN
		if(len(isnull(@HealthPlanList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@HealthPlanList,',')

			-- insert records into Rule_HealthPlan relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleHealthPlan (Rule_ID, HealthPlan_ID)
					values (@ruleId, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- EMPLOYER
		if(len(isnull(@EmployerList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@EmployerList,',')

			-- insert records into Rule_Employer relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleEmployer (Rule_ID, Employer_ID)
					values (@ruleId, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- AGENT
		if(len(isnull(@AgentList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@AgentList,',')

			-- insert records into Rule_Agent relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleAgent (Rule_ID, Agent_ID)
					values (@ruleId, @tempId)

				delete from #temp where data = @tempId
			end
		end

		-- COUNTY
		if(len(isnull(@CountyList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@CountyList,',')

			-- insert records into Rule_County relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleCounty (Rule_ID, County_ID)
					values (@ruleId, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- ALERT GROUP
		if(len(isnull(@AlertGroup,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@AlertGroup,',')

			-- insert records into Rule_AlertGroup relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into dbo.Link_HPRuleAlertGroup (Rule_ID, AlertGroup_ID)
					values (@ruleId, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- CHIEF COMPLAINT
		if(len(isnull(@ChiefComplaintList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@ChiefComplaintList,',')

			-- insert records into Rule_ChiefComplaint relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleChiefComplaint (Rule_ID, ChiefComplaint_ID)
					values (@ruleId, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- COPC FACILITY
		if(len(isnull(@CopcList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@CopcList,',')

			-- insert records into Rule_CopcFacility relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPRuleCopcFacility (Rule_ID, CopcFacility_ID)
					values (@ruleId, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp
		
		-- DISEASE MANAGEMENT
		if(len(isnull(@DMList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@DMList,',')

			-- insert records into Rule_DM relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into dbo.Link_HPRuleDiseaseManagement (Rule_ID, DM_ID)
					values (@ruleId, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		-- DIAGNOSIS
		if(len(isnull(@DiagnosisList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@DiagnosisList,',')

			-- insert records into Rule_Diagnosis relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into dbo.Link_HPRuleDiagnosis (Rule_ID, Diagnosis_ID)
					values (@ruleId, @tempId)

				delete from #temp where data = @tempId
			end
		end
		delete from #temp

		select @result = 0
	end
	else
	begin
		select @result = -1
	end
	
	drop table #temp	
END