/****** Object:  Procedure [dbo].[ReProcessDischargeData_MembersNotFound]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[ReProcessDischargeData_MembersNotFound]
AS
BEGIN
	SET NOCOUNT ON;

	declare @tempRecords TABLE(
		recordID int identity(1,1),
		sourceRecordID int,
		MVDID varchar(20),
		GUID varchar(50),
		MRN varchar(50),
		CSN varchar(50),
		PATIENT_NAME varchar(50),
		DOB date,
		ADMIT_DATE datetime,
		CLASS varchar(50),
		MEDICAIDE_NUMBER varchar(50),
		VISIT_REASON varchar(100),
		PCP varchar(50),
		DISCHARGE_DISPOSITION varchar(100),
		PATIENTS_HOME_NUMBER varchar(50),
		DischargeRecordType varchar(50),		-- "Dal Emergency", or "Dal First Care"
		Created datetime,
		DischargeRecordSource varchar(50),
		MemberFName varchar(50),
		MemberLName varchar(50),		
		AdmitPlace varchar(100),
		Cust_id int,
		TerminationDate datetime,
		isProcessed bit default(0)
	)

	declare @mvdid varchar(30), 
		@recordID int,
		@sourceRecordID int,
		@GUID varchar(50),
		@MRN varchar(50),
		@CSN varchar(50),
		@PATIENT_NAME varchar(50),
		@DOB date,
		@ADMIT_DATE datetime,
		@CLASS varchar(50),
		@MEDICAIDE_NUMBER varchar(50),
		@VISIT_REASON varchar(100),
		@PCP varchar(50),
		@DISCHARGE_DISPOSITION varchar(100),
		@PATIENTS_HOME_NUMBER varchar(50),
		@DischargeRecordType varchar(50),
		@DischargeRecordSource varchar(50),
		@facilityID int,
		@facilityName varchar(50),
		@facilityPhone varchar(20),
		@customerID int,
		@MemberFName varchar(50),
		@MemberLName varchar(50),
		@AdmitPlace varchar(100),
		@SourceName varchar(50),
		@newPhone varchar(50),
		@oldPhone varchar(50),
		@historyPhone varchar(50),
		@utcAdmitDate datetime,
		@terminationDate datetime,
		@curDate datetime,
		@TimeZone	VARCHAR(4)			

	declare @est datetime

	declare @IsHealthPlanMember bit

	declare @NotifyOnError varchar(200)

	set @NotifyOnError = 'mgrigoriev@vitaldatatech.com'
	
	set @SourceName = 'Discharge Data'
	
	select @curDate = GETDATE()

	insert into @tempRecords(sourceRecordID,MVDID,GUID,MRN,CSN,PATIENT_NAME,DOB,ADMIT_DATE,
		CLASS,MEDICAIDE_NUMBER,VISIT_REASON,PCP,DISCHARGE_DISPOSITION,PATIENTS_HOME_NUMBER,DischargeRecordType,Cust_id,
		MemberFName,MemberLName, TerminationDate, DischargeRecordSource, AdmitPlace)
	-- Check to get data whose IsProcessed = 0 and processAttemptCount = 1 because members not found 
	select 
		ID,i.icenumber,GUID,MRN,CSN,PATIENT_NAME,h.DOB,ADMIT_DATE,
		CLASS,MEDICAIDE_NUMBER,VISIT_REASON,PCP,DISCHARGE_DISPOSITION,PATIENTS_HOME_NUMBER,Type,li.Cust_ID,
		p.FirstName,p.LastName,i.TerminationDate, h.Source, h.AdmitPlace--, h.Created
	from DISCHARGE_DATA_History h
		left join MainInsurance i on h.MEDICAIDE_NUMBER = i.Medicaid
		left join Link_MVDID_CustID li on i.ICENUMBER = li.MVDId
		left join MainPersonalDetails p on p.ICENUMBER = li.MVDId
	where IsProcessed = 0 and processAttemptCount = 1 and ISNULL(h.MEDICAIDE_NUMBER,'') <> ''
	UNION
	-- Check Patient_Name with MainpersonalDetails LastName+','+FirstName where Medicaide_Number is not provided in Discharge_Data_History Table
	select 
		ID,i.icenumber,GUID,MRN,CSN,PATIENT_NAME,h.DOB,ADMIT_DATE,
		CLASS,MEDICAIDE_NUMBER,VISIT_REASON,PCP,DISCHARGE_DISPOSITION,PATIENTS_HOME_NUMBER,Type,li.Cust_ID,
		p.FirstName,p.LastName,i.TerminationDate, h.Source, h.AdmitPlace--, h.Created
	from DISCHARGE_DATA_History h
	left join MainPersonalDetails p on h.PATIENT_NAME = P.LastName+','+P.FirstName and CONVERT(date,h.DOB,100) = CONVERT(Date,P.DOB,100)
		left join MainInsurance i on p.icenumber = i.icenumber--h.MEDICAIDE_NUMBER = i.Medicaid
		left join Link_MVDID_CustID li on i.ICENUMBER = li.MVDId
	where IsProcessed = 0 and processAttemptCount = 0 and ISNULL(h.MEDICAIDE_NUMBER,'') = '' and i.icenumber is not null and ADMIT_DATE <> '1900-01-01 00:00:00.000'
	UNION
	-- Check Patient_Name with MainpersonalDetails FirstName+','+LastName where Medicaide_Number is not provided in Discharge_Data_History Table
	select 
			ID,i.icenumber,GUID,MRN,CSN,PATIENT_NAME,h.DOB,ADMIT_DATE,
			CLASS,MEDICAIDE_NUMBER,VISIT_REASON,PCP,DISCHARGE_DISPOSITION,PATIENTS_HOME_NUMBER,Type,li.Cust_ID,
			p.FirstName,p.LastName,i.TerminationDate, h.Source, h.AdmitPlace--, h.Created
		from DISCHARGE_DATA_History h
		left join MainPersonalDetails p on h.PATIENT_NAME = P.FirstName+' '+P.LastName and CONVERT(date,h.DOB,100) = CONVERT(Date,P.DOB,100)
			left join MainInsurance i on p.icenumber = i.icenumber--h.MEDICAIDE_NUMBER = i.Medicaid
			left join Link_MVDID_CustID li on i.ICENUMBER = li.MVDId
		where IsProcessed = 0 and processAttemptCount = 0 and ISNULL(h.MEDICAIDE_NUMBER,'') = '' and i.icenumber is not null and ADMIT_DATE <> '1900-01-01 00:00:00.000'
	UNION
	-- Check Patient_Name with MainpersonalDetails LastName+','+FirstName where Medicaide_Number is provided in Discharge_Data_History Table but does not match with MainInsurance table
	select 
		ID,i.icenumber,GUID,MRN,CSN,PATIENT_NAME,h.DOB,ADMIT_DATE,
		CLASS,MEDICAIDE_NUMBER,VISIT_REASON,PCP,DISCHARGE_DISPOSITION,PATIENTS_HOME_NUMBER,Type,li.Cust_ID,
		p.FirstName,p.LastName,i.TerminationDate, h.Source, h.AdmitPlace--, h.Created
	from DISCHARGE_DATA_History h
	left join MainPersonalDetails p on h.PATIENT_NAME = P.LastName+','+P.FirstName and CONVERT(date,h.DOB,100) = CONVERT(Date,P.DOB,100)
		left join MainInsurance i on p.icenumber = i.icenumber--h.MEDICAIDE_NUMBER = i.Medicaid
		left join Link_MVDID_CustID li on i.ICENUMBER = li.MVDId
	where IsProcessed = 0 and processAttemptCount = 1 and ISNULL(h.MEDICAIDE_NUMBER,'') <> '' and i.icenumber is not null and ADMIT_DATE <> '1900-01-01 00:00:00.000'
	UNION
	-- Check Patient_Name with MainpersonalDetails FirstName+','+LastName where Medicaide_Number is provided in Discharge_Data_History Table but does not match with MainInsurance table
	select 
			ID,i.icenumber,GUID,MRN,CSN,PATIENT_NAME,h.DOB,ADMIT_DATE,
			CLASS,MEDICAIDE_NUMBER,VISIT_REASON,PCP,DISCHARGE_DISPOSITION,PATIENTS_HOME_NUMBER,Type,li.Cust_ID,
			p.FirstName,p.LastName,i.TerminationDate, h.Source, h.AdmitPlace--, h.Created
		from DISCHARGE_DATA_History h
		left join MainPersonalDetails p on h.PATIENT_NAME = P.FirstName+' '+P.LastName and CONVERT(date,h.DOB,100) = CONVERT(Date,P.DOB,100)
			left join MainInsurance i on p.icenumber = i.icenumber--h.MEDICAIDE_NUMBER = i.Medicaid
			left join Link_MVDID_CustID li on i.ICENUMBER = li.MVDId
		where IsProcessed = 0 and processAttemptCount = 1 and ISNULL(h.MEDICAIDE_NUMBER,'') <> '' and i.icenumber is not null and ADMIT_DATE <> '1900-01-01 00:00:00.000'
	ORDER BY i.ICENUMBER


	update DISCHARGE_DATA_History set processAttemptCount = 1, ProcessNote = 'Member not found'
	where ID in(
		select t.sourceRecordID from @tempRecords t where t.MVDID is null
	)

	delete from @tempRecords where MVDID is null
			
	while exists(select recordID from @tempRecords where isProcessed = 0)
	BEGIN
	
		select top 1 @mvdid = MVDID, 
			@recordID = recordID,
			@sourceRecordID = sourceRecordID,
			@GUID = guid,
			@MRN = mrn,
			@CSN = csn,
			@PATIENT_NAME = PATIENT_NAME,
			@DOB = dob,
			@ADMIT_DATE = ADMIT_DATE,
			@CLASS = class,
			@MEDICAIDE_NUMBER = MEDICAIDE_NUMBER,
			@VISIT_REASON = VISIT_REASON,
			@PCP = pcp,
			@DISCHARGE_DISPOSITION = DISCHARGE_DISPOSITION,
			@PATIENTS_HOME_NUMBER = PATIENTS_HOME_NUMBER,
			@DischargeRecordType = DischargeRecordType,
			@customerID = Cust_id,
			@MemberFName = MemberFName,
			@MemberLName = MemberLName,
			@terminationDate = TerminationDate,
			@DischargeRecordSource = DischargeRecordSource,
			@AdmitPlace = AdmitPlace
		from @tempRecords 
		where isProcessed = 0
		order by recordID

		--select	@recordID as 'processing', @sourceRecordID as '@sourceRecordID',  @mvdid

		BEGIN TRY

			--PRINT 'sourceRecordID: ' + CONVERT(VARCHAR,ISNULL(@sourceRecordID,0)) + ' ' + CONVERT(VARCHAR,GETDATE())
			declare @splitLocation int
			
			if(@DischargeRecordSource like '%Driscoll%')
			begin
				if(@DischargeRecordSource = 'Driscoll Excel Report 1')
					begin
					set @facilityName = 'Driscoll'
					end
				else
					begin
					set @splitLocation =  charindex (':', @AdmitPlace)
					
					if (@splitLocation > 0)
						begin
						set @splitLocation = @splitLocation - 1
						end
					else
						begin
						set @splitLocation = 50
						end

					set @facilityName = rtrim(substring(@AdmitPlace, 1, @splitLocation))
					end
			end
			else if(@DischargeRecordSource = 'Cook report')
			begin
				set @facilityName = 'Cook Children' + '''s Medical Center'
			end
			else if(@DischargeRecordSource = 'Presbyterian Hospital')
			begin
				set @facilityName = 'Presbyterian Hospital'
			end
			else if(@DischargeRecordSource = 'Methodist report')
			begin
				select @facilityName =
					case ISNULL(@AdmitPlace,'')
					when 'MCMC' then 'Methodist Charlton Medical Center'
					when 'MDMC' then 'Methodist Dallas Medical Center'
					when 'MMMC' then 'Methodist Mansfield Medical Center'
					when 'MRMC' then 'Methodist Richardson Medical Center'
					end
			end
			else if(@DischargeRecordSource = 'Hunt Regional Medical Center')
			begin
				set @facilityName = @DischargeRecordSource
			end
			else
			begin
				-- NOTE: in later time discharge data table will be populated with data from 
				--	different hospitals.
				-- TODO: make it dynamic
				set @facilityName = 'Children' + '''s Medical Center'				
			end
		
			select 
				@facilityID = ID,
				@facilityPhone = ContactPhone,
				@TimeZone =  CASE WHEN [STATE] in ('CT','DE','GA','ME','MD','MA','NH','NJ','NY','NC','SC','OH','PA','RI','VT','VA','WV','FL','MI','AL', 'DC','IN','KY') THEN 'EST'
								  WHEN [STATE] in ('ND','SD','AR','IL','IA','LA','MN','MS','MO','OK','WI','KS','MI','NE','TN','TX', 'AL') THEN 'CST'
								  WHEN [STATE] in ('NM','WY','UT','CO','ID','AZ','MT') THEN 'MST'
								  WHEN [STATE] in ('WA','OR','CA','NV') THEN 'PST' END 
			from MainEMSHospital
			where Name = @facilityName			
		
			-- Don't set multiple alerts which occured within 12 hours		
			-- Note: Check for duplicate entries
			if exists ( select recordID from @tempRecords 
				where MVDId = @mvdid 
					AND recordID <> @recordID
					and ADMIT_DATE  between dateadd(hour,-12,@ADMIT_DATE) AND dateadd(hour,12,@ADMIT_DATE)
					and isProcessed = 1
				)				
			begin			
				-- Duplicate record was already processed
				update @tempRecords set isProcessed = 1 where recordID = @recordID
				
				update DISCHARGE_DATA_History set isProcessed = 1, ProcessDate = GETUTCDATE(), 
					ProcessNote = 'Ignore: Duplicate Record'
				where Id = @sourceRecordID
			end			
			else if (@terminationDate is null OR (@terminationDate is not null AND @terminationDate > DATEADD(MM,-2,@curDate)))
			begin
				if (@TimeZone = 'EST')
				begin
					set @utcAdmitDate = dbo.ConvertESTtoUTC(@ADMIT_DATE)
				end
				else if (@TimeZone = 'CST')
				begin
					set @utcAdmitDate = dbo.ConvertCTtoUTC(@ADMIT_DATE)
				end
				else if (@TimeZone = 'MST')
				begin
					set @utcAdmitDate = dbo.ConvertMTtoUTC(@ADMIT_DATE)
				end
				else if (@TimeZone = 'PST')
				begin
					set @utcAdmitDate = dbo.ConvertPTtoUTC(@ADMIT_DATE)
				end
				else
				begin
					set @utcAdmitDate = @ADMIT_DATE
				end
				--select @utcAdmitDate as '@VisitDate'
				--select 'about to set visit and alert ' + @mvdid + ' recordID: ' + convert(varchar(10),@recordID)
				--	+ ' SourceRecordID: ' + convert(varchar(10),@sourceRecordID)
				
				EXEC Set_EDVisitHistory  
				   @ICENUMBER = @mvdid,
				  @VisitDate = @utcAdmitDate,
				  @FacilityName = @facilityName,
				  @PhysicianFirstName  = '',
				  @PhysicianLastName = '',
				  @PhysicianPhone = @facilityPhone,
				  @Source = @SourceName,
				  @SourceRecordID = @sourceRecordID,
				  @AccessReason = @VISIT_REASON,
				  @OriginalVisitType = @DischargeRecordType

				EXEC Set_HPAgentAlert 
					@RecordAccessId = @sourceRecordID,
					@MVDId = @mvdid,
					@MemberFName = @MemberFName,
					@MemberLName = @MemberLName,
					@DateTime = @utcAdmitDate,
					@FacilityID = @FacilityId,
					@CustomerIDList = @customerID,
					@ChiefComplaint = @VISIT_REASON,
					@EMSNote = '',
					@DISCHARGE_DISPOSITION = @DISCHARGE_DISPOSITION,
					@SourceName = @SourceName,
					@DischargeRecordType = @DischargeRecordType
					
				update DISCHARGE_DATA_History set IsProcessed = 1, ProcessDate = GETUTCDATE(), 
					ProcessNote = 'Success'
				where ID = @sourceRecordID

				---------------- Start Home Phone
				select @oldPhone = '', @historyPhone = ''

				select @newPhone = REPLACE(REPLACE(REPLACE(isnull(@PATIENTS_HOME_NUMBER,''),'-',''),'(',''),')','')

				select @oldPhone = isnull(HomePhone,'')
				from MainPersonalDetails
				WHERE ICENUMBER = @mvdid

				if( @newPhone <> '' AND @newPhone <> '9999999999' AND @oldPhone <> @newPhone)
				begin
					if not exists( select mvdid from dbo.HPFieldValueHistory
						where mvdid = @mvdid and tableName = 'MainPersonalDetails' and FieldName = 'HomePhone' )
					begin
						-- Backup value provided by HP into history table
						insert into dbo.HPFieldValueHistory (mvdid, tableName, FieldName, FieldValue)
						values (@mvdid, 'MainPersonalDetails', 'HomePhone', @oldPhone)
					end

					--Update Phone
					UPDATE MainPersonalDetails SET 
						HomePhone = LEFT(@newPhone,10) -- DJS 11/16/2015 truncate value to match destination table field size
					WHERE ICENUMBER = @mvdid

					-- TODO: Notify HP about HomePhone change
				end
				---------------- End Home Phone
			end
			else
			begin
				--select 'expired insurance ' + @mvdid
	
				EXEC Set_EDVisitHistory  @mvdid, @utcAdmitDate, @facilityName, '', '', 
					@facilityPhone, @SourceName, @sourceRecordID, @VISIT_REASON
					
				update DISCHARGE_DATA_History set IsProcessed = 1, ProcessDate = GETUTCDATE(), 
					ProcessNote = 'Expired insurance'
				where ID = @sourceRecordID					
			end

			update @tempRecords set isProcessed = 1 where recordID = @recordID

		END TRY
		BEGIN CATCH
			-- DJS 11/16/2015 remove err'd record from our 'to do' list so we can move on to the next
			delete from @tempRecords where recordID = @recordID

			-- record
			EXEC SP_ExportXMLCatchError

			--declare @messageSubject varchar(200), @msgBody varchar(1000)

			--set @messageSubject = db_name() + ': Discharge Data error'

			--set @msgBody = 'Procedure:' + isnull(ERROR_PROCEDURE(),'') + ' - '    
			--		+ isnull(ERROR_MESSAGE(),'') + ' Line: ' + isnull(LTrim(Str(ERROR_LINE())),'')
			--		+ nchar(13) + nchar(10)
			--		+ ' Data: ' + nchar(13) + nchar(10)
			--		+ '@mvdid = ' + isnull(@MVDID,'') + nchar(13) + nchar(10)
			--		+ '@ID = ' + isnull(convert(varchar(10),@id),'') + nchar(13) + nchar(10)
			--		+ '@GUID = ' + isnull(@guid,'') + nchar(13) + nchar(10)
			--		+ '@MRN = ' + isnull(@mrn,'') + nchar(13) + nchar(10)
			--		+ '@CSN = ' + isnull(@csn,'') + nchar(13) + nchar(10)
			--		+ '@PATIENT_NAME = ' + isnull(@PATIENT_NAME,'') + nchar(13) + nchar(10)
			--		+ '@DOB = ' + isnull(convert(varchar(20),@dob),'') + nchar(13) + nchar(10)
			--		+ '@ADMIT_DATE = ' + isnull(@ADMIT_DATE,'') + nchar(13) + nchar(10)
			--		+ '@CLASS = ' + isnull(@class,'') + nchar(13) + nchar(10)
			--		+ '@MEDICAIDE_NUMBER = ' + isnull(@MEDICAIDE_NUMBER,'') + nchar(13) + nchar(10)
			--		+ '@VISIT_REASON = ' + isnull(@VISIT_REASON,'') + nchar(13) + nchar(10)
			--		+ '@PCP = ' + isnull(@pcp,'') + nchar(13) + nchar(10)
			--		+ '@DISCHARGE_DISPOSITION = ' + isnull(@DISCHARGE_DISPOSITION,'') + nchar(13) + nchar(10)
			--		+ '@PATIENTS_HOME_NUMBER ' + isnull(@PATIENTS_HOME_NUMBER, '') + nchar(13) + nchar(10)
			--		+ '@DischargeRecordType ' + isnull(@DischargeRecordType, '') + nchar(13) + nchar(10)

			---- send email notification
			--EXEC msdb.dbo.sp_send_dbmail @recipients = @NotifyOnError, 
			--	@body = @msgBody , 
			--	@subject = @messageSubject

		END CATCH

	END -- End While

END