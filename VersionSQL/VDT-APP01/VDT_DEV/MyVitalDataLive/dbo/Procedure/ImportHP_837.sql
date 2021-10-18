/****** Object:  Procedure [dbo].[ImportHP_837]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 9/11/2008
-- Description:	Import Health Plan 837 data residing in HIPAATalk database
-- =============================================
CREATE Procedure [dbo].[ImportHP_837]
	@Type int		-- 1 - 837_claim_institutional, 2 - 837_claim_professional
As
SET NOCOUNT ON
declare @query varchar(max), @databaseName varchar(50), @tableName varchar(50), @idColumnName varchar(50)

select @databaseName = 'HIPAATalk'

if( @Type = 1)
begin
	select @tableName = 'x12_837_claim_institutional'
	select @idColumnName = 'x12_837_claim_institutional_id'
end
else if( @Type = 2)
begin
	select @tableName = 'x12_837_claim_professional'
	select @idColumnName = 'x12_837_claim_professional_id'
end

declare
    @recordId int,
	@x12_transaction_id int,

	-- Subscriber (the primary owner of the account)
	@SubMemberID varchar(30),
	@SubLastName varchar(35),
	@SubFirstName varchar(25),
	@SubAddress1 varchar(55),
	@SubAddress2 varchar(55),
	@SubCity varchar(30),
	@SubState char(2),
	@SubZip varchar(15),
	@SubDOB varchar(35),
	@SubGender char(1),

	-- Patient (one of the profile in the subscriber MVD account)
	@PtMemberID varchar(30),
	@PtRelationship char(2),
	@PtLastName varchar(35),
	@PtFirstName varchar(25),
	@PtAddress1 varchar(55),
	@PtAddress2 varchar(55),
	@PtCity varchar(30),
	@PtState char(2),
	@PtZip varchar(15),
	@PtDOB varchar(35),
	@PtGender char(1),

	-- insurance data
	@InsType char(1),
	@InsLastName varchar(35),
	@InsFirstName varchar(25),
	@InsProviderId varchar(80),
	@InsAddress1 varchar(55),
	@InsAddress2 varchar(55),
	@InsCity varchar(30),
	@InsState char(2),
	@InsZip varchar(15),
	@InsContactMethod char(2), -- communication method TE or EM
	@InsPhoneOrEmail varchar(80),

	-- facility data
	@FacLastName varchar (35),
	@FacFirstName varchar(25),
	@FacId varchar(80),
	@FacAddress1 varchar(55),
	@FacAddress2 varchar(55),
	@FacCity varchar(30),
	@FacState char(2),
	@FacZip varchar(15),

	-- procedure data
	@ProcCode varchar(10),
	@ProcDate varchar(10),	

	-- mvd data
	@MVDGroupId varchar(15),
	@SubMVDId varchar(15), 
	@PtMVDId varchar(15), 
	@MVDGender int,
	@IsPrimary bit,	
	@ImportResult int			-- 0 - success, -1 - failure

-- Holds data which needs to be processed
create table #tempRecords (
	recordId int,
	x12_transaction_id int,

	SubMemberID varchar(30),
	SubLastName varchar(35),
	SubFirstName varchar(25),
	SubAddress1 varchar(55),
	SubAddress2 varchar(55),
	SubCity varchar(30),
	SubState char(2),
	SubZip varchar(15),
	SubDOB varchar(35),
	SubGender char(1),

	PtMemberID varchar(30),
	PtRelationship char(2),
	PtLastName varchar(35),
	PtFirstName varchar(25),
	PtAddress1 varchar(55),
	PtAddress2 varchar(55),
	PtCity varchar(30),
	PtState char(2),
	PtZip varchar(15),
	PtDOB varchar(35),
	PtGender char(1),
	
	InsType char(1),
	InsLastName varchar(35),
	InsFirstName varchar(25),
	InsProviderId varchar(80),
	InsAddress1 varchar(55),
	InsAddress2 varchar(55),
	InsCity varchar(30),
	InsState char(2),
	InsZip varchar(15),
	InsContactMethod char(2), -- communication method TE or EM
	InsPhoneOrEmail varchar(80),

	FacLastName varchar (35),
	FacFirstName varchar(25),
	FacId varchar(80),
	FacAddress1 varchar(55),
	FacAddress2 varchar(55),
	FacCity varchar(30),
	FacState char(2),
	FacZip varchar(15),

	ProcCode varchar(10),
	ProcDate varchar(10)
)

-- Populate temp table with unprocessed records
set @query = 'select ' + @idColumnName + 
	
	',x12_transaction_id
	,L2010BA_nm109_subscriber_id
	,L2010BA_nm103_subscriber_last_nm
	,L2010BA_nm104_subscriber_first_nm
	,L2010BA_n301_subscriber_address1
	,L2010BA_n302_subscriber_address2
	,L2010BA_n401_subscriber_city
	,L2010BA_n402_subscriber_state
	,L2010BA_n403_subscriber_zip
	,L2010BA_dmg02_subscriber_dob
	,L2010BA_dmg03_subscriber_gender

	,L2010CA_nm109_patient_id
    ,L2000C_pat01_ind_relationship_code
	,L2010CA_nm103_patient_last_nm
	,L2010CA_nm104_patient_first_nm
	,L2010CA_n301_patient_address1
	,L2010CA_n302_patient_address2
	,L2010CA_n401_patient_city
	,L2010CA_n402_patient_state
	,L2010CA_n403_patient_zip
	,L2010CA_dmg02_patient_dob
	,L2010CA_dmg03_patient_gender

	,L2010AA_nm102_entity_type_qual
	,L2010AA_nm103_billing_prov_last_nm
	,L2010AA_nm104_billing_prov_first_nm
	,L2010AA_nm109_billing_prov_id
	,L2010AA_n301_billing_prov_address1
	,L2010AA_n302_billing_prov_address2
	,L2010AA_n401_billing_prov_city
	,L2010AA_n402_billing_prov_state
	,L2010AA_n403_billing_prov_zip
	,L2010AA_per03_billing_prov_comm_num_qual	
	,L2010AA_per04_billing_prov_comm			-- phone number or email address

	,L2010AB_nm103_payto_prov_last_nm
	,L2010AB_nm104_payto_prov_first_nm
	,L2010AB_nm109_payto_prov_id
	,L2010AB_n301_payto_prov_address1
	,L2010AB_n302_payto_prov_address2
	,L2010AB_n401_payto_prov_city
	,L2010AB_n402_payto_prov_state
	,L2010AB_n403_payto_prov_zip'

	+ case @tableName
		when 'x12_837_claim_professional'
		then
			',L2400_sv101_proc_code'
		when 'x12_837_claim_institutional'
		then
			',L2400_sv202_proc_code'
	end +
	',L2400_dtp02_472_from_service_date
from ' + @databaseName + '.dbo.' + @tableName + 
' where isMVDProcessed = ''0'' or isMVDProcessed is null
order by x12_transaction_id,timestamp'

insert into #tempRecords 
(recordId ,
	x12_transaction_id,
	SubMemberID,
	SubLastName,
	SubFirstName,
	SubAddress1,
	SubAddress2,
	SubCity,
	SubState,
	SubZip,
	SubDOB,
	SubGender,

	PtMemberID,
    PtRelationship,
	PtLastName,
	PtFirstName,
	PtAddress1,
	PtAddress2,
	PtCity,
	PtState,
	PtZip,
	PtDOB,
	PtGender,

	InsType,
	InsLastName,
	InsFirstName,
	InsProviderId,
	InsAddress1,
	InsAddress2,
	InsCity,
	InsState,
	InsZip,
	InsContactMethod, -- communication method TE or EM
	InsPhoneOrEmail,

	FacLastName,
	FacFirstName,
	FacId,
	FacAddress1,
	FacAddress2,
	FacCity,
	FacState,
	FacZip,
	ProcCode,
	ProcDate
)
EXEC(@query) 


-- Process each record separately
while exists (select * from #tempRecords)
begin
	BEGIN TRY	

		select top 1  @recordId = recordId,
			@x12_transaction_id = x12_transaction_id,
			-- Subscriber (the primary owner of the account)
			@SubMemberID = SubMemberID,
			@SubLastName = SubLastName,
			@SubFirstName = SubFirstName,
			@SubAddress1 = SubAddress1,
			@SubAddress2 = SubAddress2,
			@SubCity = SubCity,
			@SubState = SubState,
			@SubZip = SubZip,
			@SubDOB = SubDOB,
			@SubGender = SubGender,
			-- Patient (one of the profile in the subscriber MVD account)
			@PtMemberID = PtMemberID,
			@PtRelationship = PtRelationship,
			@PtLastName = PtLastName,
			@PtFirstName = PtFirstName,
			@PtAddress1 = PtAddress1,
			@PtAddress2 = PtAddress2,
			@PtCity = PtCity,
			@PtState = PtState,
			@PtZip = PtZip,
			@PtDOB = PtDOB,
			@PtGender = PtGender,
			-- Insurance or a person (if she/he doesn't have insurance)
			@InsType = InsType,
			@InsLastName = InsLastName,
			@InsFirstName = InsFirstName,
			@InsProviderId = InsProviderId,
			@InsAddress1 = InsAddress1,
			@InsAddress2 = InsAddress2,
			@InsCity = InsCity,
			@InsState = InsState,
			@InsZip = InsZip,
			@InsContactMethod = InsContactMethod,
			@InsPhoneOrEmail = InsPhoneOrEmail,
			-- Facility providing treatment
			@FacLastName = FacLastName,
			@FacFirstName = FacFirstName,
			@FacId = FacId,
			@FacAddress1 = FacAddress1,
			@FacAddress2 = FacAddress2,
			@FacCity = FacCity,
			@FacState = FacState,
			@FacZip = FacZip,
			-- Procedure
			@ProcCode = ProcCode,
			@ProcDate = ProcDate
		from #tempRecords

		-- Check if insurance group has mvd group mapped
		-- Primary subscriber ID is used to link to MVD Group Id
		if( exists (select * from Link_GroupID_MVD_Ins where InsGroupId = @SubMemberID ) )
		begin
			select @MVDGroupId = MVDGroupId from Link_GroupID_MVD_Ins where InsGroupId = @SubMemberID
		end
		else
		begin
			-- Generate new MVD GroupID
			EXEC GenerateRandomString 1,0,1,'23456789ABCDEFGHJKLMNPQRSTWXYZ',10, @MVDGroupId output

			-- Repeat generating MVD GroupID until it's unique
			while exists (select * from MainICENUMBERGroups where ICEGROUP = @MVDGroupId)
			begin
				EXEC GenerateRandomString 1,0,1,'23456789ABCDEFGHJKLMNPQRSTWXYZ',10, @MVDGroupId output
			end
		end


		-- Check if the patient is the primary owner of the insurance policy
		-- That person will become the primary ower of MVD account
		-- If patient is the primary subscriber the patient section is not valued
		if (@PtRelationship is null OR @PtRelationship = '18')
		begin
			select @isPrimary = 1
		end
		else
		begin
			select @isPrimary = 0
		end

		-- SUBSCRIBER SECTION
		EXEC ImportHP_Pers_837
			@IsPrimary = 1,
			@MemberID = @SubMemberID,
			-- TODO: verify if this logic is true
			-- For primary subscriber, use his ID to map MVD Group Id to
			@InsGroupId = @SubMemberID,
			@MVDGroupId = @MVDGroupId,
			@LastName = @SubLastName,
			@FirstName = @SubFirstName,
			@Address1 = @SubAddress1,
			@Address2 = @SubAddress2,
			@City = @SubCity,
			@State = @SubState,
			@Zip = @SubZip,
			@DOB = @SubDOB,
			@Gender = @SubGender,
			@MVDId = @SubMVDId output, -- At this point, @SubMVDId has the MVD Id of the newly created or updated MVD record
			@Result = @ImportResult output				

		-- PATIENT SECTION
		-- Process only if data provided		
		if( @ImportResult = 0 and len(isnull(@PtMemberID,'')) <> 0 and 
			len(isnull(@PtLastName,'')) <> 0 and len(isnull(@PtFirstName,'')) <> 0 )
		begin
			EXEC ImportHP_Pers_837
				@IsPrimary = 0,						-- Not primary MVD account
				@MemberID = @PtMemberID,			-- Insurance Member Id
				-- TODO: verify if this logic is true
				-- For primary subscriber, use his ID to map MVD Group Id to
				@InsGroupId = @SubMemberID,			-- Used to link patient to subscriber group
				@MVDGroupId = @MVDGroupId,			-- Patient is in the same group as subscriber
				@LastName = @PtLastName,
				@FirstName = @PtFirstName,
				@Address1 = @PtAddress1,
				@Address2 = @PtAddress2,
				@City = @PtCity,
				@State = @PtState,
				@Zip = @PtZip,
				@DOB = @PtDOB,
				@Gender = @PtGender,
				@MVDId = @PtMVDId output,
				@Result = @ImportResult output				
		end

		-- INSURANCE SECTION
		-- Process only if data provided	

		declare @tempPolicyHolder varchar(50)
		select @tempPolicyHolder = left(isnull(@SubFirstName + ' ','') + isnull(@SubLastName,''), 50)
	 	
		if( @ImportResult = 0 and len(isnull(@SubMVDId,'')) <> 0 and 
			len(isnull(@InsProviderId,'')) <> 0 and len(isnull(@InsLastName,'')) <> 0 )
		begin
			EXEC ImportHP_Insurance_837
				@MVDId = @SubMVDId,
				@InsType = @InsType,
				@InsLastName = @InsLastName,
				@InsFirstName = @InsFirstName,
				@InsProviderId = @InsProviderId,
				@InsAddress1 = @InsAddress1,
				@InsAddress2 = @InsAddress2,
				@InsCity = @InsCity,
				@InsState = @InsState,
				@InsZip = @InsZip,
				@InsPolicyHolder = @tempPolicyHolder,
				@InsContactMethod = @InsContactMethod,
				@InsPhoneOrEmail = @InsPhoneOrEmail,
				@Result = @ImportResult output
		end	

		declare @tempMvdId varchar(15)

		-- FACILITY SECTION
		-- Process only if data provided		
		if( @ImportResult = 0 and len(isnull(@FacLastName,'')) <> 0 )
		begin
			if( len(isnull(@PtMVDId,'')) <> 0 )
			begin
				-- Import to patient profile
				set @tempMvdId = @PtMVDId
			end
			else
			begin
				-- Import to primary subscriber profile
				set @tempMvdId = @SubMVDId
			end

			EXEC ImportHP_Facility_837
				@MVDId = @tempMvdId,
				@FacLastName = @FacLastName,
				@FacFirstName = @FacFirstName,
				@FacId = @FacId,
				@FacAddress1 = @FacAddress1,
				@FacAddress2 = @FacAddress2,
				@FacCity = @FacCity,
				@FacState = @FacState,
				@FacZip = @FacZip,
				@Result = @ImportResult output	
		end

		-- PROCEDURE SECTION
		-- Process only if data provided	
		if( @ImportResult = 0 and len(isnull(@ProcCode,'')) <> 0 and 
			len(isnull(@ProcDate,'')) = 8 )
		begin
			if( len(isnull(@PtMVDId,'')) <> 0 )
			begin
				-- Import to patient profile
				set @tempMvdId = @PtMVDId
			end
			else
			begin
				-- Import to primary subscriber profile
				set @tempMvdId = @SubMVDId
			end

			EXEC ImportHP_Procedure_837
				@MVDId = @tempMvdId,
				@ProcCode = @ProcCode,
				@ProcDate = @ProcDate,
				@Result = @ImportResult output	
		end	

		if( @ImportResult = '0' )
		begin
			-- Set Record as already processed
			EXEC('update ' + @databaseName + '.dbo.' + @tableName +
				' set isMVDProcessed = ''1''
				where ' + @idColumnName + ' = ' + @recordId)
		end

	END TRY
	BEGIN CATCH
		SELECT @ImportResult = -1

		EXEC ImportCatchError	
	END CATCH

	delete from #tempRecords where recordId = @recordId
end

drop table #tempRecords