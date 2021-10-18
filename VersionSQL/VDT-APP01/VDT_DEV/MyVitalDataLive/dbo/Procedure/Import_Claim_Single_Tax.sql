/****** Object:  Procedure [dbo].[Import_Claim_Single_Tax]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 3/2/2009
-- Description:	Import single claim record
-- =============================================
CREATE PROCEDURE [dbo].[Import_Claim_Single_Tax]
    @recordId int,
	-- Claim info
	@ClaimNumber varchar(50),
	@LineNumber varchar(50),
	-- Owner
	@MemberID varchar(30),
	@MemberLastName varchar(35),
	@MemberFirstName varchar(25),
	@MemberDOB varchar(35),
	@MemberGender char(1),
	-- Diagnoses
	@Diag1 varchar(50),
	@Diag2 varchar(50),
	@Diag3 varchar(50),
	@Diag4 varchar(50),
	@Diag5 varchar(50),
	@Diag6 varchar(50),
	@Diag7 varchar(50),
	@Diag8 varchar(50),
	@Diag9 varchar(50),
	-- Procedure
	@ProcedureCode varchar(50),
	@ServFromDate varchar(50),
	-- Service Provider
	@ServProvNPI varchar(50),
    @ServProvLastName varchar(50),
	@ServProvFirstName varchar(50),
	@BillType varchar(20),				-- Used to determine Hospital Admits
	@RevCode varchar(50),					-- Used to determine ER visits
	@Pos varchar(50),
	@DRGCode varchar(5),		
	@FormType varchar(50),
	@Customer varchar(50) = 'HEDIS',
	@DischargeStatus varchar(50),
	@AdmissionDate varchar(50),	
	@DischargeDate varchar(50),
	@Taxonomy varchar(50),	
	@RetVisitType varchar(50) output,
	@ImportResult int output			-- 0 - success, -1 - failure
As
BEGIN
SET NOCOUNT ON

/*
select @recordId  = '552688509',
	-- Claim info
	@ClaimNumber = '2011066T0340500',
	@LineNumber = '9',
	-- Owner
	@MemberID = '123',
	@MemberLastName  = '',
	@MemberFirstName  = '',
	@MemberDOB  = '4/4/2010',
	@MemberGender = '',
	-- Diagnoses
	@Diag1 = '778.4',
	@Diag2 = 'V29.0',
	@Diag3 = null,
	@Diag4 = null,
	@Diag5 = null,
	@Diag6 = null,
	@Diag7 = null,
	@Diag8 = null,
	@Diag9 = null,
	-- Procedure
	@ProcedureCode = '450',
	@ServFromDate = '2/4/2011',
	-- Service Provider
	@ServProvNPI = NULL,
    @ServProvLastName = 'COOK CHILDRENS MEDICAL CENTER',
	@ServProvFirstName = '',
	@BillType  = '111',				-- Used to determine Hospital Admits
	@RevCode = '450',					-- Used to determine ER visits
	@Pos = '21',
	@DRGCode  = '',		
	@FormType = 'UB92',
	@Customer = 'Driscoll',
	@DischargeStatus = '01',
	@AdmissionDate = '2/4/2011',	
	@DischargeDate = '2/6/2011'
*/

