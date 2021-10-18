/****** Object:  Procedure [dbo].[EMS_AllowUserPINReset]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 7/26/2010
-- Description:	Sets password to NULL which allows user access to PIN Reset page
-- =============================================
CREATE PROCEDURE [dbo].[EMS_AllowUserPINReset] 
	@primaryKey int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Username varchar(50), @CompanyID int
	
	SELECT	@Username = Username, @CompanyID = CompanyID
	FROM	MainEMS
	WHERE	PrimaryKey = @primaryKey
	
	UPDATE	MainEMS
	SET		Password = NULL
	WHERE	PrimaryKey = @primaryKey
	
	DELETE	LockedUsers
	WHERE	Username = @Username AND CompanyID = @CompanyID
END