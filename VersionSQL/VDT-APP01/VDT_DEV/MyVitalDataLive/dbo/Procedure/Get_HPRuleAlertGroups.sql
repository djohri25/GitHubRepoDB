/****** Object:  Procedure [dbo].[Get_HPRuleAlertGroups]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 9/24/2009
-- Description:	 Retrieves the list of Alert Group Criteria Items for particular customer
--		If @RuleId is valued, get a field indicating if a criteria item is associated with the rule
--		If @ShowAll = 1 retrieve all items inluding those not selected previously by the user
-- =============================================
create PROCEDURE [dbo].[Get_HPRuleAlertGroups]
	@CustomerId int,
	@RuleId int,
	@ShowAll bit
AS
BEGIN
	SET NOCOUNT ON;

	-- Holds temporary result
	create table #tempTab (id varchar(50), name varchar(100), isSelected bit default(0))

	if(@ShowAll = 1)
	begin

		insert into #tempTab (id,name)
		SELECT ID, Name from dbo.HPAlertGroup 
		where Cust_Id = @CustomerId 

		-- Set Select flag only if @RuleId is valued
		if(@RuleId is not null and @RuleId <> 0)
		begin
			update #tempTab set isSelected = 1 where id in( 
				select AlertGroup_ID from dbo.Link_HPRuleAlertGroup
				 where Rule_Id = @RuleId)
		end

		select id, name, isSelected from #tempTab
	end
	else 
	begin
		-- Selected only rows previously selected by the user

		SELECT ID, Name,1 as isSelected from HPAlertGroup a
			inner join Link_HPRuleAlertGroup b on a.ID = b.AlertGroup_ID 
		where Rule_ID = @RuleId		
	end

	drop table #tempTab
END