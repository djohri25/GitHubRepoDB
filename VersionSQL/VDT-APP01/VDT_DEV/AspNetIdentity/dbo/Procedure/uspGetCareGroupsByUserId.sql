/****** Object:  Procedure [dbo].[uspGetCareGroupsByUserId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		NE
-- Create date: 06/21/2019
-- Description:	Gets a list of user care queue groups
-- =============================================
CREATE PROCEDURE [dbo].[uspGetCareGroupsByUserId]
	-- Add the parameters for the stored procedure here
	@UserId nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		Id,
		Name
	FROM AspNetCareQueueGroups G
	INNER JOIN AspNetCareQueueGroupsUsers U ON
	G.Id=U.CareQueueGroupId
	WHERE U.UserId= @UserId
END