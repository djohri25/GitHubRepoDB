/****** Object:  Procedure [dbo].[sp_LockedUserCount]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_LockedUserCount]
	@UserID varchar(100),
	@Count int OUTPUT
AS
SET @Count = 0
SELECT @Count = [COUNT] FROM LockedUsers WHERE Username = @UserID AND CompanyID = 0