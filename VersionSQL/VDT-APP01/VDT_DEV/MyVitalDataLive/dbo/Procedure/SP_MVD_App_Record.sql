/****** Object:  Procedure [dbo].[SP_MVD_App_Record]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Records account access
-- =============================================
CREATE PROCEDURE [dbo].[SP_MVD_App_Record] 
		@MyVitalDataID varchar(30), @LocationID  varchar(30), @ApplicationID varchar(50),
        @UserName varchar(50), @AccessReason varchar(2000), @Action varchar(30), @Criteria varchar(max),
		@ResultStatus varchar(30), @ResultCount int, @RecordID int out
AS
BEGIN
	SET NOCOUNT ON;

	declare @ChiefComplaint varchar(100), @EmsNote varchar(1000), 
		@CancelNotification bit, @CancelNotifyReason varchar(100)
	declare @IDoc int				-- handle to XML

	-- Retrieve Chief Complaint if AccessReason was passed in XML format
	-- Note: other applications using MVD API don't have to format AccessReason in XML
	BEGIN TRY
		EXEC sp_xml_preparedocument @IDoc OUTPUT, @AccessReason

		SELECT @ChiefComplaint = CHIEFCOMPLAINT
		FROM OPENXML (@IDoc, 'ACCESSREASON', 2)
		with (CHIEFCOMPLAINT varchar(100))

		SELECT @EmsNote = EMSNOTE
		FROM OPENXML (@IDoc, 'ACCESSREASON', 2)
		with (EMSNOTE varchar(1000))

		SELECT @CancelNotification = CANCELNOTIFICATION
		FROM OPENXML (@IDoc, 'ACCESSREASON', 2)
		with (CANCELNOTIFICATION bit)

		SELECT @CancelNotifyReason = CANCELNOTIFYREASON
		FROM OPENXML (@IDoc, 'ACCESSREASON', 2)
		with (CANCELNOTIFYREASON varchar(100))

		if( @CancelNotification is null)
		begin
			set @CancelNotification = 0
		end

		EXEC sp_xml_removedocument @IDoc
	END TRY
	BEGIN CATCH
		select @ChiefComplaint = '', @EmsNote = '', @CancelNotification = 0, @CancelNotifyReason = ''
	END CATCH

	-- Get user facility
	declare @facility varchar(250), @facilityID int, @isSpecial int
	
	SELECT	TOP 1 @facility = COMPANY, @facilityID = CompanyID, @isSpecial = IsSpecial
	FROM	mainEMS
	WHERE	email = @UserName or username = @UserName

	IF @isSpecial = 1
	BEGIN
		INSERT INTO MVD_AppRecord 
				(AppId,LocationID,UserName,UserFacilityID,AccessReason,Action,MVDID,Criteria,ResultStatus,ResultCount, 
				ChiefComplaint,EMSNote, CancelNotification, CancelNotifyReason, AlertSendDate, Status)
		VALUES	(@ApplicationID,@LocationID,@UserName,@facilityID,@AccessReason,@Action,@MyVitalDataID,@Criteria,@ResultStatus, @ResultCount,
				@ChiefComplaint,@EMSNote,@CancelNotification, @CancelNotifyReason, '1900-01-01', 'Ignore: Case Manager Lookup')	

		set @RecordID = @@IDENTITY 
	END
	ELSE
	BEGIN
		INSERT INTO MVD_AppRecord 
				(AppId,LocationID,UserName,UserFacilityID,AccessReason,Action,MVDID,Criteria,ResultStatus,ResultCount, 
				ChiefComplaint,EMSNote, CancelNotification, CancelNotifyReason)
		VALUES	(@ApplicationID,@LocationID,@UserName,@facilityID,@AccessReason,@Action,@MyVitalDataID,@Criteria,@ResultStatus, @ResultCount,
				@ChiefComplaint,@EMSNote,@CancelNotification, @CancelNotifyReason)	

		set @RecordID = @@IDENTITY 

		EXEC Set_EDPatientStatus @userName = @UserName,	@mvdId = @MyVitalDataID
	END

	-- Notify system admin when record is successfully looked up
	--if( @Action = 'LOOKUP' AND @ResultStatus = 'SUCCESS' AND @ResultCount='1' and db_name() <> 'MyVitalDataDev')
	--begin
	--	declare @msgBody varchar(1000), @aSubject varchar(100)
		
	--	set @aSubject = db_name() + ': MVD record was looked up'
	--	set @msgBody = db_name() + nchar(13) + nchar(10)
	--	set @msgBody = @msgBody + 'MVD ID: ' + isnull(@MyVitalDataID,'') + nchar(13) + nchar(10)
	--	set @msgBody = @msgBody + 'Retrieved By: ' + isnull(@UserName,'') + nchar(13) + nchar(10)
	--	set @msgBody = @msgBody + 'At: ' + isnull(@facility,'') + nchar(13) + nchar(10)
	--	set @msgBody = @msgBody + 'Access Reason: ' + isnull(@AccessReason,'') + nchar(13) + nchar(10)
	--	set @msgBody = @msgBody + 'Lookup Record ID: ' + convert(varchar,isnull(@RecordID,''),20) + nchar(13) + nchar(10)

	--	EXEC msdb.dbo.sp_send_dbmail @recipients = 'mvd.support@vitaldatatech.com', 
	--		@body = @msgBody , 
	--		@subject = @aSubject
	--end
END