/****** Object:  Procedure [dbo].[Set_TaskIsDeleted]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 05/14/2019
-- Description:	Update task record to be deleted.
-- =============================================
CREATE PROCEDURE [dbo].[Set_TaskIsDeleted]
	@TaskId int,
	@IsDeleted bit,
	@UserName varchar(100),
	@ModifiedDate datetime = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Update Task
	set IsDelete = @IsDeleted
	   ,UpdatedBy = @UserName
	   ,UpdatedDate = ISNULL(@ModifiedDate,getutcdate())
	where Id = @TaskId
END