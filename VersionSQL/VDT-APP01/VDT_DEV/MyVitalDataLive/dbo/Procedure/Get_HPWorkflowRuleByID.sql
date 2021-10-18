/****** Object:  Procedure [dbo].[Get_HPWorkflowRuleByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 12/23/2008
-- Description:	 Retrieves the Workflow Rule identified by ID
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPWorkflowRuleByID]
	@RuleId varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	select Rule_ID,Name, [Description], Cust_ID,
		(select Name from HPCustomer where Cust_ID = a.Cust_ID) as CustomerName,  
		Active,
		[Body],
		isnull([Action_ID],-1) as Action_ID,
		isnull([Action_Days],-1) as Action_Days
	from HPWorkflowRule a 
	where Rule_ID = @RuleId
END