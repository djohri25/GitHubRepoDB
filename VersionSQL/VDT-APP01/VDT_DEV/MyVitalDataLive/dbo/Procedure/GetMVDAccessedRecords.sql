/****** Object:  Procedure [dbo].[GetMVDAccessedRecords]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Goes over each log about MyVitalData
--		record access and sends email notifying the primary
--		owner of the account and contact people with 'Notify by Email' flag set. 
--		Email is sent only once and the date of the notification is recorded.
--		Don't send email multiple times if the record was accessed within same facility
--		and 12 hour time period
--		The procedure also inserts records to outgoing SMS table for
--		contact people with 'Notify by SMS' flag set.
--		Don't send email/sms to health plan members (they didn't sign up for MVD membership
--		explicitly so they shouldn't be notified about record access)
-- 06/08/2017	Marc De Luca	Changed @NotifyOnError
-- =============================================
CREATE PROCEDURE [dbo].[GetMVDAccessedRecords]
AS
BEGIN

	SET NOCOUNT ON;

	-- Holds the list of recipients of the access notification
	CREATE TABLE #Recipients (
			Email varchar(50),
			FNamePrimary varchar(50),
			LNamePrimary varchar(50),
			FNameProfile varchar(50),
			LNameProfile varchar(50),
			MVDID varchar(30),
			ICEGROUP VARCHAR(30),
			IsPrimary bit,
			Date DateTime,
			UserAccessed varchar(50),
			UserFacility varchar(50),
			UserFacilityID int,
			AppAccessed varchar(100),
			RecordID int,
			IsHealthPlanMember bit default(0),
			AccessReason varchar(2000),
			ChiefComplaint varchar(100),
			EMSNote varchar(1000),
			CancelNotification bit,
			CancelNotifyReason varchar(100),
			isProcessed bit default(0)
	)

	-- Info of primary owner of the account
	declare @email varchar(50), 
			@primMVDID varchar(50),
			@primFName varchar(50), 
			@primLName varchar(50)

	declare @_mvdid varchar(30), 
			@_group varchar(30), 
			@_isprim bit,
			@_FNameProf varchar(50),
			@_LNameProf varchar(50),
			@_AccDate DateTime,
			@_UserAcc varchar(50),
			@_AppAccessed varchar(100),
			@_RecordId int,
			@_UserAccFacility varchar(50),
			@_UserAccFacilityID int,
			@_AccessReason varchar(2000),
			@_ChiefComplaint varchar(100),
			@_EMSNote varchar(1000),
			@_CancelNotification bit,
			@_CancelNotifyReason varchar(100)

	declare @est datetime

	declare @IsHealthPlanMember bit

	declare @NotifyOnError varchar(200)

	set @NotifyOnError = 'alerts@vitaldatatech.com'

	DECLARE Sendmail CURSOR FOR
	SELECT Email, FNamePrimary,LNamePrimary,MVDID,FNameProfile,LNameProfile,IsPrimary,
		Date,UserAccessed,AppAccessed, RecordID,IsHealthPlanMember,UserFacility,AccessReason,ChiefComplaint,EMSNote,
		CancelNotification,CancelNotifyReason
	FROM #Recipients order by LNameProfile

	BEGIN TRY

		INSERT INTO #Recipients 
			(Email,FNamePrimary,LNamePrimary,FNameProfile,LNameProfile,MVDID,ICEGROUP,IsPrimary,Date,
			UserAccessed,UserFacility,UserFacilityID,AppAccessed,RecordId,AccessReason,ChiefComplaint,EMSNote,CancelNotification,
			CancelNotifyReason)
		select '','','',
			(SELECT TOP 1 FIRSTNAME FROM MainPersonalDetails b WHERE b.ICENUMBER = a.MVDID),
			(SELECT TOP 1 LASTNAME FROM MainPersonalDetails b WHERE b.ICENUMBER = a.MVDID),
			MVDID,
			(select TOP 1 ICEGROUP from dbo.MainICENUMBERGroups c WHERE c.ICENUMBER = a.MVDID),
			(select TOP 1 MAINACCOUNT from dbo.MainICENUMBERGroups c WHERE c.ICENUMBER = a.MVDID),
			CREATED,a.USERNAME,
			(select TOP 1 COMPANY from mainEMS where email = a.USERNAME or UserName = a.username),
			userFacilityID,
			LOCATIONID,RecordId,AccessReason,ChiefComplaint,EMSNote,CancelNotification,
			CancelNotifyReason
		from dbo.MVD_AppRecord a
		where Action = 'LOOKUP' AND ResultStatus = 'SUCCESS' AND ResultCount='1' 
			and AlertSendDate is null and LocationID <> 'MVDSupport'
		order by CREATED
		
		-- Set IsHealthPlanMember flag for selected records
		update #Recipients set IsHealthPlanMember = 1
		where MVDID in
		(
			select a.MVDID 
			from MVD_AppRecord a
				inner join Link_MVDID_CustID b on a.MVDID = b.MVDID
			where a.Action = 'LOOKUP' AND a.ResultStatus = 'SUCCESS' 
				AND a.ResultCount='1' and a.AlertSendDate is null
		)	

		-- Don't set multiple alerts which occured within 12 hours
		-- Check if a record with the same MVDId, Facility and accessed time within 12 hours already exists
		-- in MVD_AppRecord and a notification was sent
		-- Note: to simplify the search check if same user accessed the record. However, we should check
		-- if the record was access within the same facility
		while exists (select recordid from #Recipients where isProcessed = 0 )
		BEGIN
			select top 1    
				@_mvdid = MVDID, 
				@_AccDate = Date,
				@_UserAcc = UserAccessed,
				@_UserAccFacility = UserFacility,
				@_UserAccFacilityID = UserFacilityID,
				@_RecordId = RecordId
			from #Recipients 
			where isProcessed = 0 
			order by Date
	
			-- Note: If the notification was cancelled, don't consider it as sent
			if exists ( select recordID from MVD_AppRecord 
				where MVDId = @_mvdid 
					and UserFacilityID = @_UserAccFacilityID			-- and UserName = @_UserAcc 
					and Created  > dateadd(hour,-12,@_AccDate) 
					and Created  < dateadd(hour,12,@_AccDate)
					and Action = 'LOOKUP' AND ResultStatus = 'SUCCESS' 
					and ResultCount='1' 
					and AlertSendDate is not null and (status is null or status not like 'ignore%') )
				or exists ( select recordId from #Recipients
				where MVDID = @_mvdid 
					and UserFacilityID = @_UserAccFacilityID			-- and UserAccessed = @_UserAcc
					and isProcessed = '1'
					and CancelNotification = '0'
					and Date  > dateadd(hour,-12,@_AccDate) )
			begin
				-- Alert was already sent
				delete from #Recipients where RecordId = @_RecordId
				
				update MVD_AppRecord set AlertSendDate = '1900/01/01', Status = 'Ignore: Already Sent'
				where RecordId = @_RecordId
			end			
			else
			begin
				 update #Recipients set isProcessed = 1 where RecordId = @_RecordId
			end			
		END

		-- Reset
		update #Recipients set isProcessed = 0

		--------------- SET EMAIL, NAME AND INSERT RECORDS OF ALL CONTACTS WHICH SHOULD BE NOTIFIED
		---------------	ABOUT THE RECORD ACCESS
		while exists (select recordid from #Recipients where isProcessed = 0)
		BEGIN
			select top 1    
				@_mvdid = MVDID, 
				@_group = ICEGROUP, 
				@_FNameProf = FNameProfile, 
				@_LNameProf = LNameProfile,
				@_isprim = IsPrimary,
				@_AccDate = Date,
				@_UserAcc = UserAccessed,
				@_UserAccFacility = UserFacility,
				@_AppAccessed = AppAccessed,
				@_RecordId = RecordId,
				@_AccessReason = AccessReason,
				@_ChiefComplaint = ChiefComplaint,
				@_EMSNote = EMSNote,
				@_CancelNotification = CancelNotification,
				@_CancelNotifyReason = CancelNotifyReason,
				@IsHealthPlanMember = IsHealthPlanMember
			from #Recipients 
			where isProcessed = 0
			order by Date

				-- Record lookup to 'EdVisitHistory'
				-- Get Physician name and Facility name
				declare @physFName varchar(50), @physLName varchar(50), @physPhone varchar(50)
				
				select @physFName = FirstName, @physLName=LastName, @physPhone=Phone
					from MainEMS where Email=@_UserAcc or Username = @_UserAcc

				-- since we currently don't store physician phone, get it from contact person of the facility
				select @physPhone=contactphone  
				from mainemshospital where name = @_UserAccFacility

				if( @physLName is null and @_UserAccFacility is null)
				begin
					-- facility has CredentialsRequired=false so they are using ContactInfo account
					-- to log in, so get that info
					select @_UserAccFacility=name,@physLName=contactname,@physPhone=contactphone  
					from mainemshospital where contactemail = @_UserAcc
				end

				--set @est = null
				
				--set @est = dbo.ConvertUTCtoEST(@_AccDate)

				-- 09/15/2015 Commented out because the lookup feature is currently not used in ER settings
				--EXEC Set_EDVisitHistory @_mvdid, @_AccDate, @_UserAccFacility, @physFName, @physLName, 
				--	@physPhone, 'EMS - Lookup', @_RecordId, @_AccessReason
				-- End EdVisitHistory

				-- Only for members who don't belong to health plans
				if(@IsHealthPlanMember = 0)
				begin
					if(@_isprim = '1')
					begin
						-- the profile owner is a primary owner of the account
						-- get email address
						select @email = email from MainPersonalDetails where icenumber = @_mvdid

						select @primFName = FNameProfile, @primLName=LNameProfile from #Recipients
						where MVDID = @_mvdid
					end
					else
					begin
						-- find the primary owner of the account
						select top 1 @primMVDID=ICENUMBER from dbo.MainICENUMBERGroups 
						where icegroup = @_group and mainaccount = '1'
						
						-- get the primary owner name and email
						select @email = email,@primFName = FirstName, @primLName=LastName  
						from MainPersonalDetails where icenumber = @primMVDID
					end

					update #Recipients set email = @email, FNamePrimary = @primFName, LNamePrimary = @primLName
					where recordid = @_RecordId

					-- Don't notify contacts if that was requested
					if(@_CancelNotification is null or @_CancelNotification = 0)
					begin
						-- Insert contacts who should  be notified
						INSERT INTO #Recipients 
							(Email,FNamePrimary,LNamePrimary,FNameProfile,LNameProfile,MVDID,ICEGROUP,IsPrimary,Date,
							UserAccessed,UserFacility,AppAccessed,RecordId,ChiefComplaint,EMSNote,isProcessed,
							CancelNotification,CancelNotifyReason)
						(
							select EmailAddress,FirstName,LastName,@_FNameProf, @_LNameProf,@_mvdid, @_group,0,
								@_AccDate,@_UserAcc,@_UserAccFacility,@_AppAccessed,@_RecordId,@_ChiefComplaint,@_EMSNote,'1',
								@_CancelNotification,@_CancelNotifyReason
							from maincareinfo 
							where icenumber  = @_mvdid and EmailAddress is not null 
								and len(EmailAddress) > 0 and  NotifyByEmail = 1
						)	

						if( @_UserAccFacility is null)
						begin
							select @_UserAccFacility = 'emergency professionals';
						end

						-- Insert SMS records for contact people who should be notified
						INSERT INTO SendSMS
							(RecordAccessID,Phone,Text)
						(
							-- convert access time to Eastern Standard
							-- Since most phone service providers allow 160 characters messages, we need to limit names
							select @_RecordId, PhoneCell, 
								' ' + isnull(LEFT(@primFName,10) + ' ','') + isnull(LEFT(@primLName,20)+'''s','') + 
								' MyVitalData record was accessed by ' + LEFT(@_UserAccFacility,35) + ' on ' + convert(varchar(30), dbo.ConvertUTCtoEST( @_AccDate )) + ' EST. ' + 
								'For info call 888-683-3292'  from maincareinfo
							where icenumber  = @_mvdid and PhoneCell is not null 
								and len(PhoneCell) > 0 and  NotifyBySMS = 1
						)
					end
				end
			--end

			update #Recipients set isProcessed = 1 where recordId = @_RecordId


		END -- End While

		-- FORWARD TO QA on test environments; ********** 
		if( db_name() != 'MyVitalDataLive' and db_name() != 'MyVitalDataDemo')
		begin
			update #Recipients set Email = 'alerts@vitaldatatech.com'
		end

		--	SEND EMAIL	
		OPEN SendMail
		declare @tempESTDate datetime

		FETCH NEXT FROM SendMail INTO @email, @primFName, @primLName, @_mvdid, @_FNameProf, @_LNameProf,
			@_isprim,@_AccDate,@_UserAcc,@_AppAccessed,@_RecordId,@IsHealthPlanMember, @_UserAccFacility,
			@_AccessReason,@_ChiefComplaint,@_EMSNote,@_CancelNotification,@_CancelNotifyReason
		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- convert access time to Eastern Standard				
			--select @_AccDate = dbo.ConvertUTCtoEST(@_AccDate)

			-- SEND EMAIL FOR EVERY RECORD NOT BELONGING TO HEALTH PLAN
			if( @IsHealthPlanMember <> 1)
			begin

				-- Don't notify contacts if that was requested
				if(@_CancelNotification is null or @_CancelNotification = 0)
				begin
					set @tempESTDate = dbo.ConvertUTCtoEST(@_AccDate)

					EXEC SendMailOnMVD_RecordAccess @RecipientEmail=@email,
						@RecipentFName=@primFName,
						@RecipentLName=@primLName,
						@MVDID=@_mvdid,
						@ProfileOwnerFName=@_FNameProf,
						@ProfileOwnerLName=@_LNameProf,
						@IsPrimary=@_isprim,
						@Date=@tempESTDate,
						@UserAccessed=@_UserAcc,
						@AppAccessed=@_UserAccFacility,
						@ChiefComplaint=@_ChiefComplaint,
						@EMSNote=@_EMSNote

					-- Update the record that the email was sent
					update dbo.MVD_AppRecord set AlertSendDate = getutcdate(),Status = 'Success' where RecordId = @_RecordId
				end
				else
				begin
					-- Update the record so it won't be processed again
					update dbo.MVD_AppRecord set AlertSendDate = '1900/01/01', Status = 'Ignore: Requested Cancel'
					where RecordId = @_RecordId
				end
			end
			else
			begin

				-- Create alert for health plan agent if MVD member is mapped to Health Plan
				declare @FacilityId int, 
					@CustomerIDList varchar(100) -- in case same MVD Member is mapped to different Health Plan
												-- records in different customers
				set @CustomerIDList = ''

				select @FacilityId = ID from mainEmsHospital where name = @_UserAccFacility
				
				select @CustomerIDList = @CustomerIDList + convert(varchar,Cust_ID,10) + ',' 
				from Link_MVDID_CustID
				where MVDId = @_mvdid

				-- remove last comma
				if(len(isnull(@CustomerIDList,'')) > 0)
				begin
					set @CustomerIDList = substring(@CustomerIDList,0,len(@CustomerIDList))
				end


	--			select @_RecordId as '@_RecordId',@_mvdid as '@_mvdid',@_FNameProf as '@_FNameProf' ,@_LNameProf as '@_LNameProf',
	--				@_AccDate as '@_AccDate',@FacilityId as '@FacilityId', @_UserAccFacility as '@_UserAccFacility',
	--				@CustomerIDList as '@CustomerIDList'

				EXEC Set_HPAgentAlert 
					@RecordAccessId = @_RecordId,
					@MVDId = @_mvdid,
					@MemberFName = @_FNameProf,
					@MemberLName = @_LNameProf,
					@DateTime = @_AccDate,
					@FacilityID = @FacilityId,
					@CustomerIDList = @CustomerIDList,
					@ChiefComplaint=@_ChiefComplaint,
					@EMSNote=@_EMSNote,
					@SourceName = 'EMS - Lookup'

				EXEC Set_DoctorAlert
					@RecordAccessId = @_RecordId,
					@MVDId = @_mvdid,
					@MemberFName = @_FNameProf,
					@MemberLName = @_LNameProf,
					@DateTime = @_AccDate,
					@Facility = @_UserAccFacility,
					@ChiefComplaint =@_ChiefComplaint,
					@EMSNote =@_EMSNote

				-- Update the record that the email was sent
				update dbo.MVD_AppRecord 
				set AlertSendDate = getutcdate(), Status = 'Success: HP record processed' where RecordId = @_RecordId
			end

			FETCH NEXT FROM SendMail INTO @email, @primFName, @primLName, @_mvdid, @_FNameProf, @_LNameProf,
				@_isprim,@_AccDate,@_UserAcc,@_AppAccessed,@_RecordId,@IsHealthPlanMember, @_UserAccFacility,
				@_AccessReason,@_ChiefComplaint,@_EMSNote,@_CancelNotification,@_CancelNotifyReason
		END

	END TRY
	BEGIN CATCH

		-- record
		EXEC SP_ExportXMLCatchError

		declare @messageSubject varchar(200), @msgBody varchar(1000)

		if(db_name() = 'MyVitalDataDemo')
		begin
			set @messageSubject = 'DEMO: MVD send access alert error'		
		end
		else if(db_name() = 'MyVitalDataTest1')
		begin
			set @messageSubject = 'TEST_1 TEST: MVD send access alert error'		
		end
		else if(db_name() = 'MyVitalDataTest2')
		begin
			set @messageSubject = 'TEST_2 TEST: MVD send access alert error'		
		end
		else if(db_name() = 'MyVitalDataDev')
		begin
			set @messageSubject = 'DEV TEST: MVD send access alert error'		
		end
		else
		begin
			set @messageSubject = 'MVD send access alert error'
		end

		set @msgBody = 'Procedure:' + isnull(ERROR_PROCEDURE(),'') + ' - '    
				+ isnull(ERROR_MESSAGE(),'') + ' Line: ' + isnull(LTrim(Str(ERROR_LINE())),'')

		-- send email notification
		EXEC msdb.dbo.sp_send_dbmail 
		@recipients = @NotifyOnError, 
		@profile_name = 'VD-APP01',
		@body = @msgBody , 
		@subject = @messageSubject

	END CATCH

	-- Release resources
	CLOSE SendMail
	DEALLOCATE SendMail
	drop table #Recipients
END