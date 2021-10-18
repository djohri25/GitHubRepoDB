/****** Object:  Procedure [dbo].[Get_HPWorkflowRuleList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/02/2008
-- Description:	 Retrieves the list of Alerting Rules for particular customer
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPWorkflowRuleList]
	@CustomerId varchar(50)
AS
---------------------------------------------------------------------------------------------
-- Date					Name					Comments									
-- 12/29/2016			PPetluri				Made GroupID to comma seperated column
---------------------------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON;
Declare @Cus_Name	varchar(100);

select @Cus_Name = Name from HPCustomer where Cust_ID = CAST(@CustomerId as INT)

	--select a.Rule_ID, Name, [Description], Cust_ID,
	--	(select Name from HPCustomer where Cust_ID = a.Cust_ID) as CustomerName,  
	--	Active,
	--	[Body],
	--	isnull([Action_ID],-1) as Action_ID,
	--	isnull([Action_Days],-1) as Action_Days,
	--	b.AlertGroup_ID as Group_ID
	--from HPWorkflowRule a 
	--left join Link_HPRuleAlertGroup b on a.Rule_ID = b.Rule_ID;
	----where Cust_ID = @CustomerId

	;WITH CTE as (
		select a.Rule_ID,
		b.AlertGroup_ID as Group_ID
	from HPWorkflowRule a 
	left join Link_HPRuleAlertGroup b on a.Rule_ID = b.Rule_ID
	)
	Select distinct  A.Rule_ID, A.[Group], A.[Name], A.[Description], A.Cust_ID, @Cus_Name as CustomerName, A.Active, A.Body, A.Action_ID, A.Action_Days, substring((SELECT ','+CAST(c.Group_ID as varchar(10)) FROM cte c where c.rule_ID = A.rule_ID ORDER BY c.Group_ID
				FOR XML PATH('')),2,200000) as GroupID
		From HPWorkflowRule a where a.Cust_ID = @CustomerId

END