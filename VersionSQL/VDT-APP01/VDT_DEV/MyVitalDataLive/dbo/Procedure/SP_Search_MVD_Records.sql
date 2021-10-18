/****** Object:  Procedure [dbo].[SP_Search_MVD_Records]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Sylvester Wyrzykowski
-- Create date: 01/04/2008
-- Description:	Returns the list of MyVitalData records
--		matching the criteria specified by passed 
--		arguments. The result is in XML format
-- =============================================
CREATE PROCEDURE [dbo].[SP_Search_MVD_Records]
	@LocationID varchar(30), 
	@ApplicationID varchar(50),
    @UserName varchar(50), 
	@AccessReason varchar(2000), 
	@Criteria varchar(max),
	@RequestType varchar(50) = null,		-- Set in MD lookup
	@OutputLimit int,
	@EMS varchar(50) = null,
	@UserID_SSO varchar(50) = null,
	@ResultCount int OUT,
	@XmlOutput varchar(max) OUT
AS
BEGIN

	SET NOCOUNT ON;

--select @LocationID = 'myvitaldatadev', 
--	@ApplicationID ='1D236AF7-B53F-4D79-90DC-7A0946D557D',
--    @UserName = 'johndoe@nowhere.com', 
--	@AccessReason ='<ACCESSREASON><IDTYPE>0</IDTYPE><CHIEFCOMPLAINT></CHIEFCOMPLAINT><EMSNOTE></EMSNOTE></ACCESSREASON>', 
--	@Criteria ='<CRITERIA><CRITERION><NAME>PATIENTFIRSTNAME</NAME><VALUE>john</VALUE></CRITERION><CRITERION><NAME>PATIENTLASTNAME</NAME><VALUE>doe</VALUE></CRITERION><CRITERION><NAME>PATIENTHOMESTATE</NAME><VALUE></VALUE></CRITERION></CRITERIA>',
--	@RequestType ='ER' , --= null,		-- Set in MD lookup
--	@OutputLimit = 10


	declare @MVDID varchar(20),
		@TempID varchar(20),
		@FirstName varchar(30),
		@LastName varchar(30),
		@HomeZipCode varchar(30),
		@HomeCity varchar(30),
		@HomeState varchar(30),
		@Phone varchar(30),
		@Gender varchar(30),
		@DOB varchar(30),
		@CUSTGROUP VARCHAR(30),	-- MVD Group matching MVDID
		@IDoc int,				-- handle to XML
		@sql varchar(max),		-- dynamic query
		@sqlBase varchar(max),	-- dynamic query
		@GenderID varchar(30),	-- gender lookup value
		@skipNotification bit	-- set for MD loookup where it's not required to notify neither patient nor health plan

	set @skipNotification = 0

	declare @tempXML XML

	declare @InsertedRecordId int -- id of access history record. not used here, but in record lookup store proc

	-- Temporary result table
	CREATE TABLE #TEMPRESULT
	(
		MVDID VARCHAR(30),
		LASTNAME VARCHAR(50),
		FIRSTNAME VARCHAR(50),
		GENDER VARCHAR(20),
		DOB VARCHAR(50),
		HEIGHTINCHES INT,
		WEIGHTLBS INT,
		MEDICAID VARCHAR(50),
		MEDICARENUMBER VARCHAR(50),
		isProcessed bit default(0)
	)

	-- Other MVD customers belonging to the same MVD Group
	CREATE TABLE #TEMPGROUPMEMBERS
	(
		MVDID VARCHAR(30)
	)

	EXEC sp_xml_preparedocument @IDoc OUTPUT, @Criteria

	BEGIN TRY

		-- Check if request was made by valid MD application
		select @skipNotification = dbo.SkipNotifications(@ApplicationID, @RequestType)

		-- Extract criterion values------
		-- Set to "any value" for the field if criterion not provided
		SELECT @MVDID = Value
		FROM OPENXML (@IDoc, 'CRITERIA/CRITERION', 2)
		WITH (Name varchar(50) './NAME',Value text './VALUE')
		where Name = 'MYVITALDATAID'

		-- In case patient id was provided other than MVD ID,
		-- the ID type is provided in AccessReason XML.
		-- ID type can be health plan customer ID, SSN, or other.
		EXEC dbo.Get_RequestedPatientMVDID @MVDID, @AccessReason, @TempID output

		if(len(isnull(@MVDID,'')) > 0 )
		begin 
			if(len(isnull(@TempID,'')) > 0)
			begin
				-- Patient ID was provided in the search criteria and
				-- MVD ID could be located using ID type provided in AccessReason
				set @MVDID = @TempID			
			end
			else
			begin
				-- Patient ID was provided in the search criteria but
				-- MVD ID couldn't be located using ID type provided in AccessReason
				set @MVDID = 'DUMMYID'
			end
		end

		SELECT @FirstName = Value
		FROM OPENXML (@IDoc, 'CRITERIA/CRITERION', 2)
		WITH (Name varchar(50) './NAME',Value text './VALUE')
		where Name = 'PATIENTFIRSTNAME'

		SELECT @LastName = Value
		FROM OPENXML (@IDoc, 'CRITERIA/CRITERION', 2)
		WITH (Name varchar(50) './NAME',Value text './VALUE')
		where Name = 'PATIENTLASTNAME'

		SELECT @HomeZipCode = Value
		FROM OPENXML (@IDoc, 'CRITERIA/CRITERION', 2)
		WITH (Name varchar(50) './NAME',Value text './VALUE')
		where Name = 'PATIENTHOMEZIPCODE'

		SELECT @HomeCity = Value
		FROM OPENXML (@IDoc, 'CRITERIA/CRITERION', 2)
		WITH (Name varchar(50) './NAME',Value text './VALUE')
		where Name = 'PATIENTHOMECITY'

		SELECT @HomeState = Value
		FROM OPENXML (@IDoc, 'CRITERIA/CRITERION', 2)
		WITH (Name varchar(50) './NAME',Value text './VALUE')
		where Name = 'PATIENTHOMESTATE'

		SELECT @Phone = Value
		FROM OPENXML (@IDoc, 'CRITERIA/CRITERION', 2)
		WITH (Name varchar(50) './NAME',Value text './VALUE')
		where Name = 'PATIENTPHONE'

		SELECT @Gender = Value
		FROM OPENXML (@IDoc, 'CRITERIA/CRITERION', 2)
		WITH (Name varchar(50) './NAME',Value text './VALUE')
		where Name = 'PATIENTGENDER'

		SELECT @DOB = Value
		FROM OPENXML (@IDoc, 'CRITERIA/CRITERION', 2)
		WITH (Name varchar(50) './NAME',Value text './VALUE')
		where Name = 'PATIENTDOB'

		---------------------------------

		-- Initialize gender is so the condition will be included in the query
		-- even if no matching genderid is found	
		select @GenderID = -999
		-- Get id of gender criterion from lookup table
		select @GenderID = genderID from LookupGenderID WHERE GenderName=@Gender

		-- Uncomment if want to check criteria values
--		select @MVDID as 'mvdid',@FirstName as 'First name', @LastName as 'Last name', 
--			@HomeZipCode as 'Zip', @HomeCity as 'city', @HomeState 'state', @Phone as 'phone',
--			@Gender  as 'Gender', @DOB as 'DOB'


		-- Include other members of the current member's group
		if len( isnull(@MVDID,'')) > 0
		BEGIN
			SELECT @CUSTGROUP = ICEGROUP FROM dbo.MainICENUMBERGroups 
			WHERE ICENUMBER=@MVDID

			IF @CUSTGROUP is NOT null AND len(@CUSTGROUP)>0 
			BEGIN
				INSERT INTO #TEMPGROUPMEMBERS
				SELECT ICENUMBER FROM dbo.MainICENUMBERGroups 
					WHERE ICEGROUP = @CUSTGROUP
			END
		END

		-- Build a select query
		select @sqlBase = 
		'select ICENUMBER,LASTNAME,FIRSTNAME,
			(SELECT GENDERNAME FROM dbo.LookupGenderID b WHERE b.GenderID=a.GenderID) as GENDER,
				CASE ISNULL(DOB,'''')
							WHEN '''' THEN NULL
							ELSE 
							(
								CONVERT(VARCHAR(30),ISNULL(DOB,''''),101)
							)
						END AS DOB,
			HEIGHTINCHES, WEIGHTLBS,
			(select top 1 Medicaid from mainInsurance i where i.icenumber = a.icenumber),
			(select top 1 MedicareNumber from mainInsurance i where i.icenumber = a.icenumber)
		from dbo.MainPersonalDetails a
		where 1=1 ' +
		case len(isnull(@MVDID,''))
		when 0 then '' 
		else 
			'and  ICENUMBER IN 
			(
				SELECT MVDID FROM #TEMPGROUPMEMBERS
			) '	
		end +
		case len(isnull(@HomeZipCode,''))  
		when 0 then '' 
		else ' and PostalCode= ''' + @HomeZipCode + ''''
		end +
		case len(isnull(@HomeCity,''))  
		when 0 then '' 
		else ' and City= ''' + @HomeCity + ''''
		end +
		case len(isnull(@HomeState,''))  
		when 0 then '' 
		else ' and State= ''' + @HomeState + ''''
		end +
		case len(isnull(@Phone,''))   
		when 0 then '' 
		else ' and (HomePhone= ''' + @Phone + ''' or CellPhone= ''' + @Phone + ''' or WorkPhone = ''' + @Phone + ''') '
		end +
		case len(isnull(@Gender,''))  
		when 0 then '' 
		--when 4 then '' -- length of initial value '-999'
		else ' and GenderID= ''' + @GenderID + ''''
		end +
		case len(isnull(@DOB,''))  
		when 0 then '' 
		else ' and DOB= ''' + @DOB + ''''
		end

		if(isnull(@LastName,'') <> '' OR isnull(@FirstName,'') <> '')
		begin
			select @sql = @sqlBase +
			case len(isnull(@LastName,'')) 
			when 0 then '' 
			else ' and LastName= ''' + @LastName + ''''
			end +
			case len(isnull(@FirstName,''))  
			when 0 then '' 
			else ' and FirstName= ''' + @FirstName + ''''
			end
		end
		else 
		begin
			select @sql = @sqlBase
		end

		select @sql as ' query'

		-- Insert records into temporary result table
		INSERT INTO #TEMPRESULT (MVDID,	LASTNAME,FIRSTNAME,	GENDER,	DOB,HEIGHTINCHES, 
			WEIGHTLBS, MEDICAID, MEDICARENUMBER)
		exec (@sql )

		if not exists(select mvdid from #TEMPRESULT) AND (isnull(@LastName,'') <> '' OR isnull(@FirstName,'') <> '')
		begin
			-- LIKE 'LastName%'
			select @sql = @sqlBase +
				case len(isnull(@LastName,'')) 
				when 0 then '' 
				else ' and LastName like ''' + @LastName  + '%'''
				end +
				case len(isnull(@FirstName,''))  
				when 0 then '' 
				else ' and FirstName= ''' + @FirstName + ''''
				end

			INSERT INTO #TEMPRESULT (MVDID,	LASTNAME,FIRSTNAME,	GENDER,	DOB,HEIGHTINCHES, 
				WEIGHTLBS, MEDICAID, MEDICARENUMBER)
			exec (@sql )

			if not exists(select mvdid from #TEMPRESULT)
			begin
				-- LIKE 'FirstName%' and 'LastName%'
				select @sql = @sqlBase +
					case len(isnull(@LastName,'')) 
					when 0 then '' 
					else ' and LastName like ''' + @LastName  + '%'''
					end +
					case len(isnull(@FirstName,''))  
					when 0 then '' 
					else ' and FirstName like ''' + @FirstName + '%'''
					end

				INSERT INTO #TEMPRESULT (MVDID,	LASTNAME,FIRSTNAME,	GENDER,	DOB,HEIGHTINCHES, 
					WEIGHTLBS, MEDICAID, MEDICARENUMBER)
				exec (@sql )
			end
		end


		--SELECT * FROM #TEMPRESULT

		declare @tempMvdid varchar(20)
		-- If an account is linked to health plan and there is insurance record with the same name
		-- and termination date on that insurance is older than current date
		-- the record CANNOT be displayed
		while exists (select mvdid from #tempresult where isprocessed = 0)
		begin
			select top 1 @tempMvdid = mvdid from #tempresult where isprocessed = 0

			if(dbo.CanRetrieveRecord(@tempMvdid) = 0)
			begin
				-- Remove from search result
				delete from #tempresult where mvdid = @tempMvdid
			end
			else
			begin
				update #tempresult set isProcessed = 1 where mvdid = @tempMvdid
			end
		end

		-- Get the size of result set
		SELECT @ResultCount=COUNT(*) FROM #TEMPRESULT

		-- If MVD ID wasn't provided allow the max of 1 record retrieved
		if (isnull(@RequestType,'') <> 'MD' AND (len( isnull(@MVDID,'')) = 0) and (@ResultCount > 1))
		begin
			-- This will force the message to user to provide more specific criteria
			select @ResultCount = @OutputLimit + 2
		end

		-- Set the result XML if the size doesn't exceed the limit
		if @ResultCount <= @OutputLimit
		begin
			SELECT @TEMPXML =
			(
				SELECT getutcdate() as DATE,
				(
					SELECT 
						ISNULL(MVDID,'') AS MVDID,
						ISNULL(LASTNAME,'') AS LASTNAME,
						ISNULL(FIRSTNAME,'') AS FIRSTNAME,
						ISNULL(GENDER,'') AS GENDER,
						CONVERT(VARCHAR(30),ISNULL(DOB,''),101) AS DOB,
						ISNULL(HEIGHTINCHES,'') AS HEIGHT_INCH,
						ISNULL(WEIGHTLBS,'') AS WEIGHT_LBS,
						ISNULL(MEDICAID,'') AS MEDICAID,
						ISNULL(MEDICARENUMBER,'') AS MEDICARENUMBER
						FROM #TEMPRESULT
					FOR XML PATH('RECORD'),TYPE, ELEMENTS
				)
				FOR XML RAW ('SEARCHRESULT'), TYPE
			)

			SELECT @XmlOutput=CONVERT(VARCHAR(MAX),@TEMPXML)
			
		end

		DROP TABLE #TEMPRESULT
		DROP TABLE #TEMPGROUPMEMBERS

		-- Store the request
		if(@skipNotification = 1)
		begin
			EXEC SP_MVD_App_Record_MD @MVDID, @LocationID, @ApplicationID,@UserName, @AccessReason, 
				'SEARCH', @Criteria, 'SUCCESS',@ResultCount, @InsertedRecordId out
		end
		else
		begin
			EXEC SP_MVD_App_Record @MVDID, @LocationID, @ApplicationID,@UserName, @AccessReason, 
				'SEARCH', @Criteria, 'SUCCESS',@ResultCount, @InsertedRecordId out
		end
	END TRY
	BEGIN CATCH
		EXEC SP_ExportXMLCatchError
		-- RECORD ACTION
		if(@skipNotification = 1)
		begin
			EXEC SP_MVD_App_Record_MD @MVDID, @LocationID, @ApplicationID,@UserName, @AccessReason, 
				'SEARCH', @Criteria, 'FAILED',-1, @InsertedRecordId out
		end
		else
		begin
			EXEC SP_MVD_App_Record @MVDID, @LocationID, @ApplicationID,@UserName, @AccessReason, 
				'SEARCH', @Criteria, 'FAILED',-1, @InsertedRecordId out
		end
	END CATCH

	EXEC sp_xml_removedocument @IDoc
	
	-- Record SP Log
	declare @params nvarchar(1000) = null
	set @params = '@LocationID=' + ISNULL(@LocationID, 'null') + ';' +
				  '@ApplicationID=' + ISNULL(@ApplicationID, 'null') + ';' +
				  '@UserName=' + ISNULL(@UserName, 'null') + ';' +
				  '@AccessReason=' + ISNULL(@AccessReason, 'null') + ';' +
				  '@Criteria=' + ISNULL(@Criteria, 'null') + ';' +
				  '@RequestType=' + ISNULL(@RequestType, 'null') + ';' +
				  '@OutputLimit=' + CONVERT(varchar(50), @OutputLimit) + ';'
	exec [dbo].[Set_StoredProcedures_Log] '[dbo].[SP_Search_MVD_Records]', @EMS, @UserID_SSO, @params

END