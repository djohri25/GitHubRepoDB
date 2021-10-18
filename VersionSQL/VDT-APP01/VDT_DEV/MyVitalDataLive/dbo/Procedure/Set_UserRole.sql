/****** Object:  Procedure [dbo].[Set_UserRole]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Sandberg
-- Create date: 9/14/20
-- Description:	Insert or update UserRole record
-- =============================================
CREATE PROCEDURE [dbo].[Set_UserRole] 
	-- Add the parameters for the stored procedure here
	@UserRoleID UNIQUEIDENTIFIER, 
	@UserID UNIQUEIDENTIFIER, 
	@RoleID UNIQUEIDENTIFIER,
	@IsActive BIT,
	@CreatedBy VARCHAR(50),
	@UpdatedBy VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE dbo.UserRole
	SET RoleID = @RoleID, Updated = GETDATE(), UpdatedBy = @UpdatedBy, IsActive = @IsActive
	WHERE UserID = @UserID AND IsActive = 1;

	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO dbo.UserRole(UserRoleID, UserID, RoleID, CreatedBy, UpdatedBy)
		VALUES(@UserRoleID, @UserID, @RoleID, @CreatedBy, @UpdatedBy);
	END

END