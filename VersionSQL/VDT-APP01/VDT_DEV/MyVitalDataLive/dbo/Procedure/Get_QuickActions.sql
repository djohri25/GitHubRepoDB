/****** Object:  Procedure [dbo].[Get_QuickActions]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 10/24/2018
-- Description:	Get QuickActions based on Product and Customer
-- =============================================
CREATE PROCEDURE [dbo].[Get_QuickActions]
	@CustomerId int = NULL,
	@ProductId int
--	@UserName - Later add this in order to provide user administration capability. In that case All active/Inactive actions will be returned
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select
		Id
		,CustomerId
		,ProductId
		,ActionName
		,ActionDescription
		,QATId
		,TaskStatusToUpdate
		,ScheduledJobId
		,ParentQAId
		,IsActive
		,CreatedDate
		,CreatedBy
		,UpdatedDate
		,UpdatedBy
	from QuickAction
	where ProductId = @ProductId
		and (CustomerId is NULL or CustomerId = @CustomerId)
		and IsActive = 1
    
END