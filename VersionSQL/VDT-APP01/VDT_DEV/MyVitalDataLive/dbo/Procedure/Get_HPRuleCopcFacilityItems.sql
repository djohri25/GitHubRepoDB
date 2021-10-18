/****** Object:  Procedure [dbo].[Get_HPRuleCopcFacilityItems]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 5/15/2013
-- Description:	 Retrieves the list of Copc Facility Alert Criteria Items for particular customer
--		If @RuleId is valued, get a field indicating if a criteria item is associated with the rule
--		If @ShowAll = 1 retrieve all items inluding those not selected previously by the user
-- =============================================
create PROCEDURE [dbo].Get_HPRuleCopcFacilityItems
	@CustomerId int,
	@RuleId int,
	@ShowAll bit
AS
BEGIN
	SET NOCOUNT ON;

	-- Holds temporary result
	declare @tempTab table  (id varchar(50), name varchar(100), isSelected bit default(0))

	if(@ShowAll = 1)
	begin

		-- Set Select flag only if @RuleId is valued
		if(@RuleId is not null and @RuleId <> 0)
		begin
			insert into @tempTab (id,name)
			SELECT ID, FacilityName 
			from CopcFacility 
			where Active = 1
			
			update @tempTab set isSelected = 1 where id in( 
				select CopcFacility_ID from dbo.Link_HPRuleCopcFacility
				 where Rule_Id = @RuleId)

			select id, dbo.initFirstCap(name) as Name, isSelected 
			from @tempTab	
			order by name
		end
		else
		begin
			SELECT id, dbo.initFirstCap(FacilityName) as Name, 0 as isSelected
			from CopcFacility		
			order by name	
		end
	end
	else 
	begin
		-- Selected only rows previously selected by the user

		SELECT id, dbo.initFirstCap(FacilityName) as Name, 1 as isSelected
		from CopcFacility cc
			inner join dbo.Link_HPRuleCopcFacility li on cc.id = li.CopcFacility_ID
		where li.rule_ID = @RuleId
		order by name
	end

END