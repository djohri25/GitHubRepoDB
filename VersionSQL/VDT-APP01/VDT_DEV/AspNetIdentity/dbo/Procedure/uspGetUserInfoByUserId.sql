/****** Object:  Procedure [dbo].[uspGetUserInfoByUserId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		nelanwer
-- Create date: 06/21/2019
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetUserInfoByUserId]
	-- Add the parameters for the stored procedure here
	@UserId nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *
	FROM AspNetUserInfo
	WHERE UserId=@UserId
END