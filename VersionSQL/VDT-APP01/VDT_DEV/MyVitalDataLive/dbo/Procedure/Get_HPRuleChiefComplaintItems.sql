/****** Object:  Procedure [dbo].[Get_HPRuleChiefComplaintItems]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 8/21/2009
-- Description:	 Retrieves the list of County Alert Criteria Items for particular customer
--		If @RuleId is valued, get a field indicating if a criteria item is associated with the rule
--		If @ShowAll = 1 retrieve all items inluding those not selected previously by the user
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPRuleChiefComplaintItems]
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
			SELECT ID, Name from lookupChiefComplaint a

			update @tempTab set isSelected = 1 where id in( 
				select chiefComplaint_ID from dbo.Link_HPRuleChiefComplaint
				 where Rule_Id = @RuleId)

			select id, dbo.initFirstCap(name) as Name, isSelected 
			from @tempTab	
			order by name
		end
		else
		begin
			SELECT id, dbo.initFirstCap(name) as Name, 0 as isSelected
			from lookupChiefComplaint		
			order by name	
		end
	end
	else 
	begin
		-- Selected only rows previously selected by the user

		SELECT id, dbo.initFirstCap(name) as Name, 1 as isSelected
		from lookupChiefComplaint cc
			inner join dbo.Link_HPRuleChiefComplaint li on cc.id = li.chiefComplaint_ID
		where li.rule_ID = @RuleId
		order by name
	end

END