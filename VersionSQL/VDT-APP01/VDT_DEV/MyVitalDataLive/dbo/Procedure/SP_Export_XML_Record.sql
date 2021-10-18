/****** Object:  Procedure [dbo].[SP_Export_XML_Record]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[SP_Export_XML_Record]
	@MVDID VARCHAR (200),			-- It used to be single MVD ID, currently system accepts 
										-- multiple comma separated member IDs of one type, e.g. insurance member ID or SSN
	@LocationID VARCHAR (30), 
	@ApplicationID VARCHAR (50), 
	@UserName VARCHAR (50), 
	@AccessReason VARCHAR (2000), 
	@RequestType VARCHAR (50)=null, 
	@RecordCount INT OUTPUT, 
	@XmlOutput VARCHAR (MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--select @MVDID = '22333444,355373', 
--	@LocationID = 'MyVitalDataDev', 
--	@ApplicationID = '1D236AF7-B53F-4D79-90DC-7A0946D557D9', 
--	@UserName = 'johndoe@nowhere.com', 
--	@AccessReason = '<ACCESSREASON><IDTYPE>4</IDTYPE><CHIEFCOMPLAINT>HEADACHE</CHIEFCOMPLAINT><EMSNOTE>some note</EMSNOTE></ACCESSREASON>', 
--	@RequestType = ''

DECLARE @RESULT XML
declare @InsertedRecordId int, -- id of access history record
	@outputFormat varchar(50),
	@IDoc int,				-- handle to XML
	@canRetrieve bit,		-- set to FALSE when for some reason record shouldn't be retrieved, e.g. expired insurance
	@skipNotification bit,	-- set for MD loookup where it's not required to notify neither patient nor health plan
	@MemberInsId varchar(50), -- member's insurance ID 
	@curMemberID varchar(30),


	@curMVDID varchar(30),
	@curXMLRecord xml
	
select @canRetrieve = '1',
	@skipNotification = 0

BEGIN TRY

	declare @IDList table (memberID varchar(50))
	declare @recordsXML table(record xml)
	
	insert into @IDList(memberID)
	select data from dbo.Split(@MVDID,',')


--************
--select * from @IDList
--*********


	-- Check if notification should be ignored
	select @skipNotification = dbo.SkipNotifications(@ApplicationID, @RequestType)
		
	-- Get Output format
	BEGIN TRY
		EXEC sp_xml_preparedocument @IDoc OUTPUT, @AccessReason

		SELECT @outputFormat = OUTPUTFORMAT
		FROM OPENXML (@IDoc, 'ACCESSREASON', 2)
		with (OUTPUTFORMAT varchar(50))

		if( len(isnull(@outputFormat,'')) = 0)
		begin
			set @outputFormat = 'MVD'
		end

		EXEC sp_xml_removedocument @IDoc
	END TRY
	BEGIN CATCH
		-- Consider it MVD
		set @outputFormat = 'MVD'
	END CATCH
	
	
	
	while exists(select top 1 memberID from @IDList)
	begin
		select top 1 @curMemberID = memberID,
			@XmlOutput = null
		from @IDList
		
		-- In case patient id was provided other than MVD ID,
		-- the ID type is provided in AccessReason XML.
		-- ID type can be health plan customer ID, SSN, or other.
		EXEC dbo.Get_RequestedPatientMVDID @curMemberID, @AccessReason, @curMVDID output

--		select @curMemberID, @AccessReason, @curMVDID

		-- Check if the matching record exists
		select @RecordCount = count(*) 
		FROM dbo.MainPersonalDetails
		WHERE ICENUMBER = @curMVDID

		-- Check if the record should be returned
		select @canRetrieve = dbo.CanRetrieveRecord(@curMVDID)

		IF @RecordCount = 0 OR @canRetrieve = '0'
		begin
			SELECT @RESULT = '', 
				@RecordCount = 0
		end
		else
		begin

			EXEC Export_MemberRecord 
				@MVDID = @curMVDID,
				@outputFormat = @outputFormat,
				@ApplicationID = @ApplicationID,
				@XmlOutput = @curXMLRecord output

			insert into @recordsXML (record)
			values(@curXMLRecord)

			if(@skipNotification = 1)
			begin
				-- Store the request, without sending notification etc
				EXEC SP_MVD_App_Record_MD @curMVDID, @LocationID, @ApplicationID,@UserName, @AccessReason, 
					'LOOKUP', '', 'SUCCESS',@RecordCount, @InsertedRecordId out
			end
			else
			begin
				-- Record the request
				EXEC SP_MVD_App_Record @curMVDID, @LocationID, @ApplicationID,@UserName, @AccessReason, 
					'LOOKUP', '', 'SUCCESS',@RecordCount, @InsertedRecordId out
			end
		end
		
		delete from @IDList where memberID = @curMemberID

	end	-- end while	
		
	select @RecordCount = COUNT(record)
	from @recordsXML		

	select @XmlOutput = CONVERT(VARCHAR(MAX),(		
		select 
		getutcdate() as RetrievalUTC, 
		convert(varchar(5),@RecordCount) as RecordCount,
		(		
			SELECT (
				select record AS 'RECORD'
				from @recordsXML
				FOR XML PATH(''),TYPE, ELEMENTS	
			)
		)	
		FOR XML RAW('RECORDSET'),TYPE
	))
				
END TRY
BEGIN CATCH

	EXEC SP_ExportXMLCatchError

	if(@skipNotification = 1)
	begin
		-- Store the request, without sending notification etc
		EXEC SP_MVD_App_Record_MD @MVDID, @LocationID, @ApplicationID,@UserName, @AccessReason, 
			'LOOKUP', '', 'FAILED',@RecordCount, @InsertedRecordId out
	end
	else
	begin
		-- Record the request
		EXEC SP_MVD_App_Record @MVDID, @LocationID, @ApplicationID,@UserName, @AccessReason, 
			'LOOKUP', '', 'FAILED',-1, @InsertedRecordId out
	end

END CATCH

END