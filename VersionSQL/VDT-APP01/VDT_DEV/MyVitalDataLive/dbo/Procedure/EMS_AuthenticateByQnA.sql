/****** Object:  Procedure [dbo].[EMS_AuthenticateByQnA]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 7/20/2010
-- Description:	Authenticates username, company, and answers to 3 questions.
-- =============================================
CREATE PROCEDURE [dbo].[EMS_AuthenticateByQnA] 
	@username varchar(50), 
	@facilityIP varchar(15),
	@a1	varchar(50),
	@a2 varchar(50),
	@a3 varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CompanyID int, @CompanyName nvarchar(50), @xMinutesAgo datetime
	DECLARE @result int 
	-- possible values: 
	--  1 - authentication succeeded, 
	--  0 - authentication failed, 
	-- -1 - username is locked for 15 minutes
	SET @result = 0

	SELECT	TOP 1
			@CompanyID = ID, @CompanyName = m.Name, 
			@xMinutesAgo = DATEADD(minute, -15, GETUTCDATE())
	FROM	MainEMSHospital m INNER JOIN
			Companies c ON m.Name = c.CompanyName
	WHERE	@FacilityIP BETWEEN c.IPAddressRangeMin and c.IPAddressRangeMax

	/*
	check username & companyid in lockedusers
	if lockeduser count > 3 and datelastfailed is less than 15 minutes ago
		increment lockedusers count & datelastfailed
		return username is locked
	else 
		check username, companyid, password
		if password good
			remove from lockedusers
			update lastlogin
			return authentication succeeded
		else
			create lockedusers if one doesn't exist
			increment lockedusers count & datelastfailed
			if lockeduser count == 3
				return username is locked
			else
				return authentication failed
	*/

	UPDATE	LockedUsers
	SET		[Count] = [Count] + 1, DateLastFailed = (GETUTCDATE())
	WHERE	Username = @Username AND CompanyID = @CompanyID AND [Count] >= 3 AND DateLastFailed > @xMinutesAgo

	IF @@ROWCOUNT = 1
		SET	@result = -1
	ELSE
	BEGIN
		IF @CompanyName IN ('Community Hospital Watervliet', 'Borgess Health')
			SELECT	TOP 1 @Username = Username
			FROM	MainEMS
			WHERE	Active = 1 AND Username = @Username AND SecurityA1 = @a1 AND SecurityA2 = @a2 AND SecurityA3 = @a3 AND
					Company IN ('Community Hospital Watervliet', 'Borgess Health')
		ELSE
			SELECT	TOP 1 @Username = Username
			FROM	MainEMS
			WHERE	Active = 1 AND Username = @Username AND SecurityA1 = @a1 AND SecurityA2 = @a2 AND SecurityA3 = @a3 AND
					CompanyID = @CompanyID
			
		IF @@ROWCOUNT = 1
		BEGIN
			DELETE	LockedUsers
			WHERE	Username = @Username AND CompanyID = @CompanyID
			
			UPDATE	MainEMS
			SET		LastLogin = (GETUTCDATE())
			WHERE	Username = @Username AND CompanyID = @CompanyID
			
			SET	@result = 1
		END
		ELSE
		BEGIN
			SET	@result = 0
			
			UPDATE	LockedUsers
			SET		[Count] = [Count] + 1, DateLastFailed = (GETUTCDATE())
			WHERE	Username = @Username AND CompanyID = @CompanyID
			
			IF @@ROWCOUNT = 0
				INSERT	LockedUsers
						(Username, CompanyId, [Count], DateLastFailed)
				VALUES	(@Username, @CompanyId, 1, (GETUTCDATE()))
			ELSE IF EXISTS(SELECT TOP 1 Username FROM LockedUsers WHERE Username = @Username AND CompanyID = @CompanyID AND [Count] = 3)
				SET @result = -1
		END
	END

	SELECT @result
END