declare
	-- mvd data
	@MVDGroupId varchar(15),
	@MVDId varchar(15), 
	@MVDGender int,
	@UpdatedBy varchar(250),			-- Only set when Individual updates a record
	@UpdatedByContact varchar(50),		-- Common field for UpdatedBy and Organization
	@Organization varchar(250),
	@HPCustomerId int,
	@HPRecordIdentifier varchar(100),	-- composed of claimNumber and lineNumber
	-- provider info from LookupNPI table
	@TempProvType int,					-- 1 - individual, 2 - organization
	@TempProvOrgName varchar(50),
	@TempProvLastName varchar(50),
	@TempProvFirstName varchar(50),
	@TempProvAddress1 varchar(50),
	@TempProvAddress2 varchar(50),
	@TempProvCity varchar(50),
	@TempProvState varchar(2),
	@TempProvZip varchar(50),
	@TempProvPhone varchar(50),
	@TempProvFax varchar(50),
	@TempProvCredentials varchar(50),	-- prefix in the individual's name
	@TempTaxonomy1 nvarchar(10),
	@TempTaxonomy2 nvarchar(10),
	@TempTaxonomy3 nvarchar(10),
	@TempTaxonomy4 nvarchar(10),
	@TempTaxonomy5 nvarchar(10),
	@VisitType varchar(50),				-- e.g. ER, PHYSICIAN, OTHER
	-- Insurance info
	@InsName varchar(50),
	@InsAddress1 varchar(50),
	@InsAddress2 varchar(50),
	@InsCity varchar(50),
	@InsState varchar(2),
	@InsZip varchar(5),
	@InsPhone varchar(10),
	@loginame nvarchar(128),
	
	@BillType3 varchar(3)

	BEGIN TRY
		BEGIN TRAN

		select @MemberID = dbo.RemoveLeadChars(@MemberID,'0'),
			@BillType3 = right(@BillType,3),
			@MemberDOB = case when @MemberDOB ='' then null else convert(varchar,convert(datetime,@MemberDOB),101) end,
			@ServFromDate = case when @ServFromDate ='' then null else convert(varchar,convert(datetime,@ServFromDate),101) end,
			@AdmissionDate = case when @AdmissionDate ='' then null else convert(varchar,convert(datetime,@AdmissionDate),101) end,
			@DischargeDate = case when @DischargeDate ='' then null else convert(varchar,convert(datetime,@DischargeDate),101) end

		IF ISNULL(@customer,'') = ''
			-- Default
			SET @Customer = 'Health Plan of Michigan'
 
		IF LEN(@customer) < 3
		BEGIN
			-- Customer ID was passed (e.g. from ImportHPM_Claims_LIVE), so retrieve customer name
			SET @HPCustomerId = @Customer

			SELECT	TOP 1
					@Customer = Name,
					@HPCustomerId = Cust_ID,
					@InsName = Name, 
					@InsAddress1 = Address1, 
					@InsAddress2 = Address2, 
					@InsCity = City, 
					@InsState = State, 
					@InsZip = PostalCode, 
					@InsPhone = Phone
			FROM	HPCustomer
			WHERE	cust_ID = @HPCustomerId
		END
		ELSE
			-- Get the customer the account belongs to
			SELECT	TOP 1
					@HPCustomerId = Cust_ID,
					@InsName = Name, 
					@InsAddress1 = Address1, 
					@InsAddress2 = Address2, 
					@InsCity = City, 
					@InsState = State, 
					@InsZip = PostalCode, 
					@InsPhone = Phone
			FROM	HPCustomer WHERE Name = @Customer
			
		-- As of 3/15/2010, Amerigroup sends wrong format of bill type with '0' in front
		IF @Customer = 'Amerigroup' AND LEN(ISNULL(@BillType,'')) > 1 AND @BillType LIKE '0%'
		begin
			if len(@billType) > 3
			begin
				set @BillType = substring(@BillType,2,len(@BillType)-1)
			end
			else if len(@billType) = 3
			begin
				set @BillType = substring(@BillType,2,len(@BillType)-1) + '1'
			end
		end

		IF ISNULL(@BillType,'') = ''
		begin
			set @FormType = 'HCFA'
		end
		else if isnull(@formtype,'') = ''
		begin
			set @formtype = 'UB92'
		end

		-- Create identifier of each record
		set @HPRecordIdentifier = 'Claim: ' + @ClaimNumber + ', ' + 'Line: ' + @LineNumber

		-- Determine who provided data
		SELECT	TOP 1
				@TempProvType = [Entity Type Code],
				@TempProvOrgName = left([Provider Organization Name (Legal Business Name)],50),
				@TempProvLastName = left([Provider Last Name (Legal Name)],50),
				@TempProvFirstName = [Provider First Name],
				@TempProvAddress1 = [Provider First Line Business Practice Location Address],
				@TempProvAddress2 = [Provider Second Line Business Practice Location Address],
				@TempProvCity = [Provider Business Practice Location Address City Name],
				@TempProvState = [Provider Business Practice Location Address State Name],
				@TempProvZip = left([Provider Business Practice Location Address Postal Code],5),
				@TempProvPhone = left([Provider Business Practice Location Address Telephone Number],10),
				@TempProvFax = left([Provider Business Practice Location Address Fax Number],10),
				@TempTaxonomy1 = [Healthcare Provider Taxonomy Code_1],
				@TempTaxonomy2 = [Healthcare Provider Taxonomy Code_2],
				@TempTaxonomy3 = [Healthcare Provider Taxonomy Code_3],
				@TempTaxonomy4 = [Healthcare Provider Taxonomy Code_4],
				@TempTaxonomy5 = [Healthcare Provider Taxonomy Code_5],
				@UpdatedByContact = left([Provider Business Practice Location Address Telephone Number],10),
				@TempProvCredentials = [Provider Credential Text]
		FROM	lookupNPI 
		WHERE	NPI = @ServProvNPI	

		-- In order to speed up import process query local table
		--from [156465-APP1].[hpm_import].dbo.lookupNPI 

		IF ISNULL(@ServProvNPI,'') = '' 
			OR (ISNULL(@ServProvNPI,'') != '' AND 
				ISNULL(@TempProvOrgName,'') = '' AND 
				ISNULL(@TempProvLastName,'') = '')
		begin
			-- NPI wasn't provided OR it was provided but hasn't been found in lookup table
			IF ISNULL(@ServProvLastName,'') != '' AND ISNULL(@ServProvFirstName,'') != ''
			begin
				-- Person (e.g. a doctor)
				select	@UpdatedBy = @ServProvFirstName + ' ' + @ServProvLastName,
						@Organization = ''
			end
			ELSE IF ISNULL(@ServProvLastName,'') != ''
			begin
				-- Organization
				select	@UpdatedBy = '',
						@Organization = @ServProvLastName
			end
			else
			begin
				select	@UpdatedBy = '',
						@Organization = @Customer
			end
		end
		else
		begin
			-- User info retrieved from lookupNIP
			If(@TempProvType = '1')
			begin
				-- Person (e.g. a doctor format: John Smith, Dr.)
				select	@UpdatedBy = @TempProvFirstName + ' ' + @TempProvLastName + isnull(', ' + @TempProvCredentials,''),
						@Organization = ''
			end
			else
			begin
				-- Organization
				select	@UpdatedBy = '',
						@Organization = @TempProvOrgName
			end
		end

		-------------------- MEMBER SECTION
		EXEC Import_Personal
			@IsPrimary = 1,
			@MemberID = @MemberID,
			@InsGroupId = '',
			@MVDGroupId = @MVDGroupId,
			@LastName = @MemberLastName,
			@FirstName = @MemberFirstName,
			@DOB = @MemberDOB,
			@Gender = @MemberGender,
			@MVDId = @MVDId output, -- At this point, @MVDId has the MVD Id of the newly created or updated MVD record
			@ReportDate = @ServFromDate,
			@UpdatedBy = @UpdatedBy,
			@UpdatedByContact = @UpdatedByContact,
			@Organization = @Organization,
			@HPCustomerId = @HPCustomerId,
			@SourceName = 'CLAIMS',
			@SourceRecordID = @recordId,
			@HPAssignedRecordID = @HPRecordIdentifier,
			@Customer = @Customer, 
			@Result = @ImportResult output				


		
		-- PROCEDURE SECTION
		IF @ImportResult = 0 AND ISNULL(@MVDId,'') != '' AND ISNULL(@ProcedureCode,'') != ''
		begin
			EXEC Import_Claims_Procedure_Tax
				@ClaimRecordId = @recordId,
				@HPAssignedRecordID = @HPRecordIdentifier,
				@MVDId = @MVDId, 
				@ProcedureCode = @ProcedureCode,
				@ProcedureDate = @ServFromDate,
				@ServProvNPI = @ServProvNPI,
				@UpdatedBy = @UpdatedBy, 
				@UpdatedByContact = @UpdatedByContact,
				@Organization = @Organization, 
				@Customer = @Customer, 
				@RevCode = @RevCode,
				@BillType = @BillType3,
				@POS = @POS, 
				@DRGCode = @DRGCode,
				@DischargeStatus = @DischargeStatus,
				@AdmissionDate = @AdmissionDate,	
				@DischargeDate = @DischargeDate,
				@Taxonomy = @Taxonomy,			
				@Result = @ImportResult OUTPUT
		end

		-- DJS 10/13/2015 IMMUNIZATION SECTION
		IF @ImportResult = 0 AND ISNULL(@MVDId,'') != '' AND ISNULL(@ProcedureCode,'') != ''
		begin
			EXEC Import_Immunization_Procedure
				@ClaimRecordID = @recordId,
				@MVDId = @MVDId,
				@ProcedureCode = @ProcedureCode,
				@ProcedureDate = @ServFromDate,
				@Customer = @Customer,
				@UpdatedBy = @UpdatedBy,
				@UpdatedByContact = @UpdatedByContact,
				@Organization = @Organization,
				@Result = @ImportResult OUTPUT

			SELECT @ImportResult = 0 -- TODO FIXME - DJS - here to temporarily ignore errors in Import_Immunization_Procedure - while the process is new we don't want it stopping the import process
		end

		-- DIAGNOSES SECTION
		IF @ImportResult = 0 AND ISNULL(@MVDId,'') != ''
		begin
			EXEC Import_Claims_Diagnoses_TAX 
				@RecordId = @recordId,
				@HPAssignedRecordID = @HPRecordIdentifier,
				@MVDId = @MVDId, 
				@DiagCode1 = @Diag1,
				@DiagCode2 = @Diag2,
				@DiagCode3 = @Diag3,
				@DiagCode4 = @Diag4,
				@DiagCode5 = @Diag5,
				@DiagCode6 = @Diag6,
				@DiagCode7 = @Diag7,
				@DiagCode8 = @Diag8,
				@DiagCode9 = @Diag9,
				@ServDate = @ServFromDate,
				@ServProvNPI = @ServProvNPI,
				@UpdatedBy = @UpdatedBy, 
				@UpdatedByContact = @UpdatedByContact,
				@Organization = @Organization, 
				@Customer = @Customer, 
				@RevCode = @RevCode,
				@BillType = @BillType3,
				@POS = @POS, 
				@DRGCode = @DRGCode,	
				@DischargeStatus = @DischargeStatus,
				@AdmissionDate = @AdmissionDate,	
				@DischargeDate = @DischargeDate,
				@Taxonomy = @Taxonomy,							
				@Result = @ImportResult OUTPUT
		end
		
		-- SERVICE PROVIDER SECTION
		-- Process only if data provided		
		IF @ImportResult = 0 AND ISNULL(@MVDId,'') != '' AND ISNULL(@ServProvLastName,'') != ''
		begin

			EXEC Import_Claims_ServProv
				@ClaimRecordId = @recordId,
				@HPAssignedRecordID = @HPRecordIdentifier,
				@MVDId = @MVDId,
				@ServProvNPI = @ServProvNPI,
				@ServProvType = @TempProvType,
				@ServProvName = @TempProvOrgName,
				@ServProvLastName = @ServProvLastName,
				@ServProvFirstName = @ServProvFirstName,
				@ServProvAddress1 = @TempProvAddress1,
				@ServProvAddress2 = @TempProvAddress2,
				@ServProvCity = @TempProvCity,
				@ServProvState = @TempProvState,
				@ServProvZip = @TempProvZip,
				@ServProvPhone = @TempProvPhone,
				@ServProvFax = @TempProvFax,
				@ServProvCredentials = @TempProvCredentials,
				@Customer = @Customer, 
				@Result = @ImportResult OUTPUT
		end

		-- INSURANCE SECTION
		IF @ImportResult = 0 AND ISNULL(@MVDId,'') != ''
		begin
			EXEC Import_Insurance
				@MVDId = @MVDId,
				@PolicyNumber = @MemberID,
				@PolicyHolderFirstName = @MemberFirstName,
				@PolicyHolderLastName = @MemberLastName,
				@SourceName = 'CLAIMS',
				@SourceRecordID = @recordId,
				@HPAssignedRecordID = @HPRecordIdentifier,
				@UpdatedBy = @UpdatedBy, 
				@UpdatedByContact = @UpdatedByContact,
				@Organization = @Organization, 
				@UpdatedByNPI = @ServProvNPI,
				@InsName = @InsName,
				@InsAddress1 = @InsAddress1,
				@InsAddress2 = @InsAddress2,
				@InsCity = @InsCity,
				@InsState = @InsState,
				@InsZip = @InsZip,
				@InsPhone = @InsPhone,
				@Customer = @Customer, 
				@Result = @ImportResult OUTPUT
		end

		-- ED VISIT HISTORY (set recent encounter based on claim record)
		IF @ImportResult = 0 AND ISNULL(@MVDId,'') != ''
		begin
			IF ISNULL(@ServProvNPI,'') = '' 
				OR (ISNULL(@ServProvNPI,'') != '' AND 
					ISNULL(@TempProvOrgName,'') = '' AND 
					ISNULL(@TempProvLastName,'') = '')
			begin
				-- NPI wasn't provided OR it was provided but hasn't been found in lookup table
				IF ISNULL(@ServProvLastName,'') != '' AND ISNULL(@ServProvFirstName,'') != ''
				begin
					-- Person (e.g. a doctor)
					select	@TempProvFirstName = @ServProvFirstName,
							@TempProvLastName = @ServProvLastName,
							@TempProvOrgName = ''
				end
				ELSE IF ISNULL(@ServProvLastName,'') != ''
				begin
					-- Organization
					select	@TempProvFirstName = '',
							@TempProvLastName = '',
							@TempProvOrgName = @ServProvLastName
				end
			end
			
			-- Determine visit type
			select @VisitType = dbo.Get_ClaimVisitType( 
				@FormType,	
				@ProcedureCode,
				@BillType,				
				@RevCode,
				@Pos,
				@TempTaxonomy1,
				@TempTaxonomy2,
				@TempTaxonomy3,
				@TempTaxonomy4,
				@TempTaxonomy5)

			set @RetVisitType = @VisitType
			
			/* 10/27/2009 old logic to determine ER visits
			if(RIGHT(@RevCode, 3) LIKE '45%' OR @ProcedureCode IN ('99281','99282','99283','99284','99285'))
			begin
				set @VisitType = 'ER'
			end
			else if(@TempProvType = '1')
			begin
				set @VisitType = 'PHYSICIAN'
			end
			else
			begin
				set @VisitType = 'OTHER'
			end
			*/

			IF @VisitType != 'IGNORE'
			begin
				declare @Source varchar(50)
				select @Source = left(@Customer + ' : Claims', 50)
				EXEC Import_EDVisitHistory
					@ICENUMBER = @MVDId,
					@VisitDate = @ServFromDate,
					@FacilityName = @TempProvOrgName,
					@FacilityNPI = @ServProvNPI,
					@PhysicianFirstName = @TempProvFirstName,
					@PhysicianLastName = @TempProvLastName,
					@PhysicianPhone = @UpdatedByContact,
					@Source = @Source,
					@SourceRecordID = @recordId,
					@CancelNotification = '0',
					@CancelNotifyReason = '',
					@BillType = @BillType,
					@VisitType = @VisitType,
					@FormType = @FormType,
					@POS = @Pos,
					@RevCode = @RevCode
			end
		end
		
		/*
		select	@loginame = rtrim(loginame)
		from	master.dbo.sysprocesses
		where	spid = @@spid

		--if(db_name() = 'MyVitalDataLive')
		IF @loginame NOT LIKE '%sqlservice'
		begin
			-------- Update import result
			declare @tempRecordID int

			set @tempRecordID = 0

			select @tempRecordID = ID
			from hpm_import.dbo.claims
				where [Member ID] = @MemberID
					and [Claim Number] = @ClaimNumber
					and [Line #] = @LineNumber

			IF @ImportResult = 0 AND @tempRecordID != 0
			begin
				-- Successful import and record exists
				update hpm_import.dbo.claims
					set isProcessed = '1', processedDate = convert(varchar,getutcdate(),20), forceProcess = 0   
				where ID = convert(varchar,@tempRecordID,10)
			end
			ELSE IF @ImportResult != 0
			begin
				-- Record will have to be reprocessed
					
				if(@tempRecordID = 0)
				begin
					insert into hpm_import.dbo.claims
						([Claim Number],[Line #],[Action Code],[Form Type],[Stmt From Date],[Stmt Thru Date],[Serv Prov NPI],[Serv Prov Last Name],[Serv Prov First Name],[Serv Prov Middle name]
						,[Member ID],[Member Last Name],[Member First Name],[Member Middle Name],[Member DOB],[Member Gender],[Member Age]
						,[Diag 1],[Diag 2],[Diag 3],[Diag 4],[Diag 5],[Diag 6],[Diag 7],[Diag 8],[Diag 9]
						,[Claim Status],[Claim Status Description],[Serv From Date],[Serv Thru Date],[POS],[Procedure],[Rev Code],[Bill Type]
						,[DRG Code],[Mod 1],[Mod 2],[Mod 3],[Diag Ind],[Charge Amount],[Units]
						,[IsProcessed],[ProcessedDate],[Created],[ProcessNote],[ProcessAttemptCount],[forceProcess],[Cust_ID])
					values(@ClaimNumber,@LineNumber,'',@FormType,'','',@ServProvNPI,@ServProvLastName,@ServProvFirstName,'',
						@MemberID,@MemberLastName,@MemberFirstName,'',@MemberDOB,@MemberGender,'',
						@Diag1,@Diag2,@Diag3,@Diag4,@Diag5,@Diag6,@Diag7,@Diag8,@Diag9,
						'','',@ServFromDate,'',@Pos,@ProcedureCode,@RevCode,@BillType,'','','','','','','',
						0,null,getutcdate(),null,1,0,@HPCustomerId)				
				end		
				else
				begin
					update hpm_import.dbo.claims
						set processAttemptCount = processAttemptCount + 1, forceProcess = 0 
					where id = convert(varchar,@tempRecordID,10)
				end
			end
		end
		*/
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		
		DECLARE @addInfo nvarchar(MAX)	
				
		SELECT @ImportResult = -1,
			@addInfo = 
			'RecordId=' + CAST(@RecordId AS VARCHAR(16)) + ', @ClaimNumber=' + ISNULL(@ClaimNumber, 'NULL') + ', @LineNumber=' + ISNULL(@LineNumber, 'NULL') + 
			', @MemberID=' + ISNULL(@MemberID, 'NULL') + ', @MemberLastName=' + ISNULL(@MemberLastName, 'NULL') + ', @MemberLastName=' + ISNULL(@MemberLastName, 'NULL') + ', @MemberDOB=' + ISNULL(@MemberDOB, 'NULL') + 
			', @MemberGender=' + ISNULL(@MemberGender, 'NULL') + 
			', @Diag1=' + ISNULL(@Diag1, 'NULL') + ', @Diag2=' + ISNULL(@Diag2, 'NULL') + 
			', @Diag3=' + ISNULL(@Diag3, 'NULL') + ', @Diag1=' + ISNULL(@Diag4, 'NULL') + 
			', @Diag5=' + ISNULL(@Diag5, 'NULL') + ', @Diag6=' + ISNULL(@Diag6, 'NULL') + 
			', @Diag7=' + ISNULL(@Diag7, 'NULL') + ', @Diag8=' + ISNULL(@Diag8, 'NULL') + 
			', @Diag9=' + ISNULL(@Diag9, 'NULL') +
			', @ProcedureCode=' + ISNULL(@ProcedureCode, 'NULL') + ', @ServFromDate=' + ISNULL(@ServFromDate, 'NULL') + ', @ServProvNPI=' + ISNULL(@ServProvNPI, 'NULL') + ', @ServProvLastName=' + ISNULL(@ServProvLastName, 'NULL') + 
			', @ServProvFirstName=' + ISNULL(@ServProvFirstName, 'NULL') + ', @BillType=' + ISNULL(@BillType, 'isNULL') + ', @RevCode=' + ISNULL(@RevCode, 'NULL') + 
			', @Pos=' + ISNULL(@Pos, 'NULL') + ', @FormType=' + ISNULL(@FormType, 'NULL') + ', @Customer=' + ISNULL(@Customer, 'NULL') +
			', @DischargeStatus=' + ISNULL(@DischargeStatus, 'NULL') + ', @AdmissionDate=' + ISNULL(@AdmissionDate, 'NULL') + ', @DischargeDate=' + ISNULL(@DischargeDate, 'NULL')

		EXEC ImportCatchError @addinfo = @addInfo	
	
	END CATCH
end