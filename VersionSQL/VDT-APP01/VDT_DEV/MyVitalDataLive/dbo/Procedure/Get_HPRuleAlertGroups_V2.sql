/****** Object:  Procedure [dbo].[Get_HPRuleAlertGroups_V2]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 09/23/2016
-- Description:	Retrieves the list of Alert Group Criteria Items for particular customer
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPRuleAlertGroups_V2]
	@CustomerId int,
	@RuleId int,
	@ShowAll bit
AS
BEGIN
	SET NOCOUNT ON;

	-- Holds temporary result
	create table #tempTab (id int, name varchar(100), isSelected bit default(0), CustomerId int, Description nvarchar(500), Active bit)

	if(@ShowAll = 1)
	begin

		insert into #tempTab (id,name,CustomerId,Description,Active)
		SELECT ID, Name,Cust_ID,Description,Active from dbo.HPAlertGroup 
		where Cust_Id = @CustomerId and Active = 1

		-- Set Select flag only if @RuleId is valued
		if(@RuleId is not null and @RuleId <> 0)
		begin
			update #tempTab set isSelected = 1 where id in( 
				select AlertGroup_ID from dbo.Link_HPRuleAlertGroup
				 where Rule_Id = @RuleId)
		end

		select id, name, isSelected,CustomerId,Description,Active from #tempTab
	end
	else 
	begin
		-- Selected only rows previously selected by the user
		insert into #tempTab (id,name,isSelected,CustomerId,Description,Active)
		SELECT a.ID as id, a.Name as name,1 as isSelected,a.Cust_ID as CustomerId,a.Description as 'Description',a.Active as Active from HPAlertGroup a
			inner join Link_HPRuleAlertGroup b on a.ID = b.AlertGroup_ID 
		where Rule_ID = @RuleId	and a.Active = 1

		select id, name, isSelected,CustomerId,Description,Active from #tempTab
	end

	drop table #tempTab
END