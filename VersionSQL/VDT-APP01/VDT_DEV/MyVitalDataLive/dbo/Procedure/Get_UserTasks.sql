/****** Object:  Procedure [dbo].[Get_UserTasks]    Committed by VersionSQL https://www.versionsql.com ******/

--***************
----[Get_UserTasks]
--***************

-- =============================================
-- Author:		Dpatel
-- Create date: 03/06/2019
-- Description:	Get user's tasks.
-- =============================================


CREATE PROCEDURE [dbo].[Get_UserTasks] 
	@UserId varchar(100),
	@CustomerId int,
	@ProductId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select * 
	from Task
	where [Owner] = @UserId
		and CustomerId = @CustomerId
		and ProductId = @ProductId
END