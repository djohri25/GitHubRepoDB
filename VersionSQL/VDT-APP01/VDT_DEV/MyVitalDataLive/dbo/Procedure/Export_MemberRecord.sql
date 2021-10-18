/****** Object:  Procedure [dbo].[Export_MemberRecord]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Date			Name			Comments
--01/03/2017	PPetluri		Modified code for Language, ETHNICITY to get names instead of ID's
-- 01/17/2017	Marc De Luca	Added XSINIL to PATH('LABDATA').  Added a replace @XmlOutput
-- =============================================
CREATE PROCEDURE [dbo].[Export_MemberRecord]
	@MVDID varchar(30),
	@outputFormat varchar(50),
	@ApplicationID varchar(50) = null,
	@XmlOutput XML OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

--select @MVDID = 'MA054279',
--		@outputFormat = 'CCR'


	DECLARE @RESULT XML,
		@MemberInsId varchar(50), -- member's insurance ID 
		@RecordCount int,
		@ccrRecord varchar(max),@cust_id int
		
		-- Used to check if the section is permitted to access by Medical personel
		declare @personInfoSecID int, @personInfoPermitted bit,
				@allergiesSecID int, @allergiesPermitted bit,
				@medicationsSecID int, @medicationsPermitted bit,
				@surgeriesSecID int, @surgeriesPermitted bit,
				@contactsSecID int, @contactsPermitted bit,
				@insuranceSecID int, @insurancePermitted bit,
				@conditionSecID int, @conditionPermitted bit,
				@immunizationSecID int, @immunizationPermitted bit

		select @MemberInsId = InsMemberId
		from Link_MemberId_MVD_Ins
		where MVDId = @MVDID

		select @cust_id = cust_id from  Link_MVDID_CustID lc
				   where lc.MVDId = @MVDID
		
		-- Get an ID of each section
		select @personInfoSecID = id from dbo.MainMenuTree where menuname = 'Personal Information'
		select @allergiesSecID = id from dbo.MainMenuTree where menuname = 'Allergies'
		select @medicationsSecID = id from dbo.MainMenuTree where menuname = 'Medication'
		select @surgeriesSecID = id from dbo.MainMenuTree where menuname = 'Surgeries'
		select @contactsSecID = id from dbo.MainMenuTree where menuname = 'Contact List'
		select @insuranceSecID = id from dbo.MainMenuTree where menuname = 'Insurance Policies'
		select @conditionSecID = id from dbo.MainMenuTree where menuname = 'Diseases/Conditions'
		select @immunizationSecID = id from dbo.MainMenuTree where menuname = 'Immunization Records'

		-- Get permission flag for each section
		select @personInfoPermitted=IsPermitted from SectionPermission where sectionID = @personInfoSecID and icenumber = @MVDID
		select @allergiesPermitted=IsPermitted from SectionPermission where sectionID = @allergiesSecID and icenumber = @MVDID
		select @medicationsPermitted=IsPermitted from SectionPermission where sectionID = @medicationsSecID and icenumber = @MVDID
		select @surgeriesPermitted=IsPermitted from SectionPermission where sectionID = @surgeriesSecID and icenumber = @MVDID
		select @contactsPermitted=IsPermitted from SectionPermission where sectionID = @contactsSecID and icenumber = @MVDID
		select @insurancePermitted=IsPermitted from SectionPermission where sectionID = @insuranceSecID and icenumber = @MVDID
		select @conditionPermitted=IsPermitted from SectionPermission where sectionID = @conditionSecID and icenumber = @MVDID
		select @immunizationPermitted=IsPermitted from SectionPermission where sectionID = @immunizationSecID and icenumber = @MVDID

		-- DJS 10/13/2015 - Allow Driscoll mobile app to see immunization records
		IF (@ApplicationID = '0C18E973-8303-4BA2-8CDA-3E6001B64F5B') 
		BEGIN
			select @immunizationPermitted=1
		END

		-- Per recent specification Personal Infomation is always shared
		select @personInfoPermitted = '1'
		
		if(@outputFormat = 'CCR')
		begin
			EXEC Export_CCR 
				@MVDID = @MVDID,
				@MedicationsPermitted = @medicationsPermitted,
				@SurgeriesPermitted = @surgeriesPermitted,
				@InsurancePermitted = @insurancePermitted,
				@ConditionPermitted = @conditionPermitted,
				@immunizationPermitted = @immunizationPermitted,
				@RecordCount = @RecordCount output,
				@XmlOutput = @ccrRecord output

			select @XmlOutput = CONVERT(xml,@ccrRecord)
		end
		else				
		begin
			-- Duplicates are removed for the following sections

			-- DJS - 11/09/2015 - Added Order By logic DOI-100
			DECLARE @RecordNumber INT, @RxDrug VARCHAR(50), @Treatment VARCHAR(50), @YearDate DATETIME, @Name VARCHAR(50), @count INT
			SELECT MM.RecordNumber, MM.ICENUMBER, MM.StartDate, 
				 MM.StopDate, MM.RefillDate, MM.PrescribedBy, MM.DrugId, MM.RxDrug, 
				 MM.RxPharmacy, MM.HowMuch, MM.HowOften, 
				 MM.WhyTaking, MM.HVID, MM.CreationDate, MM.ModifyDate, 
				 MM.ApproxDate, MM.CreatedBy, MM.CreatedByOrganization, 
				 MM.UpdatedBy, MM.UpdatedByOrganization, MM.UPDATEDBYCONTACT,
				 MM.HVFlag, ReadOnly, 
				 HomePhone, CellPhone, WorkPhone
			INTO #Medication
			FROM MainMedication MM INNER JOIN 
			MainPersonalDetails MPD ON MM.ICENUMBER = MPD.ICENUMBER
			WHERE (MM.ICENUMBER = @MVDID) 
			ORDER BY ISNULL(MM.RefillDate,MM.StartDate) DESC

	    SELECT MI.RecordNumber, MI.ICENUMBER, MI.ImmunId, 
		     MI.ImmunizationName, MI.DateDone, MI.DateDue, 
		     MI.DateApproximate, MI.CreationDate, MI.ModifyDate, 
		     MI.HVID, MI.HVFlag, ReadOnly,
			 CreatedBy, CreatedByOrganization, 
			 UpdatedBy, UpdatedByOrganization, UPDATEDBYCONTACT
			INTO #Immunization
			FROM MainImmunization MI  --INNER JOIN 
			--MainPersonalDetails MPD ON MI.ICENUMBER = MPD.ICENUMBER
			WHERE (MI.ICENUMBER = @MVDID)

			SELECT RecordNumber, ICENUMBER, YearDate, 
				 Condition, Treatment, 
				 Code,CodingSystem,
				 HVID, CreationDate, 
				 ModifyDate, HVFlag, ReadOnly, 
				 CreatedBy, CreatedByOrganization, 
				 UpdatedBy, UpdatedByOrganization, UPDATEDBYCONTACT
			INTO #Surgeries
			FROM MainSurgeries
			WHERE (ICENUMBER = @MVDID)
			
			SELECT RecordNumber, ICENUMBER, [Name], 
				 Address1, Address2, City, State, Postal, Phone, 
				 FaxPhone, PolicyHolderName, GroupNumber, 
				 PolicyNumber, WebSite, InsuranceTypeID, 
				 CreationDate, ModifyDate, Medicaid, 
				 MedicareNumber, HVID, HVFlag, 
				 CreatedBy, CreatedByOrganization,
				 UpdatedBy, UpdatedByOrganization, UPDATEDBYCONTACT,
				 ReadOnly
			INTO #Insurance
			FROM MainInsurance
			WHERE ICENUMBER = @MVDID
			
			IF @medicationsPermitted = 1
			BEGIN
				DECLARE currentMedicationRow CURSOR FOR
					SELECT DISTINCT RxDrug
					FROM MainMedication
					WHERE (ICENUMBER = @MVDID)
					ORDER BY RxDrug
				
				OPEN currentMedicationRow
				
				IF @@CURSOR_ROWS > 0
				BEGIN
					WHILE 1 = 1
					BEGIN
						FETCH NEXT FROM currentMedicationRow INTO @RxDrug
						IF @@FETCH_STATUS <> 0
							BREAK
						SELECT @count = count(*)
						FROM #Medication
						WHERE RxDrug = @RxDrug
						IF @count > 1
						BEGIN
							SELECT TOP (1) @RecordNumber = RecordNumber
							FROM #Medication
							WHERE (RxDrug = @RxDrug)
							ORDER BY ModifyDate DESC
							
							DELETE #Medication
							WHERE (RecordNumber <> @RecordNumber) AND 
								 (RxDrug = @RxDrug) 
						END
					END
				END
				
				CLOSE currentMedicationRow
				DEALLOCATE currentMedicationRow
			END

		--IF @immunizationPermitted = 1
		--	BEGIN
		--			DECLARE currentRow CURSOR FOR
		--    SELECT DISTINCT ISNULL
		--	  ((SELECT     ImmunName
		--		  FROM         LookupImmunization
		--		  WHERE     (MainImmunization.ImmunId = ImmunId)), ImmunizationName) AS ImmunizationName
		--FROM MainImmunization
		--WHERE (ICENUMBER = @MVDID)
		--ORDER BY ImmunizationName

		--OPEN currentRow
		
		--IF @@CURSOR_ROWS > 0
		--BEGIN
		--	DECLARE  @ImmunizationName NVARCHAR(127)
			
		--	WHILE 1 = 1
		--	BEGIN
		--		FETCH NEXT FROM currentRow INTO @ImmunizationName 
		--		IF @@FETCH_STATUS <> 0
		--			BREAK
		--		SELECT @count = count(*)
		--		FROM #Immunization
		--		WHERE ISNULL
		--		  ((SELECT     ImmunName
		--			  FROM         LookupImmunization
		--			  WHERE     (#Immunization.ImmunId = ImmunId)), ImmunizationName) = @ImmunizationName
		--		IF @count > 1
		--		BEGIN
		--			SELECT TOP (1) @RecordNumber = RecordNumber
		--			FROM #Immunization
		--			WHERE ISNULL
		--			  ((SELECT     ImmunName
		--				  FROM         LookupImmunization
		--				  WHERE     (#Immunization.ImmunId = ImmunId)), ImmunizationName) = @ImmunizationName
		--			ORDER BY DateDone DESC
					
		--			DELETE #Immunization
		--			WHERE (RecordNumber <> @RecordNumber) AND 
		--			     (ISNULL
		--					  ((SELECT     ImmunName
		--						  FROM         LookupImmunization
		--						  WHERE     (#Immunization.ImmunId = ImmunId)), ImmunizationName) = @ImmunizationName) 
		--		END
		--	END
		--END
		--CLOSE currentRow
		--	DEALLOCATE currentRow
		--END

			IF @surgeriesPermitted = 1
			BEGIN
				DECLARE currentSurgeriesRow CURSOR FOR
					SELECT DISTINCT Treatment, YearDate
					FROM MainSurgeries
					WHERE (ICENUMBER = @MVDID)
					ORDER BY YearDate, Treatment

				OPEN currentSurgeriesRow
				
				IF @@CURSOR_ROWS > 0
				BEGIN
					WHILE 1 = 1
					BEGIN
						FETCH NEXT FROM currentSurgeriesRow INTO @Treatment, @YearDate
						IF @@FETCH_STATUS <> 0
							BREAK
						SELECT @count = count(*)
						FROM #Surgeries
						WHERE Treatment = @Treatment AND YearDate = @YearDate
						IF @count > 1
						BEGIN
							SELECT TOP (1) @RecordNumber = RecordNumber
							FROM #Surgeries
							WHERE (Treatment = @Treatment) AND (YearDate = @YearDate)
							ORDER BY ModifyDate DESC
							
							DELETE #Surgeries
							WHERE (RecordNumber <> @RecordNumber) AND 
								 (Treatment = @Treatment) AND (YearDate = @YearDate) 
						END
					END
				END
				
				CLOSE currentSurgeriesRow
				DEALLOCATE currentSurgeriesRow
			END

			IF @insurancePermitted = 1
			BEGIN
				DECLARE currentInsuranceRow CURSOR FOR
					SELECT DISTINCT [Name]
					FROM MainInsurance
					WHERE (ICENUMBER = @MVDID)
					ORDER BY [Name]

				OPEN currentInsuranceRow
				
				IF @@CURSOR_ROWS > 0
				BEGIN
					WHILE 1 = 1
					BEGIN
						FETCH NEXT FROM currentInsuranceRow INTO @Name
						IF @@FETCH_STATUS <> 0
							BREAK
						SELECT @count = count(*)
						FROM #Insurance
						WHERE [Name] = @Name
						IF @count > 1
						BEGIN
							SELECT TOP (1) @RecordNumber = RecordNumber
							FROM #Insurance
							WHERE ([Name] = @Name)
							ORDER BY ModifyDate DESC
							
							DELETE #Insurance
							WHERE (RecordNumber <> @RecordNumber) AND 
								 ([Name] = @Name) 
						END
					END
				END
				
				CLOSE currentInsuranceRow
				DEALLOCATE currentInsuranceRow
			END
			
			SELECT @XmlOutput = 
			(
				--SELECT getutcdate() as RetrievalUTC, 
				--(
				SELECT
				(
					case @personInfoPermitted
						WHEN '0'
						THEN
						(
							SELECT '' FOR XML PATH('PERSONALDETAILS'),TYPE, ELEMENTS	
						)
						WHEN '1' 
						THEN 
						(
							SELECT 
								ISNULL(ICENUMBER,'') AS MVDID
								,dbo.InitCap(ISNULL(LastName,'')) AS LASTNAME
								,dbo.InitCap(ISNULL(FirstName,'')) AS FIRSTNAME
								,dbo.InitCap(ISNULL(MiddleName,'')) AS MIDDLENAME
								,CASE ISNULL(GenderID,'')
									WHEN '' THEN ''
									WHEN '0' THEN ''
									ELSE 
									(
										SELECT a.GENDERNAME FROM dbo.LookupGenderID a WHERE a.GENDERID = b.GENDERID
									)
								END AS GENDER
								,ISNULL(SSN,'') AS SSN
								,CASE ISNULL(DOB,'')
									WHEN '' THEN ''
									ELSE 
									(
										CONVERT(VARCHAR(30),ISNULL(DOB,''),101)
									)
								END AS DOB
								,dbo.InitCap(ISNULL(Address1,'')) AS ADDRESS1
								,dbo.InitCap(ISNULL(Address2,'')) AS ADDRESS2
								,dbo.InitCap(ISNULL(City,'')) AS CITY
								,upper(ISNULL(State,'')) AS STATE
								,ISNULL(PostalCode,'') AS ZIP
								,ISNULL(HomePhone,'') AS HOMEPHONE
								,ISNULL(CellPhone,'') AS CELLPHONE
								,ISNULL(WorkPhone,'') AS WORKPHONE
								,ISNULL(FaxPhone,'') AS FAX
								,CASE WHEN ISNULL(Language,'') = '' then ''
									  WHEN IsNULL(IsNumeric(Language),'') = 1 then (select	ll.Name from LookupLanguage ll where ISNULL(b.Language,'') = ISNULL(ll.ID,''))
									  Else ISNULL(Language,'') 
								END AS LANGUAGE
								,CASE WHEN ISNULL(Ethnicity, '') = '' then '' 
								      WHEN ISNULL(ISNumeric(Ethnicity), '') = 1 then (Select lr.RaceName from [dbo].[LookupRace] lr where ISNULL(Ethnicity, '') = ISNULL(lr.RaceID, ''))
									  ELSE ISNULL(Ethnicity, '') 
								END AS ETHNICITY
								,lower(ISNULL(Email,'')) AS EMAIL
								,CASE ISNULL(BloodTypeID,'')
									WHEN '' THEN ''
									WHEN 0 THEN ''
									ELSE 
									(
										SELECT a.BLOODTYPENAME FROM dbo.LookupBloodTypeID a 
										WHERE a.BloodTypeID = b.BloodTypeID
									)
								END AS BLOODTYPE 
								,CASE ISNULL(OrganDonor,'')
									WHEN '' THEN ''
									WHEN 0 THEN ''
									ELSE 
									(
										SELECT a.OrganDonorName FROM dbo.LookupOrganDonorTypeID a 
										WHERE a.OrganDonorID = b.OrganDonor
									)
								END AS ORGANDONOR
								,ISNULL( cast(HeightInches as varchar(10)),'') AS HEIGHT_INCH
								,ISNULL( cast(WeightLbs as varchar(10)),'') AS WEIGHT_LBS
								,CASE ISNULL(MaritalStatusID,'')
									WHEN '' THEN ''
									WHEN 0 THEN ''
									ELSE 
									(
										SELECT a.MARITALSTATUSNAME FROM dbo.LookupMaritalStatusID a 
										WHERE a.MaritalStatusID = b.MaritalStatusID
									)
								END AS MARITALSTATUS
								,CASE ISNULL(EconomicStatusID,'')
									WHEN '' THEN ''
									WHEN 0 THEN ''
									ELSE 
									(
										SELECT a.ECONOMICSTATUSNAME FROM dbo.LookupEconomicStatusID a 
										WHERE a.EconomicStatusID = b.EconomicStatusID
									)
								END AS ECONOMICSTATUS
								,ISNULL(Occupation,'') AS OCCUPATION
								,ISNULL(Hours,'') AS HOURS,
								ISNULL(ModifyDate,'') AS UPDATEDATETIME,
								dbo.InitCap(ISNULL(b.CreatedBy,'')) AS CREATEDBY,
								dbo.InitCap(ISNULL(b.CREATEDBYORGANIZATION,'')) AS CREATEDBYORGANIZATION,
								'' AS CREATEDBYCONTACT,
								CASE ISNULL(b.CreationDate,'')
									WHEN '' THEN ''
									ELSE 
									(
										CONVERT(VARCHAR(30),ISNULL(b.CreationDate,''),101)
									)
								END AS CREATEDON,
								CASE ISNULL(b.MODIFYDate,'')
									WHEN '' THEN ''
									ELSE 
									(
										CONVERT(VARCHAR(30),ISNULL(b.MODIFYDate,''),101)
									)
								END AS UPDATEDON,
								dbo.InitCap(ISNULL(b.UpdatedBy,'')) AS UPDATEDBY,
								dbo.InitCap(ISNULL(b.UPDATEDBYORGANIZATION,'')) AS UPDATEDBYORGANIZATION,
								ISNULL(b.UpdatedByContact,'') AS UPDATEDBYCONTACT
								FROM dbo.MainPersonalDetails b
								WHERE ICENUMBER = @MVDID
							FOR XML PATH('PERSONALDETAILS'),TYPE, ELEMENTS
						)
					end
				)
				,
				(
					case @allergiesPermitted
						WHEN '1' 
						THEN 
						(
							SELECT 
							(
								SELECT 
									CASE ISNULL(AllergenTypeId,'')
										WHEN '' THEN ''
										ELSE 
										(
											SELECT a.AllergenTypeName FROM dbo.LookupAllergies a WHERE a.AllergenTypeId = b.AllergenTypeId
										)
									END AS ALLERGENTYPE
									,ISNULL(AllergenName,'') AS ALLERGENNAME			
									,ISNULL(Reaction,'') AS REACTION,
									ISNULL(b.ModifyDate,'') AS UPDATEDATETIME,
									dbo.InitCap(ISNULL(b.CreatedBy,'')) AS CREATEDBY,
									dbo.InitCap(ISNULL(b.CREATEDBYORGANIZATION,'')) AS CREATEDBYORGANIZATION,
									'' AS CREATEDBYCONTACT,
									CASE ISNULL(b.CreationDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(b.CreationDate,''),101)
										)
									END AS CREATEDON,
									CASE ISNULL(b.MODIFYDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(b.MODIFYDate,''),101)
										)
									END AS UPDATEDON,
									dbo.InitCap(ISNULL(b.UpdatedBy,'')) AS UPDATEDBY,
									dbo.InitCap(ISNULL(b.UpdatedBYORGANIZATION,'')) AS UPDATEDBYORGANIZATION,
									ISNULL(b.UPDATEDBYCONTACT,'') AS UPDATEDBYCONTACT
									FROM dbo.MainAllergies b INNER JOIN 
									MainPersonalDetails MPD ON b.ICENUMBER = MPD.ICENUMBER
									WHERE b.ICENUMBER = @MVDID
								FOR XML PATH('ALLERGY'),TYPE, ELEMENTS
							)FOR XML PATH('ALLERGIES'),TYPE, ELEMENTS
						)
					end
				),
				(
					case @medicationsPermitted
						WHEN '1' 
						THEN 
						(
							SELECT 						
							(
								SELECT 								
									CASE ISNULL(DrugId,'')
										WHEN '' THEN ''
										ELSE 
										(
											SELECT a.DrugName FROM dbo.LookupDrugType a WHERE a.DrugId = b.DrugId
										)
									END AS DRUGTYPE,
									dbo.InitCap(ISNULL(RxDrug,'')) AS DRUGNAME,
									CASE ISNULL(STARTDATE,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(STARTDATE,''),101)
										)
									END AS STARTDATE,
									CASE ISNULL(STOPDATE,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(STOPDATE,''),101)
										)
									END AS STOPDATE,
									CASE ISNULL(REFILLDATE,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(REFILLDATE,''),101)
										)
									END AS REFILLDATE
									,dbo.InitCap(ISNULL(PrescribedBy,'')) AS PRESCRIBEDBY
									,dbo.InitCap(ISNULL(RxPharmacy,'')) AS PHARMACY
									,ISNULL(HowMuch,'') AS HOWMUCH
									,ISNULL(HowOften,'') AS HOWOFTEN
									,ISNULL(WhyTaking,'') AS REASON
									,isnull((	SELECT 
											CASE ISNULL(FillDate,'')
											WHEN '' THEN ''
											ELSE 
											(
												CONVERT(VARCHAR(30),ISNULL(FILLDATE,''),101)
											)
											END AS FILLDATE,
											dbo.InitCap(ISNULL(mh.PrescribedBy,'')) AS PRESCRIBEDBY,
											dbo.InitCap(ISNULL(mh.RxPharmacy,'')) AS PHARMACY,
											dbo.InitCap(ISNULL(mh.CreatedBy,'')) AS CREATEDBY,
											dbo.InitCap(ISNULL(mh.CREATEDBYORGANIZATION,'')) AS CREATEDBYORGANIZATION,
											dbo.InitCap(ISNULL(mh.CreatedBy,'')) AS UPDATEDBY,
											dbo.InitCap(ISNULL(mh.CREATEDBYORGANIZATION,'')) AS UPDATEDBYORGANIZATION,
											ISNULL(mh.CREATEDByContact,'') AS UPDATEDBYCONTACT
										from MainMedicationHistory mh
										where mh.IceNumber = b.Icenumber and mh.RxDrug = b.RxDrug
											-- Skip records for which Refill date wasn't set
											-- (e.g. when the med record is first time created, refill date is not set but
											-- history record is created in MedHistory table)
											AND len(CASE ISNULL(REFILLDATE,'')
													WHEN '' THEN ''
													ELSE ('DUMMY')
												END) > 0
											AND mh.RecordNumber not in (
												-- Exclude one record, the most recent history record which already updated
												-- the main med record
												select top 1 RecordNumber from MainMedicationHistory mh2
												where mh2.Icenumber = b.Icenumber 
													and mh2.RxDrug = b.RxDrug
													and mh2.FillDate = isnull(b.RefillDate,'')
											)
									  FOR XML PATH('REFILL'),TYPE, ELEMENTS
									),'') AS REFILLS
									,ISNULL(ModifyDate,'') AS UPDATEDATETIME,
									dbo.InitCap(ISNULL(b.CreatedBy,'')) AS CREATEDBY,
									dbo.InitCap(ISNULL(b.CREATEDBYORGANIZATION,'')) AS CREATEDBYORGANIZATION,
									'' AS CREATEDBYCONTACT,
									CASE ISNULL(CreationDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(CreationDate,''),101)
										)
									END AS CREATEDON,
									CASE ISNULL(MODIFYDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(MODIFYDate,''),101)
										)
									END AS UPDATEDON,
									dbo.InitCap(ISNULL(b.UpdatedBy,'')) AS UPDATEDBY,
									dbo.InitCap(ISNULL(b.UPDATEDBYORGANIZATION,'')) AS UPDATEDBYORGANIZATION,
									ISNULL(b.UPDATEDBYCONTACT,'') AS UPDATEDBYCONTACT
									FROM #Medication b 
									--WHERE ICENUMBER = @MVDID
								FOR XML PATH('MEDICATION'),TYPE, ELEMENTS
							)FOR XML PATH('MEDICATIONS'),TYPE, ELEMENTS
						)
					end
				),
				--	(
				--	case @immunizationPermitted
				--		WHEN '1' 
				--		THEN 
				--		(
				--			SELECT 
				--			(
				--				SELECT    DateDone,
				--				 DateDue, 
				--				 DateApproximate ,
				--				  ISNULL
				--		   ((SELECT     ImmunName
				--			  FROM         LookupImmunization
				--			  WHERE     (#Immunization.ImmunId = ImmunId)), ImmunizationName) AS ImmunName,
				--			  CASE WHEN DateDone IS NULL OR
				--	          DateApproximate = 1 THEN NULL ELSE Day(DateDone) END AS [Day1], CASE DateDone WHEN NULL THEN 0 ELSE Month(DateDone) END AS [Month1], 
				--	         CASE DateDone WHEN NULL THEN '' ELSE Year(DateDone) END AS [Year1], CASE WHEN DateDue IS NULL OR
				--	        DateApproximate = 1 THEN NULL ELSE Day(DateDue) END AS [Day2], CASE DateDue WHEN NULL THEN 0 ELSE Month(DateDue) END AS [Month2], 
				--	      CASE DateDue WHEN NULL THEN '' ELSE Year(DateDue) END AS [Year2]
				--				FROM #Immunization 
				--		      --WHERE ICENUMBER = @MVDID
				--				FOR XML PATH('IMMUNIZATION'),TYPE, ELEMENTS
				--			)FOR XML PATH('IMMUNIZATIONS'),TYPE, ELEMENTS
				--		)
				--	end
				--),
				(
					case @immunizationPermitted
						WHEN '1' 
						THEN 
						(
							SELECT 
							(
								SELECT 
									ISNULL(ImmunId, '') AS ID,
									ISNULL(ImmunizationName, '') AS Name,
									CASE ISNULL(DateDone, '')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(DateDone, ''),101)
										)
									END AS DateDone,
									CASE ISNULL(DateDue, '')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(DateDue, ''),101)
										)
									END AS DateDue,
									CASE ISNULL(DateApproximate, '')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(DateApproximate, ''),101)
										)
									END AS DateApproximate,
									ISNULL(b.ModifyDate,'') AS UPDATEDATETIME,
									dbo.InitCap(ISNULL(b.CreatedBy,'')) AS CREATEDBY,
									dbo.InitCap(ISNULL(b.CREATEDBYORGANIZATION,'')) AS CREATEDBYORGANIZATION,
									'' AS CREATEDBYCONTACT,
									CASE ISNULL(b.CreationDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(b.CreationDate,''),101)
										)
									END AS CREATEDON,
									CASE ISNULL(b.MODIFYDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(b.MODIFYDate,''),101)
										)
									END AS UPDATEDON,
									dbo.InitCap(ISNULL(b.UpdatedBy,'')) AS UPDATEDBY,
									dbo.InitCap(ISNULL(b.UPDATEDBYORGANIZATION,'')) AS UPDATEDBYORGANIZATION,
									ISNULL(b.UpdatedByContact,'') AS UPDATEDBYCONTACT
								FROM #Immunization b --INNER JOIN 
									--MainPersonalDetails MPD ON b.ICENUMBER = MPD.ICENUMBER
								FOR XML PATH('IMMUNIZATION'),TYPE, ELEMENTS
							)FOR XML PATH('IMMUNIZATIONS'),TYPE, ELEMENTS
						)
					end
				),
				(
					case @surgeriesPermitted
						WHEN '1' 
						THEN 
						(
							SELECT 
							(
								SELECT 
									
									ISNULL(Condition,'') AS CONDITION,
									ISNULL(Treatment,'') AS TREATMENT,
									ISNULL(Code,'') AS CODE,
									ISNULL(CodingSystem,'') AS CODINGSYSTEM,
									CASE ISNULL(YearDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(YearDate,''),101)
										)
									END AS DATE,
									ISNULL(b.ModifyDate,'') AS UPDATEDATETIME,
									dbo.InitCap(ISNULL(b.CreatedBy,'')) AS CREATEDBY,
									dbo.InitCap(ISNULL(b.CREATEDBYORGANIZATION,'')) AS CREATEDBYORGANIZATION,
									'' AS CREATEDBYCONTACT,
									CASE ISNULL(b.CreationDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(b.CreationDate,''),101)
										)
									END AS CREATEDON,
									CASE ISNULL(b.MODIFYDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(b.MODIFYDate,''),101)
										)
									END AS UPDATEDON,
									dbo.InitCap(ISNULL(b.UpdatedBy,'')) AS UPDATEDBY,
									dbo.InitCap(ISNULL(b.UPDATEDBYORGANIZATION,'')) AS UPDATEDBYORGANIZATION,
									ISNULL(b.UpdatedByContact,'') AS UPDATEDBYCONTACT
								FROM #Surgeries b INNER JOIN 
									MainPersonalDetails MPD ON b.ICENUMBER = MPD.ICENUMBER
									--WHERE ICENUMBER = @MVDID
								FOR XML PATH('SURGERY'),TYPE, ELEMENTS
							)FOR XML PATH('SURGERIES'),TYPE, ELEMENTS
						)
					end
				),
				(
					case @contactsPermitted
						WHEN '1' 
						THEN 
						(
							SELECT 
							(
								SELECT 
									CASE ISNULL(CareTypeID,'')
										WHEN '' THEN ''
										ELSE 
										(
											SELECT a.CareTypeName FROM dbo.LookupCareTypeID a WHERE a.CareTypeID = b.CareTypeID
										)
									END AS CONTACTTYPE,
									CASE ISNULL(RelationshipId,'')
										WHEN '' THEN ''
										ELSE 
										(
											SELECT a.RelationshipName FROM dbo.LookupRelationshipID a WHERE a.RelationshipID = b.RelationshipId
										)
									END AS RELATIONSHIP,
									dbo.InitCap(ISNULL(b.LastName,'')) AS LASTNAME,
									dbo.InitCap(ISNULL(b.FirstName,'')) AS FIRSTNAME,
									dbo.InitCap(ISNULL(b.Address1,'')) AS ADDRESS1,
									dbo.InitCap(ISNULL(b.Address2,'')) AS ADDRESS2,
									dbo.InitCap(ISNULL(b.City,'')) AS CITY,
									upper(ISNULL(b.State,'')) AS STATE,
									ISNULL(b.Postal,'') AS ZIP,
									ISNULL(PhoneHome,'') AS PHONEHOME,
									ISNULL(PHONECELL,'') AS PHONECELL,
									ISNULL(PHONEOTHER,'') AS PHONEOTHER,
									ISNULL(EMAILADDRESS,'') AS EMAIL,
									ISNULL(b.ModifyDate,'') AS UPDATEDATETIME,
									dbo.InitCap(ISNULL(b.CreatedBy,'')) AS CREATEDBY,
									dbo.InitCap(ISNULL(b.CREATEDBYORGANIZATION,'')) AS CREATEDBYORGANIZATION,
									'' AS CREATEDBYCONTACT,
									CASE ISNULL(b.CreationDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(b.CreationDate,''),101)
										)
									END AS CREATEDON,
									CASE ISNULL(b.MODIFYDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(b.MODIFYDate,''),101)
										)
									END AS UPDATEDON,
									dbo.InitCap(ISNULL(b.UpdatedBy,'')) AS UPDATEDBY,
									dbo.InitCap(ISNULL(b.UPDATEDBYORGANIZATION,'')) AS UPDATEDBYORGANIZATION,
									ISNULL(b.UpdatedByContact,'') AS UPDATEDBYCONTACT
									FROM dbo.MainCareInfo b INNER JOIN 
									MainPersonalDetails MPD ON b.ICENUMBER = MPD.ICENUMBER
									WHERE b.ICENUMBER = @MVDID
								FOR XML PATH('CONTACT'),TYPE, ELEMENTS
							)FOR XML PATH('CONTACTS'),TYPE, ELEMENTS
						)
					end
				),
				(
					case @insurancePermitted
						WHEN '1' 
						THEN 
						(
							SELECT 
							(
								SELECT 
									CASE ISNULL(InsuranceTypeID,'')
										WHEN '' THEN ''
										ELSE 
										(
											SELECT a.InsuranceTypeName FROM dbo.LookupInsuranceTypeID a WHERE a.InsuranceTypeID = b.InsuranceTypeID
										)
									END AS INSURANCETYPE,
									dbo.InitCap(ISNULL(NAME,'')) AS COMPANY,
									ISNULL(PHONE,'') AS PHONE,
									ISNULL(b.FAXPHONE,'') AS FAX,
									dbo.InitCap(ISNULL(b.Address1,'')) AS ADDRESS1,
									dbo.InitCap(ISNULL(b.Address2,'')) AS ADDRESS2,
									dbo.InitCap(ISNULL(b.City,'')) AS CITY,
									upper(ISNULL(b.State,'')) AS STATE,
									ISNULL(b.Postal,'') AS ZIP,
									dbo.InitCap(ISNULL(POLICYHOLDERNAME,'')) AS POLICYHOLDERNAME,
									ISNULL(GROUPNUMBER,'') AS GROUPNUMBER,
									ISNULL(POLICYNUMBER,'') AS POLICYNUMBER,
									lower(ISNULL(WEBSITE,'')) AS WEBSITE,
									ISNULL(MEDICAID,'') AS MEDICAID,
									ISNULL(MEDICARENUMBER,'') AS MEDICARENUMBER,
									ISNULL(b.ModifyDate,'') AS UPDATEDATETIME,
									dbo.InitCap(ISNULL(b.CreatedBy,'')) AS CREATEDBY,
									dbo.InitCap(ISNULL(b.CREATEDBYORGANIZATION,'')) AS CREATEDBYORGANIZATION,
									'' AS CREATEDBYCONTACT,
									CASE ISNULL(b.CreationDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(b.CreationDate,''),101)
										)
									END AS CREATEDON,
									CASE ISNULL(b.MODIFYDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(b.MODIFYDate,''),101)
										)
									END AS UPDATEDON,
									dbo.InitCap(ISNULL(b.UpdatedBy,'')) AS UPDATEDBY,
									dbo.InitCap(ISNULL(b.UPDATEDBYORGANIZATION,'')) AS UPDATEDBYORGANIZATION,
									ISNULL(b.UpdatedByContact,'') AS UPDATEDBYCONTACT
									FROM #Insurance b INNER JOIN 
									MainPersonalDetails MPD ON b.ICENUMBER = MPD.ICENUMBER
									--WHERE ICENUMBER = @MVDID
								FOR XML PATH('POLICY'),TYPE, ELEMENTS
							)FOR XML PATH('INSURANCEPOLICIES'),TYPE, ELEMENTS
						)
					end
				),
				(
					case @conditionPermitted
						WHEN '1' 
						THEN 
						(
							SELECT 
							(
								SELECT 
									CASE ISNULL(OtherName,'')
										WHEN '' THEN 
										(
											SELECT a.ConditionName FROM dbo.LookupCondition a WHERE a.ConditionId = b.ConditionId	
										)
										ELSE 
										(
											OtherName
										)
									END AS CONDITIONNAME,	
									RTRIM(ISNULL(Code,'')) AS CODE,
									ISNULL(CodingSystem,'') AS CODINGSYSTEM,
									CASE ISNULL(ReportDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(ReportDate,''),101)
										)
									END AS REPORTDATE,							
									ISNULL(b.CreationDate,'') AS UPDATEDATETIME,
									dbo.InitCap(ISNULL(b.CreatedBy,'')) AS CREATEDBY,
									dbo.InitCap(ISNULL(b.CREATEDBYORGANIZATION,'')) AS CREATEDBYORGANIZATION,
									'' AS CREATEDBYCONTACT,
									CASE ISNULL(b.CreationDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(b.CreationDate,''),101)
										)
									END AS CREATEDON,
									CASE ISNULL(b.MODIFYDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(b.MODIFYDate,''),101)
										)
									END AS UPDATEDON,
									dbo.InitCap(ISNULL(b.UpdatedBy,'')) AS UPDATEDBY,
									dbo.InitCap(ISNULL(b.UPDATEDBYORGANIZATION,'')) AS UPDATEDBYORGANIZATION,
									ISNULL(b.UpdatedByContact,'') AS UPDATEDBYCONTACT
									FROM dbo.MainCondition b INNER JOIN 
									MainPersonalDetails MPD ON b.ICENUMBER = MPD.ICENUMBER
									WHERE b.ICENUMBER = @MVDID 
									order by ReportDate desc
								FOR XML PATH('CONDITION'),TYPE, ELEMENTS
							)FOR XML PATH('CONDITIONS'),TYPE, ELEMENTS	
						)
					end
				),
				(
					SELECT 
					(
						SELECT 
							ISNULL(VisitDate,'') AS VISITDATETIME
							,dbo.InitCap(ISNULL(FacilityName,'')) AS FACILITYNAME
							,case source 
								when 'EMS - Lookup' then ''
								else dbo.InitCap(ISNULL(PhysicianFirstName,''))
								end as PHYSICIANFIRSTNAME
							,case source 
								when 'EMS - Lookup' then ''
								else dbo.InitCap(ISNULL(PhysicianLastName,''))
								end AS PHYSICIANLASTNAME
							,case source 
								when 'EMS - Lookup' then ''
								else dbo.InitCap(isNull(PhysicianFirstName+' ', '') + isNull(PhysicianLastName,''))
								end AS PHYSICIANFULLNAME
							,ISNULL(PhysicianPhone,'') As PHYSICIANPHONE
							,ISNULL(CASE IsHospitalAdmit
								when '0' then 'N'
								when '1' then 'Y'
								END, '') as ISHOSPITALADMIT
							,ISNULL(visitType,'') as VISITTYPE
							,ISNULL(case Source
								when 'EMS - Lookup' then a.ChiefComplaint
								else ''
								end, '') as CHIEFCOMPLAINT
							 ,ISNULL(case Source
								when 'EMS - Lookup' then a.EmsNote
								else ''
								end, '') as NOTES
						FROM EDVisitHistory v
							left join MVD_AppRecord a on v.sourceRecordID = a.RecordID
						where ICENUMBER = @MVDID
						--order by v.Created desc
						--DJS - 01/26/2016 - Order by Visit Date descending, per William
						order by IsNull(v.VisitDate,'01/01/1900') desc
						FOR XML PATH('EDVISIT'),TYPE, ELEMENTS
					)FOR XML PATH('EDVISITHISTORY'),TYPE, ELEMENTS
				),
				(
					SELECT 
					(
						SELECT 
							ISNULL(HealthPlanUserNote,'') AS COMMENT,
							ISNULL(HealthPlanNoteLastUpdate,'') as COMMENTLASTUPDATE,
							ISNULL(CASE p.inCaseManagement
								when '0' then 'No'
								when '1' then 'Yes'
								END, '') as INCASEMANAGEMENT,
							ISNULL(CASE p.NarcoticLockdown
								when '0' then 'No'
								when '1' then 'Yes'
								END, '') as NARCOTICLOCKDOWN,
							(		
								SELECT 
								(
									SELECT 
										isnull(d.name,'') as NAME,
										CASE ISNULL(m.Created,'')
											WHEN '' THEN ''
											ELSE 
											(
												CONVERT(VARCHAR(30),ISNULL(m.Created,''),101)
											)
										END AS CREATEDON
										FROM dbo.MainDiseaseManagement m
											inner join HPDiseaseManagement d on m.dm_id = d.dm_id
										WHERE m.ICENUMBER = @MVDID
									FOR XML PATH('PROGRAM'),TYPE, ELEMENTS
								)FOR XML PATH('DISEASEMANAGEMENTPROGRAMS'),TYPE, ELEMENTS
							)
						FROM MainPersonalDetails p
							left join UserAdditionalInfo a on p.icenumber = a.MVDID
						where p.icenumber = @mvdid 
						FOR XML PATH('HEALTHPLAN'),TYPE, ELEMENTS
					)FOR XML PATH('HEALTHPLANS'),TYPE, ELEMENTS
				),
				(
					SELECT 
					(
						--SELECT 
						--	ISNULL(Major,'') AS MAJOR,
						--	ISNULL(minor,'') AS MINOR
						--FROM MainToDoHEDIS h
						--	inner join Link_MemberId_MVD_Ins li on h.memberID = li.insmemberID
						--where li.InsMemberId = @MemberInsId and major not like '%access %'
						--FOR XML PATH('TODOTEST'),TYPE, ELEMENTS
						SELECT 
							ISNULL(TestID,'') AS MAJOR,
							'' AS MINOR
						FROM [dbo].[Final_HEDIS_Member] h
							inner join Link_MemberId_MVD_Ins li on h.memberID = li.insmemberID
						where li.InsMemberId = @MemberInsId and TestID not like '%access %'
						FOR XML PATH('TODOTEST'),TYPE, ELEMENTS


					)FOR XML PATH('TODOTESTS'),TYPE, ELEMENTS
				),
				(
					SELECT 
					(
						SELECT 
							CASE ISNULL(s.RoleID,'')
								WHEN '' THEN ''
								ELSE 
								(
									SELECT a.RoleName FROM dbo.LookupRoleID a WHERE a.RoleID = s.RoleID
								)
							END AS TYPE,
							dbo.InitCap(ISNULL(s.NPI,'')) AS NPI,
							dbo.InitCap(ISNULL(s.LastName,'')) AS LASTNAME,
							dbo.InitCap(ISNULL(s.FirstName,'')) AS FIRSTNAME,
							dbo.InitCap(ISNULL(s.Address1,'')) AS ADDRESS1,
							dbo.InitCap(ISNULL(s.Address2,'')) AS ADDRESS2,
							dbo.InitCap(ISNULL(s.City,'')) AS CITY,
							upper(ISNULL(s.State,'')) AS STATE,
							ISNULL(s.Postal,'') AS ZIP,
							ISNULL(Phone,'') AS PHONE,
							ISNULL(PHONECELL,'') AS CELLPHONE,
							ISNULL(FaxPhone,'') AS FAX,
							ISNULL(s.ModifyDate,'') AS UPDATEDATETIME,
							CASE ISNULL(s.CreationDate,'')
								WHEN '' THEN ''
								ELSE 
								(
									CONVERT(VARCHAR(30),ISNULL(s.CreationDate,''),101)
								)
							END AS CREATEDON,
							CASE ISNULL(s.MODIFYDate,'')
								WHEN '' THEN ''
								ELSE 
								(
									CONVERT(VARCHAR(30),ISNULL(s.MODIFYDate,''),101)
								)
							END AS UPDATEDON,
							isnull(
								(SELECT 
									 lc.OfficehrMon AS 'OFFICE_HR_MON',
									 lc.OfficeHrTue AS 'OFFICE_HR_TUE',							
									 lc.OfficeHrWed AS 'OFFICE_HR_WED',							
									 lc.OfficeHrThu AS 'OFFICE_HR_THU',							
									 lc.OfficeHrFri AS 'OFFICE_HR_FRI',							
									 lc.OfficeHrSat AS 'OFFICE_HR_SAT',							
									 lc.OfficeHrSun AS 'OFFICE_HR_SUN'							
								FROM lookupNPI_Custom lc
								where lc.NPI = s.NPI
								FOR XML PATH(''),TYPE, ELEMENTS						
							),'') as OFFICEHOURS
						FROM MainSpecialist s
						where s.icenumber = @mvdid  
						FOR XML PATH('SPECIALIST'),TYPE, ELEMENTS
					)FOR XML PATH('SPECIALISTS'),TYPE, ELEMENTS					
				),
				(
					SELECT 						
					(
						SELECT 								
							ISNULL(OrderName,'') as ORDERNAME,
							ISNULL(OrderCode,'') as ORDERCODE,
							ISNULL(OrderCodingSystem,'') as ORDERCODINGSYSTEM,
							CASE ISNULL(RequestDate,'')
								WHEN '' THEN ''
								ELSE 
								(
									CONVERT(VARCHAR(30),ISNULL(REQUESTDATE,''),101)
								)
							END AS REQUESTDATE,
							ISNULL(ORDERINGPHYSICIANLASTNAME,'') as ORDERINGPHYSICIANLASTNAME,
							ISNULL(ORDERINGPHYSICIANFIRSTNAME,'') as ORDERINGPHYSICIANFIRSTNAME,
							ISNULL(OrderCode,'') as ORDERCODE,
							ISNULL(ORDERINGPHYSICIANID,'') as ORDERINGPHYSICIANID,
							dbo.InitCap(isNull(ORDERINGPHYSICIANFIRSTNAME+' ', '') + isNull(ORDERINGPHYSICIANLASTNAME,'')) AS ORDERINGPHYSICIANFULLNAME,									
							isnull((	SELECT 
									CASE ISNULL(ReportedDate,'')
									WHEN '' THEN ''
									ELSE 
									(
										CONVERT(VARCHAR(30),ISNULL(ReportedDate,''),101)
									)
									END AS REPORTEDDATE,
									ISNULL(ResultName,'') as RESULTNAME,
									ISNULL(ResultValue,'') as RESULTVALUE,
									ISNULL(ResultUnits,'') as RESULTUNIT,
									ISNULL(Code,'') as RESULTCODE,
									ISNULL(CodingSystem,'') as RESULTCODINGSYSTEM,
									ISNULL(AbnormalFlag,'') as ABNORMALFLAG,
									ISNULL(RangeAlpha,'') as REFERENCERANGE,
									isnull((	SELECT 
											ISNULL(Note,'') as TEXT
										from MainLabNote n
										where n.IceNumber = b.Icenumber and n.resultID = rs.resultID and n.sourceName = rs.sourceName
									  FOR XML PATH('NOTE'),TYPE, ELEMENTS
									),'') AS  NOTES,



									dbo.InitCap(ISNULL(rs.CreatedBy,'')) AS CREATEDBY,
									dbo.InitCap(ISNULL(rs.CREATEDBYORGANIZATION,'')) AS CREATEDBYORGANIZATION,
									CASE ISNULL(rs.CreationDate,'')
										WHEN '' THEN ''
										ELSE 
										(
											CONVERT(VARCHAR(30),ISNULL(rs.CreationDate,''),101)
										)
									END AS CREATEDON
								from MainLabResult rs
								where rs.IceNumber = b.Icenumber and rs.orderID = b.orderID and rs.sourceName = b.sourceName
								order by rs.ReportedDate DESC
							  FOR XML PATH('RESULT'),TYPE, ELEMENTS
							),'') AS RESULTS,
							dbo.InitCap(ISNULL(b.CreatedBy,'')) AS CREATEDBY,
							dbo.InitCap(ISNULL(b.CREATEDBYORGANIZATION,'')) AS CREATEDBYORGANIZATION,
							'' AS CREATEDBYCONTACT,
							CASE ISNULL(CreationDate,'')
								WHEN '' THEN ''
								ELSE 
								(
									CONVERT(VARCHAR(30),ISNULL(CreationDate,''),101)
								)
							END AS CREATEDON
							FROM dbo.MainLabRequest b 
							WHERE ICENUMBER = @MVDID
							ORDER BY b.RequestDate DESC
						FOR XML PATH('TEST'),TYPE, ELEMENTS
					)FOR XML PATH('LABDATA'),TYPE, ELEMENTS XSINIL
				)
				FOR XML RAW ('MEMBERINFO'), TYPE
			)
		--	FOR XML RAW (''), TYPE
		--)
		DROP TABLE #Immunization
		DROP TABLE #Medication
		DROP TABLE #Surgeries
		DROP TABLE #Insurance

		--select @XmlOutput = CONVERT(VARCHAR(MAX),@RESULT)
	SELECT @XmlOutput = REPLACE(CAST(@XmlOutput AS VARCHAR(MAX)), 'http://www.w3.org/2001/XMLSchema-instance', 'EMPTY')
	SELECT @XmlOutput = CAST(@XmlOutput AS XML)

		end	-- End MVD format export


END