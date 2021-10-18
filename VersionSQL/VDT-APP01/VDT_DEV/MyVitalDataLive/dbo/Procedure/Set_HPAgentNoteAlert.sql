/****** Object:  Procedure [dbo].[Set_HPAgentNoteAlert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 08/20/2013
-- Description:	Creates alerts for all agents who needs to be
--		notified about MVD member note creation.
--		To find the list of notified agents alerting rules for this customer
-- =============================================
CREATE PROCEDURE [dbo].[Set_HPAgentNoteAlert]
	@SourceRecordId int,
	@MVDId varchar(20),
	@DateTime datetime,
	@SourceName varchar(50),
	@CreatedBy varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	declare @curCustID int,
		@CurCustName varchar(50),
		@HPMemberID varchar(50),
		@CurAgent varchar(50),
		@CurAgentCustId int,
		@AgentDB varchar(20),		-- Name of the database where the Agents Info is stored
		@query varchar(1000),
		@SMSText varchar(300),
		@AlertText varchar(1000),
		@AlertStatusID int,
		@ContactTypeEmployerID int,	-- ID of the item 'Employer' as contact type in lookup table
		-- Alert Rule related
		@CurRuleID smallint,
		@CurRuleCustId int,
		@CurRuleName varchar(50),
		@AnyDiseaseManagement bit,
		@AnyDiagnosis bit,
		@AnyCOPC bit,
		@NotifyRuleAgents bit,
		@RuleInCaseManagement int,
		@InCaseManagement bit

	select @AgentDB = dbo.get_supportDBName()

--	select
--		@RecordAccessId = 100,
--		@MVDId = 'AS011341',
--		@MemberFName = 'Autum',
--		@MemberLName = 'Storms',
--		@DateTime = '2010-01-27 08:46:01.310',
--		@FacilityID = 2,
--		@CustomerIDList = '5'

	create table #tempAgent			-- holds list of agents who needs to be notified
	(
		id varchar(50),
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
		AnyDiseaseManagement bit,
		AnyDiagnosis bit,
		AnyCOPC bit,
		InCaseManagement int
	)

	create table #tempAlertedAgents (id varchar(50))

	declare @tempAlertedGroups table (id varchar(50))


	-- 11/9/2009 time is already in EST
	-- convert access time to Eastern Standard			
	--select @DateTime = dbo.ConvertUTCtoEST(@DateTime)

	select top 1 @curCustID = Cust_ID,
		@HPMemberID = InsMemberId
	from Link_MemberId_MVD_Ins
	where MVDId = @MVDId 

	-- Get customer name
	select @CurCustName = Name from HPCustomer where Cust_ID = @curCustID

	-- TODO: Set alert status
	select @AlertStatusID = 0


	--select 'CHECKING RULES'
	-- Check if the member matches any of the Alert Rules. If yes, notify agents
	-- associated with that rule

	-- Get the customer rules
	-- for current customer and it's subcustomers
	insert into #tempAlertRule
		(Rule_ID,Cust_id,Name,
		AnyDiseaseManagement,AnyDiagnosis,InCaseManagement,AnyCOPC)
	select Rule_ID,Cust_ID,Name,
		AnyDiseaseManagement,AnyDiagnosis,isnull(InCaseManagement,-1),isnull(AnyCOPC,1)
	from HPAlertRule 
	where Active = 1 and 
		isNoteAlertRule = 1 and
		(Cust_ID = @curCustID OR
			Cust_ID in
			(select Cust_ID from hpcustomer where ParentId = @curCustID)							
		)

	select @InCaseManagement = isnull(InCaseManagement,0)
	from MainPersonalDetails
	where icenumber = @MVDId
			
	while exists (select Rule_Id from #tempAlertRule)
	begin
		select top 1 @CurRuleID = Rule_ID, 
			@CurRuleName = Name,
			@CurRuleCustId = cust_id,
			@AnyDiseaseManagement = AnyDiseaseManagement,
			@AnyDiagnosis = AnyDiagnosis,
			@RuleInCaseManagement = InCaseManagement,
			@AnyCOPC = AnyCOPC
		from #tempAlertRule

		--select @CurRuleID as '@CurRuleID',@AnyFacility ,@AnyDisease,@AnyEmployer,@AnyHealthPlan,@AnyHealthPlanType
		
		-- If some of the rule criteria are not satisfied set to 0
		set @NotifyRuleAgents = 1

		-- Check In case management
		if(@NotifyRuleAgents = 1 and @RuleInCaseManagement <> -1)
		begin
			if((@RuleInCaseManagement = 1 AND @InCaseManagement = 0)
				OR (@RuleInCaseManagement = 0 AND @InCaseManagement = 1))
			begin
				set @NotifyRuleAgents = 0
			end
		end

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
						and NPI in (select c.NPI from COPC_NPI c where Cust_ID = @curCustID)
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
				insert into HPNoteAlert (AgentID,AlertDate,Customer,MVDID,HPMemberID,StatusID,SourceRecordID,TriggerType,TriggerID,RecipientType,RecipientCustID,sourceName,CreatedBy)
				select AlertGroup_ID,@DateTime,@CurCustName,@MVDID,@HPMemberID,@AlertStatusID,@SourceRecordId,'Rule',@CurRuleID, 'Group',@CurRuleCustId,@sourceName,@CreatedBy
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
							
					-- Notify only if the notification wasn't already sent as a result of different rule
					if not exists (select id from #tempAlertedAgents where id = @CurAgent)
					begin

						-- Record that the agent was notified, so duplicate email/sms
						-- won't be sent when processing another rule
						insert into #tempAlertedAgents (id)
						values(@CurAgent)

						-- Create alert record on Agent account
						insert into HPNoteAlert (AgentID,AlertDate,Customer,MVDID,HPMemberID,StatusID,SourceRecordID,TriggerType,TriggerID,RecipientType,RecipientCustID,sourceName,CreatedBy)
						values(@CurAgent,@DateTime,@CurCustName,@MVDId,@HPMemberID,@AlertStatusID,@SourceRecordID,'Rule',@CurRuleID,'Individual',@CurRuleCustId,@sourceName,@CreatedBy)
					end
					
					delete from #tempAgent where id = @CurAgent
				end

				delete from #tempAgent
			end
		end

		delete from #tempAlertRule where Rule_ID = @CurRuleID
	end

	drop table #tempAgent
	drop table #tempAlertRule	
	drop table #tempAlertedAgents
END