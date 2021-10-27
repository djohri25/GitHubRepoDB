/****** Object:  Procedure [dbo].[uspGetUserSupervisorsByUserId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		nelanwer
-- Create date: 06/24/2019
-- Description:	Gets a list of the user supervisors
-- =============================================
CREATE PROCEDURE [dbo].[uspGetUserSupervisorsByUserId]
	-- Add the parameters for the stored procedure here
	@UserId nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *
	FROM AspNetUserSupervisors u
	INNER JOIN AspNetSupervisors s on u.SupervisorId= s.Id
	WHERE u.UserId=@UserId
END