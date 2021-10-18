/****** Object:  Procedure [dbo].[Get_HPRuleFacilityItems]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/01/2008
-- Description:	 Retrieves the list of Facility Alert Criteria Items for particular customer
--		If @RuleId is valued, get a field indicating if a criteria item is associated with the rule
--		If @ShowAll = 1 retrieve all items inluding those not selected previously by the user
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPRuleFacilityItems]
	@CustomerId int,
	@RuleId int,
	@ShowAll bit
AS
BEGIN
	SET NOCOUNT ON;

--	select @CustomerId = 1, @RuleId = 6, @ShowAll = 0

	-- Holds temporary result
	create table #tempTab (id varchar(50), name varchar(100), isSelected bit default(0))

	if(@ShowAll = 1)
	begin

		insert into #tempTab (id,name)
		SELECT ID, Name from MainEMSHospital a
			inner join Link_HPFacilityCustomer b on a.ID = b.Facility_ID 
		where Cust_Id = @CustomerId 

		-- Set Select flag only if @RuleId is valued
		if(@RuleId is not null and @RuleId <> 0)
		begin
			update #tempTab set isSelected = 1 where id in( 
				select Facility_ID from dbo.Link_HPRuleFacility
				 where Rule_Id = @RuleId)
		end

		select id, name, isSelected 
		from #tempTab
		order by name
	end
	else 
	begin
		-- Selected only rows previously selected by the user

		SELECT ID, Name,1 as isSelected from MainEMSHospital a
			inner join Link_HPRuleFacility b on a.ID = b.Facility_ID 
		where Rule_ID = @RuleId		
		order by name
	end

	drop table #tempTab
END