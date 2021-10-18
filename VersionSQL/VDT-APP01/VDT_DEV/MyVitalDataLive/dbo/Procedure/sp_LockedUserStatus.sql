/****** Object:  Procedure [dbo].[sp_LockedUserStatus]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_LockedUserStatus]
	@UserID varchar(100),
	@Count tinyint,
	@Locked bit OUT
AS
SET @Locked=0
IF EXISTS (SELECT 1 FROM MainUserName WHERE UserName = @UserID) 
	BEGIN
		--PRINT 'USER FOUND IN MAIN DB' 
		IF EXISTS (SELECT 1 FROM LockedUsers WHERE Username = @UserID) 
			BEGIN
				--PRINT 'USER FOUND IN LOCKED TABLE'
				IF EXISTS (SELECT 1 FROM LockedUsers WHERE Username = @UserID AND CompanyID = 0 AND ([COUNT]>= 3) AND  ((GETUTCDATE()- DateLastFailed) > '00:15' ))
					BEGIN
						--PRINT 'USER LOCK HAS BEEN REMOVED'
						UPDATE LockedUsers SET [COUNT]=0, DateLastFailed = GETUTCDATE() WHERE Username = @UserID AND CompanyID = 0
						SET @Locked=0
					END
				ELSE
					BEGIN
						IF EXISTS (SELECT 1 FROM LockedUsers WHERE Username = @UserID AND CompanyID = 0 AND ([COUNT]>= 3) AND  ((GETUTCDATE()- DateLastFailed) < '00:15' ))
							--PRINT 'USER LOCK SET'
							SET @Locked=1
						ELSE
							--PRINT 'USER LOCK TABLE UPDATED'						
							UPDATE LockedUsers SET [COUNT]=@Count, DateLastFailed = GETUTCDATE() WHERE Username = @UserID AND CompanyID = 0
					END
			END
		ELSE
			--PRINT 'USER INSERTED IN LOCK TABLE '	
			INSERT INTO LockedUsers(Username, CompanyID, [COUNT], DateLastFailed) VALUES( @UserID, 0, @Count, GETUTCDATE())
	END 
ELSE
	PRINT 'USER NOT FOUND IN MAIN DB'