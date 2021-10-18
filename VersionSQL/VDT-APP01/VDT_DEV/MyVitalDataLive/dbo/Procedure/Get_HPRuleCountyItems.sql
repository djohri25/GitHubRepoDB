/****** Object:  Procedure [dbo].[Get_HPRuleCountyItems]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 8/21/2009
-- Description:	 Retrieves the list of County Alert Criteria Items for particular customer
--		If @RuleId is valued, get a field indicating if a criteria item is associated with the rule
--		If @ShowAll = 1 retrieve all items inluding those not selected previously by the user
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPRuleCountyItems]
	@CustomerId int,
	@RuleId int,
	@ShowAll bit
AS
BEGIN
	SET NOCOUNT ON;

--	select @CustomerId = 1, @RuleId = 6, @ShowAll = 1
	declare @customerState varchar(50)

	-- Holds temporary result
	create table #tempTab (id varchar(50), name varchar(100), isSelected bit default(0))

	select @customerState = State from hpcustomer where cust_id = @customerID

	insert into #tempTab (id,name)
	SELECT distinct fipsCountyCode, NameCounty from Fips a
	where StateAlphaCode = @customerState

	if(@ShowAll = 1)
	begin

		-- Set Select flag only if @RuleId is valued
		if(@RuleId is not null and @RuleId <> 0)
		begin
			update #tempTab set isSelected = 1 where id in( 
				select county_ID from dbo.Link_HPRuleCounty
				where Rule_Id = @RuleId)
		end

		select id, name, isSelected from #tempTab
	end
	else 
	begin
		-- Selected only rows previously selected by the user

		SELECT a.id as ID, a.Name as Name,1 as isSelected from #tempTab a
			inner join Link_HPRuleCounty b on a.id = b.county_ID 
		where Rule_ID = @RuleId		
	end

	drop table #tempTab
END