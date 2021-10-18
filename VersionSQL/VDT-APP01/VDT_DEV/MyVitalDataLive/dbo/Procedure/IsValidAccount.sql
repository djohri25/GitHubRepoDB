/****** Object:  Procedure [dbo].[IsValidAccount]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 7/1/2009
-- Description:	Check if the account exists
--	in MVD system. If 'checkActiveIns' is set to 1
--	also validate Insurance policy
-- =============================================
CREATE PROCEDURE [dbo].[IsValidAccount]
	@MVDId varchar(20), 
	@checkActiveIns bit,
	@EnteredMemberID varchar(20),
	@Action varchar(50),
	@LocationID varchar(30), 
	@ApplicationID varchar(50),
    @UserName varchar(50), 
	@AccessReason varchar(2000),
	@RequestType varchar(50)		-- e.g. ER or MD
AS
BEGIN
	SET NOCOUNT ON;

	declare @result bit, @failReason varchar(100)
	-- Get user facility
	declare @facility varchar(250), @facilityID int

	set @result = 0

	if exists(select icenumber from MainPersonalDetails where icenumber = @MVDId)
	begin
		if(@checkActiveIns = 1)		
		begin
			-- The result is 0 only when account is linked to Health Plan,
			-- and user has insurance record with same name as Health Plan 
			-- and Termination date is in the past
			set @result = dbo.CanRetrieveRecord(@MVDId)

			if(@result = 0)
			begin
				select @failReason = 'Expired insurance'
			end
		end
		else
		begin
			set @result = 1
		end
	end
	else
	begin
		select @failReason = 'Member not found'
	end

	-- Successful lookups are recorded in main export store proc
	if(@Result = 0)
	begin
		SELECT	TOP 1 @facility = COMPANY, @facilityID = CompanyID
		FROM	mainEMS
		WHERE	email = @UserName or username = @UserName

		if( @RequestType = 'ER')
		begin
			INSERT INTO MVD_AppRecord 
					(AppId,LocationID,UserName,UserFacilityID,AccessReason,Action,MVDID,Criteria,ResultStatus,ResultCount, 
					ChiefComplaint,EMSNote, CancelNotification, CancelNotifyReason, Status)
			VALUES	(@ApplicationID,@LocationID,@UserName,@facilityID,@AccessReason,@Action,@EnteredMemberID,'','FAILED', 0,
					'','',0, '', @failReason)	
		end
		else
		begin
			INSERT INTO MVD_AppRecord_MD 
					(AppId,LocationID,UserName,UserFacilityID,AccessReason,Action,MVDID,Criteria,ResultStatus,ResultCount, 
					ChiefComplaint,EMSNote, CancelNotification, CancelNotifyReason, Status)
			VALUES	(@ApplicationID,@LocationID,@UserName,@facilityID,@AccessReason,@Action,@EnteredMemberID,'','FAILED', 0,
					'','',0, '', @failReason)	
		end
	end

	select @result
END