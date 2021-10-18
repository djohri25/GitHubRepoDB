/****** Object:  Procedure [dbo].[ImportHP_Pers_837]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 9/12/2008
-- Description:	Import 837 personal info of the member.
--		If the record exists, update. Otherwise crete new record, and
--		update necessary relation tables (e.g. groups)
--		Return MVD ID of the updated/inserted record		
-- =============================================
CREATE PROCEDURE [dbo].[ImportHP_Pers_837]
	@IsPrimary bit,	
	@MemberID varchar(30),
	@InsGroupId  varchar(30),
	@MVDGroupId varchar(15),
	@LastName varchar(35),
	@FirstName varchar(25),
	@Address1 varchar(55),
	@Address2 varchar(55),
	@City varchar(30),
	@State char(2),
	@Zip varchar(15),
	@DOB varchar(35),
	@Gender char(1),
	@MVDId varchar(15) output,
	@Result int output			-- 0 - success, -1 - failure

as

	declare
		-- mvd data
		@MVDGender int,
		-- values not provided in 837 but retrieved (if exist) from already existing record
		@Phone varchar(10),
		@Email varchar(100),
		@MaritalStatus int,
		@EconomicStatus int,
		@Height int,
		@Weight int

	BEGIN TRY

		------------------------------- Map data

		-- Gender
		select @MVDGender = MVDGenderId from Link_Gender_MVD_Ins where InsGenderId = @Gender
			
		---------------------------------------

		-- Check if user was already imported
		if(not exists(select * from Link_MemberId_MVD_Ins where InsMemberId = @MemberId))
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

			-- Create new user profile
			EXEC Set_NewImportedProfile
				@MVDGroup = @MVDGroupId,
				@834_GroupId = '',
				@MVDId = @MVDId,
				@LastName = @LastName,
				@FirstName = @FirstName,
				@IsPrimary = @isPrimary,
				@Phone = '',
				@Email = '',
				@Address1 = @Address1,
				@Address2 = @Address2,
				@City = @City,
				@State = @State,
				@Zip = @Zip,
				@DOB = @DOB,
				@Gender = @MVDGender,
				@MaritalStatus = '',
				@EconomicStatus = '',
				@Height = '',
				@Weight = '',
				@InsGroupID = @InsGroupID,
				@InsMemberID = @MemberID,
				@Result = @Result OUTPUT
		end
		else
		begin
			-- Update existing record
			select @MVDId = MVDId from Link_MemberId_MVD_Ins where InsMemberId = @MemberId		

			-- We don't want to overwrite existing data on the existing record
			-- 837 don't provide that data so retrieve whatever is currently on record
			select 
				@Phone = HomePhone,
				@Email = Email,
				@Height = HeightInches,
				@Weight = WeightLbs,
				@MaritalStatus = MaritalStatusId,
				@EconomicStatus = EconomicStatusId
			from mainpersonaldetails
			where ICENUMBER = @MVDId

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
				@MaritalStatus = @MaritalStatus,
				@EconomicStatus = @EconomicStatus,
				@Height = @Height,
				@Weight = @Weight

			SELECT @Result = 0
		end


	END TRY
	BEGIN CATCH
		select @Result = -1		

		EXEC ImportCatchError	
	END CATCH