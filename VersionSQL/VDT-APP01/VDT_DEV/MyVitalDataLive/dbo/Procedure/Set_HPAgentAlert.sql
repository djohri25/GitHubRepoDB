/****** Object:  Procedure [dbo].[Set_HPAgentAlert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/7/2008
-- Description:	Creates alerts for all agents who needs to be
--		notified about MVD member record access.
--		Record access data are provided as an input.
--		To find the list of notified agents check direct agent
--		assignment and alerting rules for this customer
-- =============================================
CREATE PROCEDURE [dbo].[Set_HPAgentAlert]
	@RecordAccessId int,
	@MVDId varchar(20),
	@MemberFName varchar(50),
	@MemberLName varchar(50),
	@DateTime datetime,
	@FacilityID int,
	@CustomerIDList varchar(100), -- in case same MVD Member is mapped to different Health Plan
											-- records in different customers
	@ChiefComplaint varchar(100),
	@EMSNote varchar(1000),
	
	@Discharge_disposition varchar(100) = null,
	@DischargeRecordType varchar(50) = null,	-- "Dal Emergency", or "Dal First Care"
	@SourceName varchar(50) = null
AS
BEGIN
	SET NOCOUNT ON;

	declare @curCust int,
		@CurCustName varchar(50),
		@InsMemberId varchar(20),	-- Insurance member ID corresponding to MVDId
		@CurAgent varchar(50),
		@CurAgentCustId int,
		@CurFacility varchar(50),
		@AgentDB varchar(20),		-- Name of the database where the Agents Info is stored
		@IsContactBySMS bit,
		@IsContactByEmail bit,
		@AgentPhone varchar(50),
		@AgentEmail varchar(50),
		@query varchar(1000),
		@SMSText varchar(300),
		@AlertText varchar(1000),
		@AlertStatusID int,
		@ContactTypeEmployerID int,	-- ID of the item 'Employer' as contact type in lookup table
		-- Alert Rule related
		@CurRuleID smallint,
		@CurRuleCustId int,
		@CurRuleName varchar(50),
		@AnyFacility bit,
		@AnyDisease bit,
		@AnyEmployer bit,
		@AnyHealthPlan bit,
		@AnyHealthPlanType bit,
		@AnyChiefComplaint bit,
		@AnyDiseaseManagement bit,
		@AnyDiagnosis bit,
		@AnyCOPC bit,
		@NotifyRuleAgents bit,
		@RuleInCaseManagement int,
		@RuleNarcoticLockdown int,
		@InCaseManagement bit,
		@NarcoticLockdown bit

	select @AgentDB = dbo.get_supportDBName()

--	select
--		@RecordAccessId = 100,
--		@MVDId = 'AS011341',
--		@MemberFName = 'Autum',
--		@MemberLName = 'Storms',
--		@DateTime = '2010-01-27 08:46:01.310',
--		@FacilityID = 2,
--		@CustomerIDList = '5'

	if @SourceName = 'Discharge Data'
	begin
		declare @facilityName varchar(50)
		
		select @facilityName = Name 
		from MainEMSHospital where ID = @FacilityID
		
		-- Check if alert wasn't previously triggered by MVD Lookups
		if exists(select a.ID from HPAlert a
			inner join Link_MemberId_MVD_Ins li on a.MemberID = li.InsMemberId
			where li.MVDId = @MVDId and 
				CONVERT(varchar,AlertDate,101) = CONVERT(varchar,@DateTime,101)
				and a.Facility = @facilityName)
		begin
			RETURN
		end
	end

	create table #tempCust (id int, isProcessed bit default(0))		-- holds list of customer IDs
	create table #tempAgent			-- holds list of agents who needs to be notified
	(
		id varchar(50),
		IsContactBySMS bit,
		IsContactByEmail bit,
		Phone varchar(50),
		Email varchar(50),
		Cust_id int,
		AlertTriggerType varchar(50),	-- e.g. Individual, Group
		AlertTriggerName varchar(50)	-- e.g. Rule ID
	)						
	
	CREATE TABLE #tempAlertRule
	(
		Rule_ID smallint,
		Cust_id int,
		Name varchar(50),
		AnyFacility bit,
		AnyDisease bit,
		AnyEmployer bit,
		AnyHealthPlan bit,
		AnyHealthPlanType bit,
		AnyChiefComplaint bit,
		AnyDiseaseManagement bit,
		AnyDiagnosis bit,
		AnyCOPC bit,
		NarcoticLockdown int,
		InCaseManagement int
	)

	create table #tempAlertedAgents (id varchar(50))

	declare @tempAlertedGroups table (id varchar(50))

	insert into #tempCust (id)
	select data from dbo.split(@CustomerIDList,',')

	-- Get facility name where the record was accessed
	select @CurFacility = Name from MainEMSHospital where ID = @FacilityID
	if(@CurFacility is null)
	begin
		set @CurFacility = 'Unknown Facility'
	end
	
	-- Get ID of a contact type 'Employer'
	select @ContactTypeEmployerID = CareTypeID 
	from LookupCareTypeID 
	where CareTypeName = 'Employer'

	-- 11/9/2009 time is already in EST
	-- convert access time to Eastern Standard			
	--select @DateTime = dbo.ConvertUTCtoEST(@DateTime)

	while exists(select id from #tempCust)
	begin
		select top 1 @curCust = id from #tempCust		

		-- Get customer name
		select @CurCustName = Name from HPCustomer where Cust_ID = @curCust

		-- Set alert status
		select @AlertStatusID = dbo.Get_AlertStatus(@DischargeRecordType,@curCust, @DateTime, @SourceName, @FacilityID)
		
		/*if(@DischargeRecordType is not null AND @DischargeRecordType = 'DAL EMERGENCY')
		begin
			select @AlertStatusID = ID from LookupHPAlertStatus where Name = 'Outreach not attempted'
		end
		else
		begin
			set @AlertStatusID = 0     
		end*/

		-- Get insurance member Id
		select @InsMemberId = InsMemberId  
		from Link_MVDID_CustID 
		where MVDId = @MVDId and Cust_Id = @curCust		

		if(@CurCustName = 'Health Plan of Michigan')
		begin
			declare @NPI varchar(10)
			select @NPI = NPI from mainEmsHospital where ID = @FacilityID
			-- TODO: if not found search LookupNPI table on 240

			-- Use HPM Web Service to send Alerts
			EXEC Set_OutgoingHPMAgentAlert
				@RecordAccessID = @RecordAccessId,
				@CustomerID = @curCust,
				@RecipientEmail = @AgentEmail,
				@InsMemberId = @InsMemberId,
				@MemberFName = @MemberFName,
				@MemberLName = @MemberLName,
				@Date = @DateTime,
				@NPI = @NPI,
				@Facility = @CurFacility,
				@ChiefComplaint = @ChiefComplaint,
				@EMSNote = @EMSNote

			-- Create alert record on Default HPM Agent account. 
			-- HPM doesn't have agents in our system. The alert is sent using
			-- webservice and processed on their end.
			-- For reporting purposes create default agent and assign
			-- all alerts to him.

			declare @defaultAgentID varchar(50)
			
			set @query = 'select Userid 
				from ' + @AgentDB + '.dbo.aspnet_Membership
				where CustomerId = ''' + convert(varchar,@curCust,20) + ''' AND firstname = ''Agent'' AND lastName = ''Default'''

			insert into #tempAgent (id)
				EXEC (@query)
			
			if exists( select id from #tempAgent)
			begin
				select top 1 @defaultAgentID = id from #tempAgent
				set @Alerttext = isnull(@MemberFName + ' ','') + isnull(@MemberLName,'') + ' (ID:' + @InsMemberId + ')' +
						' record was accessed by ' + @CurFacility + ' on ' + convert(varchar(30), @DateTime) + ' UTC. ';

				insert into HPAlert (AgentID,AlertDate,Facility,Customer,Text,MemberID,StatusID,RecordAccessID,TriggerType,TriggerID, RecipientType, RecipientCustID, ChiefComplaint, EMSNote, DischargeDisposition, sourceName, MVDID)
				values(@defaultAgentID,@DateTime,@CurFacility,@CurCustName,@Alerttext,@InsMemberId,@AlertStatusID,@RecordAccessID,'Individual',null,'Individual', @curCust, @ChiefComplaint,@EMSNote, @Discharge_disposition, @sourceName, @MVDId)
			end

			delete from #tempAgent
		end
		else
		begin

			-- Set Alert text
			set @Alerttext = isnull(@MemberFName + ' ','') + isnull(@MemberLName,'') + ' (ID:' + @InsMemberId + ')' +
				' record was accessed by ' + @CurFacility + ' on ' + convert(varchar(30), @DateTime) + ' UTC. ';									
			-- Add chief complaint and admission notes if exists
			if( len(isnull(@ChiefComplaint,'')) > 0)
			begin
				set @Alerttext = @Alerttext + ' Chief complaint: ' + @ChiefComplaint + '.'
			end
			if( len(isnull(@EMSNote,'')) > 0)
			begin
				set @Alerttext = @Alerttext + ' Admission notes: ' + @EMSNote + '.'
			end
			set @Alerttext = @Alerttext + ' ' 
			-----------

			-- Set SMS text
			set @SMSText = isnull(LEFT(@MemberFName,10) + ' ','') + isnull(LEFT(@MemberLName,20),'') + ' (ID:' + @InsMemberId + ')' +
				' record was accessed by ' + LEFT(@CurFacility,25) + ' on ' + convert(varchar(30), @DateTime) + ' UTC. ' + 
				' ' 
			-----------

			-- Direct mapping takes priority over rules
			if exists( select agent_id from dbo.Link_HPMember_Agent where Member_id=@InsMemberId and Cust_Id = @curCust)
			begin
				-- Get list of agents mapped to that user
				set @query = 'select Agent_Id, ''' + 'Individual' + ''', b.CustomerId  
					from Link_HPMember_Agent a inner join ' + @AgentDB + '.dbo.aspnet_Membership b on a.Agent_Id = b.UserId
					where Member_Id = ''' + @InsMemberId + ''' and b.Active = ''true'''

				insert into #tempAgent (id,alertTriggerType,cust_id)
					EXEC (@query)

				-- Send email or/and SMS to each agent according to the agent preference
				while exists( select id from #tempAgent)
				begin
					select top 1 @CurAgent = id, 
						@CurAgentCustId = cust_id
					from #tempAgent

					-- TODO: If database name can be hardcoded, retrieve data in one query
					set @query = 'update #tempAgent set 
						IsContactBySMS = (select top 1 ContactBySMS from ' + @AgentDB + '.dbo.aspnet_Membership where Userid = ''' + @CurAgent + ''')' +
						', IsContactByEmail = (select top 1 ContactByEmail from ' + @AgentDB + '.dbo.aspnet_Membership where Userid = ''' + @CurAgent + ''')' +
						', Phone = (select top 1 Phone from ' + @AgentDB + '.dbo.aspnet_Membership where Userid = ''' + @CurAgent + ''')' +
						', Email = (select top 1 Email from ' + @AgentDB + '.dbo.aspnet_Membership where Userid = ''' + @CurAgent + ''')' +
						' where id = ''' + @CurAgent + ''''

					EXEC (@query)		

					select @IsContactBySMS = IsContactBySMS,
						@IsContactByEmail = IsContactByEmail,
						@AgentPhone = Phone,
						@AgentEmail = Email
					from #tempAgent
					where id = @CurAgent

					--select @IsContactBySMS as '@IsContactBySMS',@IsContactByEmail as '@IsContactByEmail',@AgentPhone as '@AgentPhone',@AgentEmail as '@AgentEmail'	
		
					--if(@IsContactByEmail = 1 and len(isnull(@AgentEmail,'')) > 0)
					--begin
						-- Send email

						--select 'sending email to ' + @AgentEmail,@AgentEmail,@InsMemberId,@MemberFName,@MemberLName,@DateTime,@CurFacility

						--EXEC SendMailToHPAgent
						--	@RecordAccessID = @RecordAccessId,
						--	@CustomerID = @curCust,
						--	@RecipientEmail = @AgentEmail,
						--	@InsMemberId = @InsMemberId,
						--	@MemberFName = @MemberFName,
						--	@MemberLName = @MemberLName,
						--	@Date = @DateTime,
						--	@NPI = '',
						--	@Facility = @CurFacility,
						--	@ChiefComplaint = @ChiefComplaint,
						--	@EMSNote = @EMSNote,
						--	@TriggerType = 'Individual',
						--	@TriggerName = ''
					--end

					if(@IsContactBySMS = 1 and len(isnull(@AgentPhone,'')) > 0)
					begin
						-- Send SMS
						-- Insert into outgoing SMS table
						INSERT INTO SendSMS
							(RecordAccessID,Phone,Text)
						values
						(@RecordAccessId, @AgentPhone, @SMSText)
					end

					-- Create alert record on Agent account
					insert into HPAlert (AgentID,AlertDate,Facility,Customer,Text,MemberID,StatusID,RecordAccessID,TriggerType,TriggerID, RecipientType, RecipientCustID, ChiefComplaint,EMSNote, DischargeDisposition, sourceName, MVDID)
					values(@CurAgent,@DateTime,@CurFacility,@CurCustName,@Alerttext,@InsMemberId,@AlertStatusID,@RecordAccessID,'Individual',null,'Individual',@CurAgentCustId,@ChiefComplaint,@EMSNote, @Discharge_disposition, @sourceName, @MVDId)

					delete from #tempAgent where id = @CurAgent
				end

				delete from #tempAgent
			end
			else
			begin
				--select 'CHECKING RULES'
				-- Check if the member matches any of the Alert Rules. If yes, notify agents
				-- associated with that rule

				-- Get the customer rules
				-- for current customer and it's subcustomers
				insert into #tempAlertRule
					(Rule_ID,Cust_id,Name,AnyFacility,AnyDisease,AnyEmployer,AnyHealthPlan,AnyHealthPlanType,
						AnyChiefComplaint,AnyDiseaseManagement,AnyDiagnosis,NarcoticLockdown,InCaseManagement,AnyCOPC)
				select Rule_ID,Cust_ID,Name,AnyFacility,AnyDisease,AnyEmployer,AnyHealthPlan,AnyHealthPlanType,
					AnyChiefComplaint,AnyDiseaseManagement,AnyDiagnosis,isnull(InNarcoticLockdown,-1),
					isnull(InCaseManagement,-1),isnull(AnyCOPC,1)
				from HPAlertRule 
				where Active = 1 and 
					isNoteAlertRule = 0 and
					(Cust_ID = @curCust OR
						Cust_ID in
						(select Cust_ID from hpcustomer where ParentId = @curCust)							
					)

				select @InCaseManagement = isnull(InCaseManagement,0),
					@NarcoticLockdown = isnull(NarcoticLockdown,0)
				from MainPersonalDetails
				where icenumber = @MVDId
						
				while exists (select Rule_Id from #tempAlertRule)
				begin
					select top 1 @CurRuleID = Rule_ID, 
						@CurRuleName = Name,
						@CurRuleCustId = cust_id,
						@AnyFacility = AnyFacility,
						@AnyDisease = AnyDisease,
						@AnyEmployer = AnyEmployer,
						@AnyHealthPlan = AnyHealthPlan,
						@AnyHealthPlanType = AnyHealthPlanType,
						@AnyChiefComplaint = AnyChiefComplaint,
						@AnyDiseaseManagement = AnyDiseaseManagement,
						@AnyDiagnosis = AnyDiagnosis,
						@RuleNarcoticLockdown = NarcoticLockdown,
						@RuleInCaseManagement = InCaseManagement,
						@AnyCOPC = AnyCOPC
					from #tempAlertRule

					--select @CurRuleID as '@CurRuleID',@AnyFacility ,@AnyDisease,@AnyEmployer,@AnyHealthPlan,@AnyHealthPlanType
					
					-- If some of the rule criteria are not satisfied set to 0
					set @NotifyRuleAgents = 1

					-- Check narcotic lockdown
					if(@RuleNarcoticLockdown <> -1)
					begin
						if((@RuleNarcoticLockdown = 1 AND @NarcoticLockdown = 0)
							OR (@RuleNarcoticLockdown = 0 AND @NarcoticLockdown = 1))
						begin
							set @NotifyRuleAgents = 0
						end
					end

					-- Check In case management
					if(@NotifyRuleAgents = 1 and @RuleInCaseManagement <> -1)
					begin
						if((@RuleInCaseManagement = 1 AND @InCaseManagement = 0)
							OR (@RuleInCaseManagement = 0 AND @InCaseManagement = 1))
						begin
							set @NotifyRuleAgents = 0
						end
					end

					-- Check FACILITY criteria
					if(@NotifyRuleAgents = 1 and @AnyFacility = 0)
					begin
						-- check if current Facility was selected in the rule
						if exists (select rule_id from Link_HPRuleFacility where rule_id = @CurRuleID)						 
							and not exists (select rule_id from Link_HPRuleFacility where rule_id = @CurRuleID and Facility_Id = @FacilityID)
						begin
							set @NotifyRuleAgents = 0
						end
					end

--					select @NotifyRuleAgents as '@NotifyRuleAgents after facility'

					-- Check DISEASE criteria
					if( @NotifyRuleAgents = 1 and @AnyDisease = 0)
					begin
						-- check if the member has disease specified in the rule criteria

						-- If none of the items were specified in the rule then skip that criteria
						if exists ( select Rule_Id from Link_HPRuleDisease where Rule_Id = @CurRuleID)
						begin
							-- TODO: optimize these 3 joins by selecting 2 smallest tables and 
							--	and joining the result of that join with the other table
							if not exists (select a.Rule_Id 
								from Link_HPRuleDisease a
									inner join Link_Disease_Code b on a.Disease_ID = b.DiseaseId
									inner join MainCondition c on b.CodeFirst3 = c.CodeFirst3							
								where a.Rule_ID = @CurRuleID and c.ICENUMBER = @MVDId)
							begin
								set @NotifyRuleAgents = 0
							end
						end
					end

--					select @NotifyRuleAgents as '@NotifyRuleAgents after disease'

					-- Check EMPLOYER criteria
					if( @NotifyRuleAgents = 1 and @AnyEmployer = 0)
					begin
						-- check if the member has employer specified in the rule criteria
						-- TODO: optimize these 3 joins by selecting 2 smallest tables and 
						--	and joining the result of that join with the other table
						
						-- If none of the items were specified in the rule then skip that criteria
						if exists ( select Rule_Id from Link_HPRuleEmployer where Rule_Id = @CurRuleID)
						begin
							if not exists (select c.name from hpalertrule a
								inner join Link_HPRuleEmployer b on a.rule_id = b.rule_id
								inner join HPEmployer c on b.employer_id = c.employer_id
								where a.rule_id = @CurRuleID and c.name in
								(
									select isnull(FirstName + ' ','') + isnull(LastName,'') 
									from maincareinfo
									where icenumber = @MVDId and CareTypeID = @ContactTypeEmployerID
								)
							)
							begin
								set @NotifyRuleAgents = 0
							end
						end
					end

--					select @NotifyRuleAgents as '@NotifyRuleAgents after EMPLOYER'

					-- Check HEALTH PLAN criteria
					if( @NotifyRuleAgents = 1 and @AnyHealthPlan = 0)
					begin
						-- check if the member has health plan (in insurance section), specified in the rule criteria
						-- TODO: optimize these 3 joins by selecting 2 smallest tables and 
						--	and joining the result of that join with the other table
						
						-- If none of the items were specified in the rule then skip that criteria
						if exists ( select Rule_Id from Link_HPRuleHealthPlan where Rule_Id = @CurRuleID)
						begin
							if not exists (select c.name from hpalertrule a
								inner join Link_HPRuleHealthPlan b on a.rule_id = b.rule_id
								inner join HPHealthPlan c on b.HealthPlan_id = c.HealthPlan_id
								where a.rule_id = @CurRuleID and c.name in
								(
									select name from dbo.MainInsurance 
									where icenumber = @MVDId
								)
							)
							begin
								set @NotifyRuleAgents = 0
							end
						end
					end

--					select @NotifyRuleAgents as '@NotifyRuleAgents after HEALTH PLAN'

					-- Check DISEASE MANAGEMENT criteria
					if( @NotifyRuleAgents = 1 and @AnyDiseaseManagement = 0)
					begin
						-- If none of the items were specified in the rule then skip that criteria
						if exists ( select Rule_Id from Link_HPRuleDiseaseManagement where Rule_Id = @CurRuleID)
						begin
							if not exists (select a.Rule_Id 
								from Link_HPRuleDiseaseManagement a
								inner join dbo.MainDiseaseManagement d on a.DM_ID = d.DM_ID
								where a.Rule_ID = @CurRuleID and d.ICENUMBER = @MVDId)
							begin
								set @NotifyRuleAgents = 0
							end
						end
					end

--					select @NotifyRuleAgents as '@NotifyRuleAgents after DISEASE MANAGEMENT'

					-- Check CHIEF COMPLAINT criteria
					if( @NotifyRuleAgents = 1 and @AnyChiefComplaint = 0)
					begin
						-- If none of the items were specified in the rule then skip that criteria
						if exists ( select Rule_Id from dbo.Link_HPRuleChiefComplaint where Rule_Id = @CurRuleID)
						begin
							if not exists (select a.Rule_Id 
								from Link_HPRuleChiefComplaint a
								inner join dbo.LookupChiefComplaint c on a.ChiefComplaint_ID = c.ID
								where a.Rule_ID = @CurRuleID and c.name = @chiefComplaint)
							begin
								set @NotifyRuleAgents = 0
							end
						end
					end

--					select @NotifyRuleAgents as '@NotifyRuleAgents after CHIEF COMPLAINT'

					-- Check DIAGNOSIS criteria
					if( @NotifyRuleAgents = 1 and @AnyDiagnosis = 0)
					begin
						if dbo.Get_AlertDiagnosisMatch(@CurRuleID,@MVDId) = 0
						begin
							set @NotifyRuleAgents = 0
						end
					end

					-- Check COPC criteria - TODO
					--if( @NotifyRuleAgents = 1 and @AnyCOPC = 0)
					--begin
					--		--if not exists (select a.Rule_Id 
					--		--	from Link_HPRuleChiefComplaint a
					--		--	inner join dbo.LookupChiefComplaint c on a.ChiefComplaint_ID = c.ID
					--		--	where a.Rule_ID = @CurRuleID and c.name = @chiefComplaint)
					--		--begin
					--		--	set @NotifyRuleAgents = 0
					--		--end
					--end
					
					if( @NotifyRuleAgents = 1)
					begin
						-- TODO don't depend on rule name
						if(@CurRuleName like '%COPC%')
						begin
							-- Member must have PCP with NPI belonging to COPC group
							if not exists
							(	select top 1 ICENUMBER
								from MainSpecialist 
								where ICENUMBER = @MVDId
									and RoleID = 1
									and NPI is not null
									and NPI in (select c.NPI from COPC_NPI c where Cust_ID = @curCust)
							)
							begin
								set @NotifyRuleAgents = 0
							end
						end
					end
					
--					select @NotifyRuleAgents as '@NotifyRuleAgents after DIAGNOSIS'

					if(@NotifyRuleAgents = 1)
					begin
						-- Groups assigned to rules
						if exists( select Rule_ID from dbo.Link_HPRuleAlertGroup where Rule_ID = @CurRuleID)
						begin														

							-- Create alert record for each group assiociated with the rule, unless the alert was already
							-- created as a result of different rule							
							insert into HPAlert (AgentID,AlertDate,Facility,Customer,Text,MemberID,StatusID,RecordAccessID,TriggerType,TriggerID,RecipientType,RecipientCustID,ChiefComplaint,EMSNote, DischargeDisposition, sourceName, MVDID)
							select AlertGroup_ID,@DateTime,@CurFacility,@CurCustName,@Alerttext,@InsMemberId,@AlertStatusID,@RecordAccessID,'Rule',@CurRuleID, 'Group',@CurRuleCustId, @ChiefComplaint,@EMSNote,@Discharge_disposition,@sourceName, @MVDId
							from dbo.Link_HPRuleAlertGroup
							where Rule_ID = @CurRuleID
								and alertGroup_ID not in(
									select id from @tempAlertedGroups
								)

							insert into @tempAlertedGroups(id)
							select AlertGroup_ID
							from dbo.Link_HPRuleAlertGroup
							where Rule_ID = @CurRuleID
								and alertGroup_ID not in(
									select id from @tempAlertedGroups
								)
						end

						if exists( select Rule_ID from Link_HPRuleAgent where Rule_ID = @CurRuleID)
						begin
							-- Agents assigned to rules

							-- Get list of agents associated with that rule
							set @query = '
							select Agent_Id 
							from Link_HPRuleAgent a inner join ' + @AgentDB + '.dbo.aspnet_Membership b on a.Agent_Id = b.UserId
							where Rule_ID = ''' + convert(varchar,@CurRuleID,10) + ''' and b.Active = ''true'''

							insert into #tempAgent (id)
								EXEC (@query)

							-- Remove agents who are members of group which was already processed (alerted)
							delete from #tempAgent
							where id in(
								select Agent_ID from dbo.Link_HPAlertGroupAgent
								where Group_ID in (
										select id from @tempAlertedGroups
									)
							)

							-- Send email or/and SMS to each agent according to the agent preference
							while exists( select id from #tempAgent)
							begin
								select top 1 @CurAgent = id from #tempAgent

								--select @CurAgent as '@CurAgent'

								-- TODO: If database name can be hardcoded, retrieve data in one query
								set @query = 'update #tempAgent set 
									IsContactBySMS = (select top 1 ContactBySMS from ' + @AgentDB + '.dbo.aspnet_Membership where Userid = ''' + @CurAgent + ''')' +
									', IsContactByEmail = (select top 1 ContactByEmail from ' + @AgentDB + '.dbo.aspnet_Membership where Userid = ''' + @CurAgent + ''')' +
									', Phone = (select top 1 Phone from ' + @AgentDB + '.dbo.aspnet_Membership where Userid = ''' + @CurAgent + ''')' +
									', Email = (select top 1 Email from ' + @AgentDB + '.dbo.aspnet_Membership where Userid = ''' + @CurAgent + ''')' +
									' where id = ''' + @CurAgent + ''''

								--select @query
								EXEC (@query)
						

								select @IsContactBySMS = IsContactBySMS,
									@IsContactByEmail = IsContactByEmail,
									@AgentPhone = Phone,
									@AgentEmail = Email
								from #tempAgent
								where id = @CurAgent
					
								-- Notify only if the notification wasn't already sent as a result of different rule
								if not exists (select id from #tempAlertedAgents where id = @CurAgent)
								begin
									--if(@IsContactByEmail = 1 and len(isnull(@AgentEmail,'')) > 0)
									--begin
										-- Send email

										--select 'sending email to ' + @AgentEmail,@AgentEmail,@InsMemberId,@MemberFName,@MemberLName,@DateTime,@CurFacility as 'Facility'

										--EXEC SendMailToHPAgent
										--	@RecordAccessID = @RecordAccessId,
										--	@CustomerID = @curCust,
										--	@RecipientEmail = @AgentEmail,
										--	@InsMemberId = @InsMemberId,
										--	@MemberFName = @MemberFName,
										--	@MemberLName = @MemberLName,
										--	@Date = @DateTime,
										--	@NPI = '',
										--	@Facility = @CurFacility,
										--	@ChiefComplaint = @ChiefComplaint,
										--	@EMSNote = @EMSNote,
										--	@TriggerType = 'Rule',
										--	@TriggerName = @CurRuleName
									--end

									if(@IsContactBySMS = 1 and len(isnull(@AgentPhone,'')) > 0)
									begin
										-- Send SMS
										-- Insert into outgoing SMS table
										INSERT INTO SendSMS (RecordAccessID,Phone,Text)
										values (@RecordAccessId, @AgentPhone,@SMSText)
									end

									-- Record that the agent was notified, so duplicate email/sms
									-- won't be sent when processing another rule
									if((@IsContactByEmail = 1 and len(isnull(@AgentEmail,'')) > 0)
										or (@IsContactBySMS = 1 and len(isnull(@AgentPhone,'')) > 0) )
									begin
										insert into #tempAlertedAgents (id)
											select @CurAgent
									end

									-- Create alert record on Agent account
									insert into HPAlert (AgentID,AlertDate,Facility,Customer,Text,MemberID,StatusID,RecordAccessID,TriggerType,TriggerID,RecipientType,RecipientCustID,ChiefComplaint,EMSNote,DischargeDisposition,sourceName, MVDID)
									values(@CurAgent,@DateTime,@CurFacility,@CurCustName,@Alerttext,@InsMemberId,@AlertStatusID,@RecordAccessID,'Rule',@CurRuleID,'Individual',@CurRuleCustId,@ChiefComplaint,@EMSNote,@Discharge_disposition,@sourceName, @MVDId)
								end
								
								delete from #tempAgent where id = @CurAgent
							end

							delete from #tempAgent
						end

					end

					delete from #tempAlertRule where Rule_ID = @CurRuleID
				end

			end
		end

		-- cleared notified agents before the next iteration
		delete from #tempAlertedAgents

		delete from #tempCust where id = @curCust
	end	

	drop table #tempCust
	drop table #tempAgent
	drop table #tempAlertRule	
	drop table #tempAlertedAgents
END