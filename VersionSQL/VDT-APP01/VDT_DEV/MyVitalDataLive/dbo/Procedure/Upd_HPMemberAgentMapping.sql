/****** Object:  Procedure [dbo].[Upd_HPMemberAgentMapping]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 09/29/2008
-- Description:	 Saves the linking between HealthPlan/MVD members and agents.
--		If @IsIndividualMapping = 1 we can clear all the records first for
--			the @CustomerId, and insert records passed as a parameter. In this case 
--			@Members contains only one Id without comma
--		SP returns comma separated list of successfully mapped member Ids
-- =============================================
CREATE PROCEDURE [dbo].[Upd_HPMemberAgentMapping]
	@Members varchar(max),
	@Agents varchar(max),
	@IsIndividualMapping bit,
	@CustomerId varchar(50),
	@SucMapped varchar(max) output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @tempMemberId varchar(50), @tempAgentId varchar(50)

	select @SucMapped = ''

--	select @Members = '8888888801', @Agents = '', @CustomerId =1, 
--		@IsIndividualMapping = 1

	-- Allow unmapping all agents only for individual assignments
	if(len(isnull(@Members,'')) = 0 or (@IsIndividualMapping = 0 and len(isnull(@Agents,'')) = 0))
	begin
		select @SucMapped = null
		return
	end

	-- Create temporary tables holding member Ids and agent Ids	
	create table #tempMember (id varchar(50), isProcessed bit)
	create table #tempAgent (id varchar(50), isProcessed bit)

	-- parse input strings
	insert into #tempMember(id) 
		select data from dbo.split(@Members,',')

	-- avoid inserting blank record
	if(len(isnull(@Agents,'')) > 0)
	begin
		insert into #tempAgent(id) 
			select data from dbo.split(@Agents,',')
	end

	-- Verify each Member Id if it exists in the system
	-- NOTE: UI might allow free text fields to enter member Id, that's why we need 
	--		to verify them before linking
	while exists (select id from #tempMember where isProcessed is null or isProcessed <> 1)
	begin
		select top 1 @tempMemberId = id from #tempMember where isProcessed is null or isProcessed <> 1

		if exists (select MVDId from dbo.Link_MemberId_MVD_Ins where InsMemberId = @tempMemberId and Cust_Id = @CustomerId)		
		begin
			select @SucMapped = isnull(@SucMapped,'') + @tempMemberId + ','
		end

		update #tempMember set isProcessed = 1 where id = @tempMemberId		
	end

	-- reset isProcessed flag
	update #tempMember set isProcessed = 0
	
	if(len(isnull(@SucMapped,'')) > 0)
	begin
		-- remove last comma
		select @SucMapped = substring(@SucMapped, 0, len(@SucMapped));

		-- create a new list of members which were found in the system	
		delete from #tempMember
		insert into #tempMember (Id)
			select data from dbo.split(@SucMapped, ',')
	end
	else
	begin
		-- return if none of the members from the list were found in the system
		drop table #tempMember
		drop table #tempAgent
		return
	end
	
	if(@IsIndividualMapping = 1)
	begin
		-- we can delete all linking for that member and customer because
		-- the new list has been submitted
		delete from dbo.Link_HPMember_Agent where Member_Id = @Members and Cust_Id = @CustomerId
	end

	-- Loop through each item in Members table
	while exists (select id from #tempMember where isProcessed is null or isProcessed <> 1)
	begin
		select top 1 @tempMemberId = id from #tempMember where isProcessed is null or isProcessed <> 1

		-- Loop through each item in agents table
		while exists (select id from #tempAgent where isProcessed is null or isProcessed <> 1)
		begin
			select top 1 @tempAgentId = id from #tempAgent where isProcessed is null or isProcessed <> 1
		
			-- Link Member to Agent
			if not exists (select Member_Id from Link_HPMember_Agent where Member_Id = @tempMemberId and Agent_Id = @tempAgentId)
			begin
				insert into Link_HPMember_Agent (Member_Id,Agent_Id,Cust_Id)
					values (@tempMemberId, @tempAgentId, @CustomerId)
			end

			update #tempAgent set isProcessed = 1 where id = @tempAgentId
		end

		-- Reset process flag in agent list to prepare the table for the next iteration
		update #tempAgent set isProcessed = 0 

		update #tempMember set isProcessed = 1 where id = @tempMemberId
	end

	drop table #tempMember
	drop table #tempAgent
END