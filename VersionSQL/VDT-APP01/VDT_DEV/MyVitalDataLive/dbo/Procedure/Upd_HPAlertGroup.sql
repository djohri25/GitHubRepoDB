/****** Object:  Procedure [dbo].[Upd_HPAlertGroup]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 9/23/2009
-- Description:	 Updates an instance of Alert Group
-- =============================================
create PROCEDURE [dbo].[Upd_HPAlertGroup]
	@ID int,
	@Name varchar(50),
	@Description varchar(500),
	@CustomerId int,
	@AgentList varchar(max),
	@Active bit,
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;

	declare @tempId varchar(50)

	-- holds the result of values split from the input strings
	create table #temp (data varchar(50), isProcessed bit default(0))

	if not exists(select Name from HPAlertGroup where Name = @Name and Cust_Id = @CustomerId and ID <> @ID)
	begin
		-- update record in main group table
		update dbo.HPAlertGroup set
			Cust_Id = @CustomerId,
			Name = @Name,
			Description = @Description,
			Active = @Active
		where ID = @Id

		-- insert records into tables related to the group
		-- clear all related records first and insert the new set of relations

		-- AGENT
		delete from Link_HPAlertGroupAgent where Group_Id = @Id
		if(len(isnull(@AgentList,'')) > 0)
		begin
			insert into #temp (data)
				select data from dbo.split(@AgentList,',')

			-- insert records into Group_Agent relation table
			while exists (select data from #temp where isProcessed = 0)
			begin
				select top 1 @tempId = data from #temp where isProcessed = 0
				
				insert into Link_HPAlertGroupAgent (Group_ID, Agent_ID)
					values (@ID, @tempId)

				delete from #temp where data = @tempId
			end
		end

		select @result = 0
	end
	else
	begin
		-- Group name is alread used
		select @result = -1
	end
	
	drop table #temp	
END