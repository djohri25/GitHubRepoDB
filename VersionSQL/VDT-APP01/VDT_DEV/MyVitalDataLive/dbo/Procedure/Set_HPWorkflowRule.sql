/****** Object:  Procedure [dbo].[Set_HPWorkflowRule]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/01/2008
-- Description:	 Creates an instance of WorkflowRule
--		@Body - is a Json structured rule
-- =============================================
CREATE PROCEDURE [dbo].[Set_HPWorkflowRule]
	@Group varchar(50),
	@Name varchar(50),
	@Description varchar(500),
	@CustomerId int,
	@Body varchar(max) = null,
	@Active bit,
	@Action_ID int,
	@Action_Days int,
	@Result int output,
	@Query varchar(max) = null
AS
BEGIN
	SET NOCOUNT ON;
	set @Result = -1;

	declare @ruleId int, @tempId varchar(50)

	if not exists(select Name from HPWorkflowRule where Name = @Name and Cust_Id = @CustomerId)
	begin
		-- create record in main rule table
		insert into dbo.HPWorkflowRule (Cust_Id,[Group],[Name],[Description],Active,Body,Action_ID, Action_Days, Query)
		values(@CustomerId, @Group, @Name, @Description, @Active,@Body, @Action_ID,@Action_Days, @Query)

		-- get autogenerated ID for the rule
		select @ruleId = @@IDENTITY
		set @Result = @ruleId;

		INSERT INTO HPWorkflowRuleSet (RuleID,Frequency)
		Select @ruleId, 'Daily'
	end
END