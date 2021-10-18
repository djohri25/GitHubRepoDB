/****** Object:  Procedure [dbo].[Get_HPRuleAlertCriteriaItems]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/01/2008
-- Description:	 Retrieves the list of Alert Criteria Items for particular customer
--		If @RuleId is valued, get a field indicating if a criteria item is associated with the rule
--		If @ShowAll = 1 retrieve all items inluding those not selected previously by the user
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPRuleAlertCriteriaItems]
	@CustomerId int,
	@CriteriaName varchar(50),
	@RuleId int,
	@ShowAll bit
AS
BEGIN
	SET NOCOUNT ON;

--select @CustomerId = 1,
--	@CriteriaName = 'DISEASEMANAGEMENT',
--	@RuleId = 5,
--	@ShowAll = 1

	declare @CriteriaTable varchar(50), @CriteriaIdColumn varchar(50), @RelationTable varchar(50)
	declare @query varchar(1000)

	-- Holds temporary result
	create table #tempTab (id varchar(50), name varchar(100), isSelected bit default(0))

	-- Set variables based on requested criteria
	if (@CriteriaName = 'DISEASE')
	begin
		select	@CriteriaTable = 'HPDiseaseType',
				@CriteriaIdColumn = 'Disease_Id',
				@RelationTable = 'Link_HPRuleDisease'
	end
	else if (@CriteriaName = 'FACILITY')
	begin
		select	@CriteriaTable = 'HPFacility',
				@CriteriaIdColumn = 'Facility_Id',
				@RelationTable = 'Link_HPRuleFacility'
	end
	else if (@CriteriaName = 'EMPLOYER')
	begin
		select	@CriteriaTable = 'HPEmployer',
				@CriteriaIdColumn = 'Employer_Id',
				@RelationTable = 'Link_HPRuleEmployer'
	end
	else if (@CriteriaName = 'HEALTHPLANTYPE')
	begin
		select	@CriteriaTable = 'HPHealthPlanType',
				@CriteriaIdColumn = 'HealthPlanType_Id',
				@RelationTable = 'Link_HPRuleHealthPlanType'
	end
	else if (@CriteriaName = 'HEALTHPLAN')
	begin
		select	@CriteriaTable = 'HPHealthPlan',
				@CriteriaIdColumn = 'HealthPlan_Id',
				@RelationTable = 'Link_HPRuleHealthPlan'
	end
	else if (@CriteriaName = 'DISEASEMANAGEMENT')
	begin
		select	@CriteriaTable = 'HPDiseaseManagement',
				@CriteriaIdColumn = 'DM_Id',
				@RelationTable = 'Link_HPRuleDiseaseManagement'
	end
	else if (@CriteriaName = 'DIAGNOSIS')
	begin
		select	@CriteriaTable = 'HPDiagnosis',
				@CriteriaIdColumn = 'Diagnosis_Id',
				@RelationTable = 'Link_HPRuleDiagnosis'
	end

	if(@ShowAll = 1)
	begin
		set @query = 'SELECT ' + @CriteriaIdColumn + ', Name from ' + 
						@CriteriaTable + ' where Cust_Id = ' + convert(varchar, @CustomerId, 10) + ' and Active = 1'

		insert into #tempTab (id,name)
			exec (@query)

		-- Set Select flag only if @MemberId is valued
		if(@RuleId is not null and @RuleId <> 0)
		begin
			set @query = 'update #tempTab set isSelected = 1 where id in( 
				select ' + @CriteriaIdColumn + ' from ' + @RelationTable + 
				' where Rule_Id = ' + convert(varchar, @RuleId,10) + ')'
			exec(@query)
		end

		select id, name, isSelected 
		from #tempTab
		order by name
	end
	else 
	begin
		-- Selected only rows previously selected by the user
		set @query = 'SELECT a.' + @CriteriaIdColumn + ' as id, Name, 1 as isSelected
						from ' + @CriteriaTable + ' a 
						inner join ' + @RelationTable + ' b on a.' + @CriteriaIdColumn + 
							'=b.' + @CriteriaIdColumn +
					' where a.Cust_Id = ' + convert(varchar, @CustomerId, 10) + ' and Active = 1 and b.Rule_ID = ' + convert(varchar, @RuleId, 10) + 
					' order by name '										

		exec (@query)
	end

	drop table #tempTab
END