/****** Object:  Procedure [dbo].[SP_MVD_App_Record_MD]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 6/16/2009
-- Description:	Used only by MD lookup/search
-- =============================================
CREATE PROCEDURE [dbo].[SP_MVD_App_Record_MD] 
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
	declare @facility varchar(250), @facilityID int
	
	select TOP 1 @facility = COMPANY, @facilityID = CompanyID 
	from mainEMS where email = @UserName or username = @UserName

	insert into MVD_AppRecord_MD (AppId,LocationID,UserName,UserFacilityID,AccessReason,Action,MVDID,Criteria,ResultStatus,ResultCount, 
		ChiefComplaint,EMSNote, CancelNotification, CancelNotifyReason)
	VALUES (@ApplicationID,@LocationID,@UserName,@facilityID,@AccessReason,@Action,@MyVitalDataID,@Criteria,@ResultStatus, @ResultCount,
		@ChiefComplaint,@EMSNote,@CancelNotification, @CancelNotifyReason)	

	set @RecordID = @@IDENTITY 
END