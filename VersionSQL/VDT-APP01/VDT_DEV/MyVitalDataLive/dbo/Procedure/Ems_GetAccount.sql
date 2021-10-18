/****** Object:  Procedure [dbo].[Ems_GetAccount]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Ems_GetAccount]
	@Username varchar(50),
	@Password varchar(50),
	@FacilityIP varchar(20) = null,
	@UserType varchar(50) = null		-- 'ER', 'Hosp', etc. Default is 'ER'
AS
	SET NOCOUNT ON

	DECLARE @CompanyID int, @CompanyName nvarchar(50), @xMinutesAgo datetime
	DECLARE @result int 
	-- possible values: 
	--  1 - authentication succeeded, 
	--  0 - authentication failed, 
	-- -1 - username is locked for 15 minutes
	SET @result = 0

	IF DB_NAME() != 'MyVitalDataDemo' OR (DB_NAME() = 'MyVitalDataDemo' AND (left(@Username,5) != 'sales' AND @Username != 'mtran@vitaldatatech.com') )
	BEGIN
		SELECT	TOP 1
				@CompanyID = ID, @CompanyName = m.Name, 
				@xMinutesAgo = DATEADD(minute, -15, GETUTCDATE())
		FROM	MainEMSHospital m INNER JOIN
				Companies c ON m.ID = c.companyID				-- m.Name = c.CompanyName
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
		
			if (isnull(@UserType,'') <> 'Hosp')
			begin
				IF @CompanyName IN ('Community Hospital Watervliet', 'Borgess Health')
					SELECT	TOP 1 @Username = Username
					FROM	MainEMS
					WHERE	Active = 1 AND Username = @Username AND [Password] = @Password AND
							Company IN ('Community Hospital Watervliet', 'Borgess Health')
				ELSE
					SELECT	TOP 1 @Username = Username
					FROM	MainEMS
					WHERE	Active = 1 AND Username = @Username AND [Password] = @Password AND
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
			else
			begin
				-- HOSP users
				IF @CompanyName IN ('Community Hospital Watervliet', 'Borgess Health')
					SELECT	TOP 1 @Username = Username
					FROM	HospitalUser
					WHERE	Active = 1 AND Username = @Username AND [Password] = @Password AND
							Company IN ('Community Hospital Watervliet', 'Borgess Health')
				ELSE
					SELECT	TOP 1 @Username = Username
					FROM	HospitalUser
					WHERE	Active = 1 AND Username = @Username AND [Password] = @Password AND
							CompanyID = @CompanyID
					
				IF @@ROWCOUNT = 1
				BEGIN
					DELETE	LockedUsers
					WHERE	Username = @Username AND CompanyID = @CompanyID
					
					UPDATE	HospitalUser
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
			end
		END
	END
	ELSE
	BEGIN
		-- Allow in all usernames starting with 'sales...' on demo environment
		
		if(isnull(@UserType,'') = 'Hosp')
		begin
			UPDATE	HospitalUser
			SET		LastLogin = (GETUTCDATE())
			WHERE	Username = @Username AND CompanyID = 1

			IF @@ROWCOUNT = 1
				SET @result = 1		
		end
		else
		begin
			UPDATE	MainEMS
			SET		LastLogin = (GETUTCDATE())
			WHERE	Username = @Username AND CompanyID = 1

			IF @@ROWCOUNT = 1
				SET @result = 1
		end
	END

	SELECT @result