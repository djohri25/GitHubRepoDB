/****** Object:  Procedure [dbo].[sp_SetLockedUserCount]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE 
--ALTER
PROCEDURE [dbo].[sp_SetLockedUserCount]
	@UserID varchar(100),
	@Count int
AS
UPDATE	LockedUsers 
SET		[COUNT]=@Count
WHERE	Username = @UserID AND CompanyID = 0