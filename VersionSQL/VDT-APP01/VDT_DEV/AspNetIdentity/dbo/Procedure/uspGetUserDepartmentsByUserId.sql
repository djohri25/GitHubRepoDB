/****** Object:  Procedure [dbo].[uspGetUserDepartmentsByUserId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		nelanwer
-- Create date: 06/24/2019
-- Description:	Gets a list of the user departments
-- =============================================
CREATE PROCEDURE [dbo].[uspGetUserDepartmentsByUserId]
	-- Add the parameters for the stored procedure here
	@UserId nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	Id,
	Name
	FROM AspNetUserDepartments u
	INNER JOIN AspNetDepartments d on u.DepartmentId= d.Id
	WHERE u.UserId=@UserId
END