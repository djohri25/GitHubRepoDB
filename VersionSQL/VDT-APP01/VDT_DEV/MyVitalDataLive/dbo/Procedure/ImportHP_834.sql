/****** Object:  Procedure [dbo].[ImportHP_834]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 8/29/2008
-- Description:	Import 834 claims data residing in HIPAATalk database
-- =============================================
CREATE Procedure [dbo].[ImportHP_834]
As
SET NOCOUNT ON

declare
	-- insurance data
    @recordId int,
	@x12_transaction_id int,
	@Relationship char(2),
	@EconomicStatus char(2),
	@InsGroupID varchar(30),
	@PolicyNumber varchar(30),
	@MemberID varchar(30),
	@LastName varchar(35),
	@FirstName varchar(25),
	@L2100A_nm109_subscriber_id varchar(80),
	@ContactMethod char(2),
	@PhoneOrEmail varchar(80),
	@Address1 varchar(55),
	@Address2 varchar(55),
	@City varchar(30),
	@State char(2),
	@Zip varchar(15),
	@Country varchar(3),
	@DOB varchar(35),
	@Gender char(1),
	@MaritalStatus char(1),
	@Height varchar(8),
	@Weight varchar(10),
	-- contact info
	@Cont_FirstName varchar(35), 
	@Cont_LastName varchar(35),
	@Cont_ContactMethod char(2),
	@Cont_PhoneOrEmail varchar(80),
	@Cont_Phone varchar(30),
	@Cont_Email varchar(50),
	@Cont_Address1 varchar(55),
	@Cont_Address2 varchar(55),
	@Cont_City varchar(30),
	@Cont_State char(2),
	@Cont_Zip varchar(15),
	-- mvd data
	@MVDGroupId varchar(15),
	@MVDId varchar(15), 
	@Phone varchar(30),
	@Email varchar(50),
	@MVDGender int,
	@MVDMaritalStatus int,
	@MVDEconomicStatus int,
	@IsPrimary bit,	
	@UpdateResult int

-- Holds data which needs to be processed
create table #tempInsRecords (
	recordId int,
	x12_transaction_id int,
	Relationship char(2),
	EconomicStatus char(2),
	InsGroupID varchar(30),
	PolicyNumber varchar(30),
	MemberID varchar(30),
	LastName varchar(35),
	FirstName varchar(25),
	L2100A_nm109_subscriber_id varchar(80),
	ContactMethod char(2),
	PhoneOrEmail varchar(80),
	Address1 varchar(55),
	Address2 varchar(55),
	City varchar(30),
	State char(2),
	Zip varchar(15),
	Country varchar(3),
	DOB varchar(35),
	Gender char(1),
	MaritalStatus char(1),
	Height varchar(8),
	Weight varchar(10),
	Cont_FirstName varchar(35), 
	Cont_LastName varchar(35),
	Cont_ContactMethod char(2),
	Cont_PhoneOrEmail varchar(80),
	Cont_Phone varchar(30),
	Cont_Email varchar(50),
	Cont_Address1 varchar(55),
	Cont_Address2 varchar(55),
	Cont_City varchar(30),
	Cont_State char(2),
	Cont_Zip varchar(15)
)

-- Populate temp table with unprocessed records
insert into #tempInsRecords 
(recordId ,
	x12_transaction_id,
	Relationship ,
	EconomicStatus ,
	InsGroupID ,
	PolicyNumber ,
	MemberID ,
	LastName ,
	FirstName,
	L2100A_nm109_subscriber_id,
	ContactMethod ,
	PhoneOrEmail,
	Address1 ,
	Address2 ,
	City ,
	State ,
	Zip ,
	Country,
	DOB ,
	Gender,
	MaritalStatus ,
	Height ,
	Weight,
	Cont_FirstName, 
	Cont_LastName,
	Cont_ContactMethod,
	Cont_PhoneOrEmail,
	Cont_Address1,
	Cont_Address2,
	Cont_City,
	Cont_State,
	Cont_Zip)
select 
	x12_834_benefit_enrollment_id,
	x12_transaction_id,
	L2000_ins02_ind_relationship_code,
	L2000_ins08_employment_status_code ,
	L2000_ref02_subscriber_id ,
	L2000_ref02_insured_grp_policy_num,
	L2000_ref02_23_subscriber_sup_id,
	L2100A_nm103_subscriber_last_nm ,
	L2100A_nm104_subscriber_first_nm ,
	L2100A_nm109_subscriber_id,
	L2100A_per103_member_comm_num_qual,
	L2100A_per104_member_comm ,
	L2100A_n301_subscriber_address1,
	L2100A_n302_subscriber_address2,
	L2100A_n401_subscriber_city ,
	L2100A_n402_subscriber_state ,
	L2100A_n403_subscriber_zip ,
	L2100A_n404_subscriber_country ,
	L2100A_dmg02_member_dob ,
	L2100A_dmg03_member_gender,
	L2100A_dmg04_member_marital_status ,
	L2100A_hlh02_member_height,
	L2100A_hlh03_member_weight,
	L2100G_nm104_resp_party_first_nm,
	L2100G_nm103_resp_party_last_nm,
	L2100G_per103_member_comm_num_qual,
	L2100G_per104_member_comm,
	L2100G_n301_resp_party_address1,
	L2100G_n302_resp_party_address2,
	L2100G_n401_resp_party_city,
	L2100G_n402_resp_party_state,
	L2100G_n403_resp_party_zip
from HIPAATalk.dbo.x12_834_benefit_enrollment
where isMVDProcessed = '0' or isMVDProcessed is null
order by x12_transaction_id,timestamp 

--select * from #tempInsRecords


-- Process each record separately
while exists (select * from #tempInsRecords)
begin
	select top 1 @recordId = recordId, 
		@x12_transaction_id = x12_transaction_id,
		@Relationship = Relationship,
		@EconomicStatus  = EconomicStatus,
		@InsGroupID = InsGroupID,
		@PolicyNumber = PolicyNumber,
		@MemberID = MemberID,
		@LastName = LastName,
		@FirstName = FirstName,
		@L2100A_nm109_subscriber_id = L2100A_nm109_subscriber_id,
		@ContactMethod = ContactMethod,
		@PhoneOrEmail = PhoneOrEmail,
		@Address1 = Address1,
		@Address2 = Address2,
		@City = City,
		@State = State,
		@Zip = Zip,
		@Country = Country,
		@DOB = DOB,
		@Gender = Gender,
		@MaritalStatus = MaritalStatus,
		@Height = Height,
		@Weight = Weight,
		@Cont_FirstName =Cont_FirstName, 
		@Cont_LastName = Cont_LastName,
		@Cont_ContactMethod = Cont_ContactMethod,
		@Cont_PhoneOrEmail = Cont_PhoneOrEmail,
		@Cont_Phone = Cont_Phone,
		@Cont_Email = Cont_Email,
		@Cont_Address1 = Cont_Address1,
		@Cont_Address2 = Cont_Address2,
		@Cont_City = Cont_City,
		@Cont_State = Cont_State,
		@Cont_Zip = Cont_Zip
	from #tempInsRecords 

	-- Check if subscriber id (L2100A_nm109_subscriber_id) is valued, if not then find the group owner record
	-- with same InsGroupID (common value for all members of the same group), where subscriber is valued
	if(len(isnull(@L2100A_nm109_subscriber_id,'')) = 0)
	begin
		select @L2100A_nm109_subscriber_id = L2100A_nm109_subscriber_id 
		from #tempInsRecords
		where InsGroupID = @InsGroupID
	end

	-- If it's not in temp table, try to get it from already processed records
	if(len(isnull(@L2100A_nm109_subscriber_id,'')) = 0)
	begin
		select @L2100A_nm109_subscriber_id = InsGroupID 
		from dbo.Link_GroupID_MVD_Ins
		where GroupId_834 = @InsGroupID
	end


	-- If it's still not found, skip it because maybe we can identify it in the next import
	-- TODO: To avoid infinite processing with the same record without group Id, limit unprocessed
	--		records by date
	
	if(len(isnull(@L2100A_nm109_subscriber_id,'')) <> 0)
	begin

		-- Check if insurance group has mvd group mapped
		if( exists (select * from Link_GroupID_MVD_Ins where InsGroupId = @L2100A_nm109_subscriber_id ) )
		begin
			select @MVDGroupId = MVDGroupId from Link_GroupID_MVD_Ins where InsGroupId = @L2100A_nm109_subscriber_id
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

		------------------------------- Map data

		-- Retrieve email and phone
		if( @ContactMethod = 'TE')
		begin
			select @Phone = @PhoneOrEmail
		end
		else if( @ContactMethod = 'EM')
		begin
			select @Email = @PhoneOrEmail
		end

		-- Check if the person is the primary owner of the insurance policy
		-- That person will become the primary ower of MVD account
		if (@Relationship = '18')
		begin
			select @isPrimary = 1
		end
		else
		begin
			select @isPrimary = 0
		end

		-- Gender
		select @MVDGender = MVDGenderId from Link_Gender_MVD_Ins where InsGenderId = @Gender
		
		-- Marital Status
		select @MVDMaritalStatus = MVDMaritalStatusId from Link_MaritalStatus_MVD_Ins 
		where InsMaritalStatusId = @MaritalStatus

		if( len(isnull(@MVDMaritalStatus,'')) = 0)
		begin
			-- Set to 'Please Select'
			select @MVDMaritalStatus = 0
		end

		-- Economic Status
		select @MVDEconomicStatus = MVDEconomicStatusId from  Link_EconomicStatus_MVD_Ins
		where InsEconomicStatusId = @EconomicStatus

		if( len(isnull(@MVDEconomicStatus,'')) = 0)
		begin
			-- Set to 'Please Select'
			select @MVDEconomicStatus = 0
		end

		---------------------------------------

		-- TODO: confim the logic
		-- Use L2100A_nm109_subscriber_id to map user to MVD record only for primary insurance owner
		-- This number can also be used 837
		if(@isPrimary = 1)
		begin
			select @MemberId = @L2100A_nm109_subscriber_id
		end

		-- Check if user was already imported
		if(not exists(select * from Link_LegacyMemberId_MVD_Ins where InsMemberId = @MemberId))
		begin
			-- Generate new MVD ID
			-- EXEC GenerateRandomString 1,0,1,'23456789ABCDEFGHJKLMNPQRSTWXYZ',10, @MVDId output 
			EXEC GenerateMVDId
					@firstName = @FirstName,
					@lastName = @LastName,
					@newID = @MVDId OUTPUT

			-- Repeat generating MVD ID until it's unique
			while exists (select * from MainICENUMBERGroups where ICENUMBER = @MVDId)
			begin
				-- EXEC GenerateRandomString 1,0,1,'23456789ABCDEFGHJKLMNPQRSTWXYZ',10, @MVDId output
				EXEC GenerateMVDId
						@firstName = @FirstName,
						@lastName = @LastName,
						@newID = @MVDId OUTPUT
			end

			--select 'group: ' + @MVDGroupId + ', new MVD Id: ' + @MVDId

			-- Create new user profile
			EXEC Set_NewImportedProfile
				@MVDGroup = @MVDGroupId,
				@834_GroupId = @InsGroupId,
				@MVDId = @MVDId,
				@LastName = @LastName,
				@FirstName = @FirstName,
				@IsPrimary = @isPrimary,
				@Phone = @Phone,
				@Email = @Email,
				@Address1 = @Address1,
				@Address2 = @Address2,
				@City = @City,
				@State = @State,
				@Zip = @Zip,
				@DOB = @DOB,
				@Gender = @MVDGender,
				@MaritalStatus = @MVDMaritalStatus,
				@EconomicStatus = @MVDEconomicStatus,
				@Height = @Height,
				@Weight = @Weight,
				-- @InsGroupID = @InsGroupID,
				-- User Primary subscriber SSN (or generated Id) to map to MVD ID
				@InsGroupID = @L2100A_nm109_subscriber_id,
				@InsMemberID = @MemberId,
				@Result = @UpdateResult OUTPUT

			-- Map Ins Member to MVD Member	
--			if(@UpdateResult = '0')
--			begin
--				insert into Link_LegacyMemberId_MVD_Ins (MVDId,InsMemberId)
--				values(@MVDId, @MemberId)
--			end	

			-- If employer information exists on record import into MVD
			if( len(isnull(@Cont_LastName,'')) != 0 and len(isnull(@Cont_PhoneOrEmail,'')) != 0)
			begin
				-- Retrieve email and phone
				if( @Cont_ContactMethod = 'TE')
				begin
					select @Cont_Phone = @Cont_PhoneOrEmail
				end
				else if( @Cont_ContactMethod = 'EM')
				begin
					select @Cont_Email = @Cont_PhoneOrEmail
				end

				EXEC Set_MainCareInfo
					@ICENUMBER = @MVDId
					,@LastName = @Cont_LastName
					,@FirstName = @Cont_FirstName
					,@Address1 = @Cont_Address1
					,@Address2 = @Cont_Address2
					,@City = @Cont_City
					,@State = @Cont_State
					,@Postal = @Cont_Zip
					,@PhoneHome = @Cont_Phone
					,@PhoneCell = ''
					,@PhoneOther = ''
					,@CareTypeId = '6' -- Care Type: Secondary Contact
					,@RelationshipId = '8' -- Relationship: Other
					,@ContactType = NULL
					,@EmailAddress = @Cont_Email
					,@NotifyByEmail = '0'
					,@NotifyBySMS = '0'
			end
		end
		else
		begin
			-- Update existing record
			select @MVDId = MVDId from Link_LegacyMemberId_MVD_Ins where InsMemberId = @MemberId		

			EXEC Upd_ImportedProfile
				@IceNumber = @MVDId,
				@LastName = @LastName,
				@FirstName = @FirstName,
				@Phone = @Phone,
				@Email = @Email,
				@Address1 = @Address1,
				@Address2 = @Address2,
				@City = @City,
				@State = @State,
				@Zip = @Zip,
				@DOB = @DOB,
				@Gender = @MVDGender,
				@MaritalStatus = @MVDMaritalStatus,
				@EconomicStatus = @MVDEconomicStatus,
				@Height = @Height,
				@Weight = @Weight

			-- Check if 834 Group Id is stored in Group Mapping table
			-- If not (it happens when record is imported from 837)
			-- update that value
			Update Link_GroupID_MVD_Ins 
			set GroupId_834 = @InsGroupID
			where MVDGroupId = @MVDGroupId

			-- Check if Employer data is provided and exists in contacts section
			if( len(isnull(@Cont_LastName,'')) != 0 and len(isnull(@Cont_PhoneOrEmail,'')) != 0)
			begin
				-- Retrieve email and phone
				if( @Cont_ContactMethod = 'TE')
				begin
					select @Cont_Phone = @Cont_PhoneOrEmail
				end
				else if( @Cont_ContactMethod = 'EM')
				begin
					select @Cont_Email = @Cont_PhoneOrEmail
				end

				--	TO DO: Determine based on provided data how we can identify if the contact was previously
				--		added e.g. contact id etc

				declare @contCount int, @recNumber int

				-- Check if already exists
				Select @contCount = count(*) from maincareinfo 
				where icenumber = @MVDId and LastName = @Cont_LastName
		
				if( @contCount = 0)
				begin
					-- insert new contact
					EXEC Set_MainCareInfo
						@ICENUMBER = @MVDId
						,@LastName = @Cont_LastName
						,@FirstName = @Cont_FirstName
						,@Address1 = @Cont_Address1
						,@Address2 = @Cont_Address2
						,@City = @Cont_City
						,@State = @Cont_State
						,@Postal = @Cont_Zip
						,@PhoneHome = @Cont_Phone
						,@PhoneCell = ''
						,@PhoneOther = ''
						,@CareTypeId = '6' -- Care Type: Secondary Contact
						,@RelationshipId = '8' -- Relationship: Other
						,@ContactType = NULL
						,@EmailAddress = @Cont_Email
						,@NotifyByEmail = '0'
						,@NotifyBySMS = '0'
				end
				else if (@contCount = 1)
				begin			
					select @recNumber = RecordNumber from maincareinfo 
					where icenumber = @MVDId and LastName = @Cont_LastName

					-- update existing contact
					EXEC Upd_MainCareInfo
						@RecNum = @recNumber
						,@LastName = @Cont_LastName
						,@FirstName = @Cont_FirstName
						,@Address1 = @Cont_Address1
						,@Address2 = @Cont_Address2
						,@City = @Cont_City
						,@State = @Cont_State
						,@Postal = @Cont_Zip
						,@PhoneHome = @Cont_Phone
						,@PhoneCell = ''
						,@PhoneOther = ''
						,@CareTypeId = '6' -- Care Type: Secondary Contact
						,@RelationshipId = '8' -- Relationship: Other
						,@ContactType = NULL
						,@EmailAddress = @Cont_Email
						,@NotifyByEmail = '0'
						,@NotifyBySMS = '0'
				end
			end

			SELECT @UpdateResult = '0'
		end
		
		if( @UpdateResult = '0' )
		begin
			-- Set Record as already processed
			update HIPAATalk.dbo.x12_834_benefit_enrollment
			set isMVDProcessed = '1'
			where x12_834_benefit_enrollment_id = @recordId
		end
	end

	delete from #tempInsRecords where recordId = @recordId
end

drop table #tempInsRecords