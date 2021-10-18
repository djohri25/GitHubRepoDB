/****** Object:  Procedure [dbo].[SP_GetMatchingCustomers_CustID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[SP_GetMatchingCustomers_CustID]
	@CustID int,
	@Criteria varchar(max),
	@OutputLimit int,
	@SearchStatus int out
	
AS


--Select 
--@CustID = 13
--,
--	@Criteria = '<CRITERIA><CRITERION><NAME>PATIENTINSURANCEID</NAME><VALUE>1007009200</VALUE></CRITERION></CRITERIA>'
--	,
--	@OutputLimit = 50
	

BEGIN

	SET NOCOUNT ON;



	declare 
		@HpID varchar(20),
		@MVDID varchar(20),	
		@insID varchar(20),
		@Email varchar(30),
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
		@GenderID varchar(30),	-- gender lookup value
		@ResultCount int

	declare @tempXML XML

	-- Temporary result table
	CREATE TABLE #TEMPRESULT
	(
		MVDID VARCHAR(30),
		LASTNAME VARCHAR(50),
		FIRSTNAME VARCHAR(50),
		EMAIL VARCHAR(50),
		CITY VARCHAR(50),
		STATE VARCHAR(50),
		GENDER VARCHAR(20),
		DOB VARCHAR(50),
		SSN VARCHAR(20),
		HPCUSTOMER VARCHAR(100),
		INSMEMBERID VARCHAR(20)
	)

	-- Other MVD customers belonging to the same MVD Group
	CREATE TABLE #TEMPGROUPMEMBERS
	(
		MVDID VARCHAR(30)
	)

	EXEC sp_xml_preparedocument @IDoc OUTPUT, @Criteria

	BEGIN TRY

		-- Extract criterion values------
		-- Set to "any value" for the field if criterion not provided
		SELECT @HpID = Value
		FROM OPENXML (@IDoc, 'CRITERIA/CRITERION', 2)
		WITH (Name varchar(50) './NAME',Value text './VALUE')
		where Name = 'HEALTHPLANID'

		SELECT @MVDID = Value
		FROM OPENXML (@IDoc, 'CRITERIA/CRITERION', 2)
		WITH (Name varchar(50) './NAME',Value text './VALUE')
		where Name = 'MYVITALDATAID'

		SELECT @insID = Value
		FROM OPENXML (@IDoc, 'CRITERIA/CRITERION', 2)
		WITH (Name varchar(50) './NAME',Value text './VALUE')
		where Name = 'PATIENTINSURANCEID'

		SELECT @Email = Value
		FROM OPENXML (@IDoc, 'CRITERIA/CRITERION', 2)
		WITH (Name varchar(50) './NAME',Value text './VALUE')
		where Name = 'PATIENTEMAIL'

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
		Select @HpID = @CustID 


		if len( isnull(@MVDID,'')) = 0 AND len( isnull(@insID,'')) > 0
		begin
			if len( isnull(@HpID,'')) = 0
			begin
				select @mvdid = mvdid from Link_MemberId_MVD_Ins where insmemberID = @insID 
			end
			else
			begin
				select @mvdid = mvdid from Link_MemberId_MVD_Ins where insmemberID = @insID and cust_id = @HpID
			end

			if isnull(@MVDID,'') = ''
			begin
				select @mvdid = icenumber  from maininsurance a join Link_MemberId_MVD_Ins b
				on a.ICENUMBER = b.MVDId 
				where medicaid = @insID and b.Cust_ID = @HpID
			end			
		end

	

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
		select @sql = 
		'select a.ICENUMBER,LASTNAME,FIRSTNAME,EMAIL,a.CITY,a.STATE,
		(SELECT GENDERNAME FROM dbo.LookupGenderID b WHERE b.GenderID=a.GenderID) as GENDER,
			CASE ISNULL(DOB,'''')
						WHEN '''' THEN NULL
						ELSE 
						(
							CONVERT(VARCHAR(30),ISNULL(DOB,''''),101)
						)
					END AS DOB,
			CASE ISNULL(SSN,'''')
						WHEN '''' THEN NULL
						ELSE 
						(
							RIGHT(SSN,4)
						)
					END AS SSN,
			c.name,
			li.insmemberID
		from dbo.MainPersonalDetails a
			left join Link_MemberId_MVD_Ins li on a.icenumber = li.mvdid
			left join hpCustomer c on li.cust_id = c.cust_id
			left join maininsurance i on a.icenumber = i.icenumber 
		where 1=1 ' +
		case len(isnull(@MVDID,''))
		when 0 then '' 
		else 
			'and  a.ICENUMBER IN 
			(
				SELECT MVDID FROM #TEMPGROUPMEMBERS
			) and  li.Isprimary = 1 '	
		end +
	--	case len(isnull(@insID,'')) 
	--	when 0 then '' 
	--	else ' and (li.insMemberID = ''' + @insID + ''' or i.medicaid = ''' + @insID + ''') '
	--	end +
		case len(isnull(@HpID,'')) 
		when 0 then '' 
		else ' and li.cust_id = ''' + @HpID + ''''
		end +
		case len(isnull(@Email,'')) 
		when 0 then '' 
		else ' and a.Email LIKE ''' + @Email + '%'''
		end +
		case len(isnull(@LastName,'')) 
		when 0 then '' 
		else ' and a.LastName= ''' + @LastName + ''''
		end +
		case len(isnull(@FirstName,''))  
		when 0 then '' 
		else ' and a.FirstName= ''' + @FirstName + ''''
		end +
		case len(isnull(@HomeZipCode,''))  
		when 0 then '' 
		else ' and a.PostalCode= ''' + @HomeZipCode + ''''
		end +
		case len(isnull(@HomeCity,''))  
		when 0 then '' 
		else ' and a.City= ''' + @HomeCity + ''''
		end +
		case len(isnull(@HomeState,''))  
		when 0 then '' 
		else ' and a.State= ''' + @HomeState + ''''
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

		-- Insert records into temporary result table
		INSERT INTO #TEMPRESULT (MVDID,LASTNAME,FIRSTNAME,EMAIL, CITY,STATE,GENDER,DOB,SSN,HPCUSTOMER,INSMEMBERID)
		exec (@sql )

--SELECT * FROM #TEMPRESULT

		-- Get the size of result set
		SELECT @ResultCount=COUNT(*) FROM #TEMPRESULT

	
	
		-- Set the result XML if the size doesn't exceed the limit
		if @ResultCount <= @OutputLimit
		begin
			set @SearchStatus = 0
			--SELECT @TEMPXML =
--			(
				--SELECT getutcdate() as DATE,
--				(
					SELECT 
						ISNULL(MVDID,'') AS MVDID,
						ISNULL(LASTNAME,'') AS LASTNAME,
						ISNULL(FIRSTNAME,'') AS FIRSTNAME,
						ISNULL(EMAIL,'') AS EMAIL, 
						ISNULL(CITY,'') AS CITY,
						ISNULL(STATE,'') AS STATE,
						ISNULL(GENDER,'') AS GENDER,
						CONVERT(VARCHAR(30),ISNULL(DOB,''),101) AS DOB,
						ISNULL(SSN,'') AS SSN,
						ISNULL(HPCUSTOMER,'') AS HPCUSTOMER,
						ISNULL(INSMEMBERID,'') AS INSMEMBERID
						FROM #TEMPRESULT
--					FOR XML PATH('RECORD'),TYPE, ELEMENTS
--				)
--				FOR XML RAW ('SEARCHRESULT'), TYPE
--			)

--			SELECT @XmlOutput=CONVERT(VARCHAR(MAX),@TEMPXML)
		end
		else
		begin
			set @SearchStatus = -2
		end

		DROP TABLE #TEMPRESULT
		DROP TABLE #TEMPGROUPMEMBERS

	END TRY
	BEGIN CATCH
		set @SearchStatus = -1

		EXEC SP_ExportXMLCatchError
		-- RECORD ACTION
	END CATCH

	EXEC sp_xml_removedocument @IDoc
END






--select a.ICENUMBER,LASTNAME,FIRSTNAME,EMAIL,a.CITY,a.STATE,
--		(SELECT GENDERNAME FROM dbo.LookupGenderID b WHERE b.GenderID=a.GenderID) as GENDER,
--			CASE ISNULL(DOB,'')
--						WHEN '' THEN NULL
--						ELSE 
--						(
--							CONVERT(VARCHAR(30),ISNULL(DOB,''),101)
--						)
--					END AS DOB,
--			CASE ISNULL(SSN,'')
--						WHEN '' THEN NULL
--						ELSE 
--						(
--							RIGHT(SSN,4)
--						)
--					END AS SSN,
--			c.name,
--			li.insmemberID
--		from dbo.MainPersonalDetails a
--			left join Link_MemberId_MVD_Ins li on a.icenumber = li.mvdid
--			left join hpCustomer c on li.cust_id = c.cust_id
--			left join maininsurance i on a.icenumber = i.icenumber 
--		where 1=1 and  a.ICENUMBER IN 
--			(
--				SELECT MVDID FROM #TEMPGROUPMEMBERS
--			)  and  li.Isprimary = 1   --(li.insMemberID = '1007009200' or i.medicaid = '1007009200')  
--			   and li.cust_id = '13'
--			   order by Created Desc


--Select * from Link_MemberId_MVD_Ins where insmemberID = '1007009200'