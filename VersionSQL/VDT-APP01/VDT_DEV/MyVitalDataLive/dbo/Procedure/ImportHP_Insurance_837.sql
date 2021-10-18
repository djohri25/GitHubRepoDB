/****** Object:  Procedure [dbo].[ImportHP_Insurance_837]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 9/15/2008
-- Description:	Import 837 inurance info into MVD member record
--		If the record exists, update. Otherwise create new record
--		Return import status: 0 - success, -1 - failure		
-- =============================================
CREATE PROCEDURE [dbo].[ImportHP_Insurance_837]
	@MVDId varchar(15),
	@InsType char(1),
	@InsLastName varchar(35),
	@InsFirstName varchar(25),
	@InsProviderId varchar(80),
	@InsAddress1 varchar(55),
	@InsAddress2 varchar(55),
	@InsCity varchar(30),
	@InsState char(2),
	@InsZip varchar(15),
	@InsPolicyHolder varchar(50),
	@InsContactMethod char(2), -- communication method TE or EM
	@InsPhoneOrEmail varchar(80),
	@Result int output

as
	declare @Phone varchar(10),
		@MVDInsuranceTypeId int

	SELECT @Result = 0		-- default return value

	-- TODO: Check how we can identify if the provided info is about the patient
	--		because she/he doesn't have insurance
	-- Temporarly only check for first name
	if(len(isnull(@InsLastName,'')) <> 0 and len(isnull(@InsFirstName,'')) = 0)
	begin

		BEGIN TRY

			-- Map data
			if(@InsContactMethod = 'TE')
			begin
				select @Phone = left(@InsPhoneOrEmail,10) 
			end
			-- TODO: check what type of insurance should be set for imported data
			-- Temporarily use Primary Insurance
			select top 1 @MVDInsuranceTypeId = InsuranceTypeId from LookupInsuranceTypeID
			where InsurancetypeName like 'Primary%'

			-- Check if the insurance was already imported
			-- TODO: check if there is unique identifier which we can use
			--	to link already imported insurance and verify if it already exists on record
			if(not exists(select Name from MainInsurance where ICENUMBER = @MVDId and Name = @InsLastName))
			begin
				-- Create new instance
				INSERT INTO MainInsurance (ICENUMBER, [Name], Address1, Address2,
					City, State, Postal, Phone, PolicyHolderName, InsuranceTypeId, CreationDate, ModifyDate) 
				VALUES (@MVDId, @InsLastName, @InsAddress1, @InsAddress2, @InsCity, @InsState,
					@InsZip, @Phone, @InsPolicyHolder, @MVDInsuranceTypeId, GETUTCDATE(), GETUTCDATE())
			end
			else
			begin
				-- Update existing record
				UPDATE MainInsurance SET
					Address1 = @InsAddress1, 
					Address2 = @InsAddress2,
					City = @InsCity,
					State = @InsState, 
					Postal = @InsZip,
					Phone = @Phone,
					PolicyHolderName = @InsPolicyHolder, 
					InsuranceTypeId = @MVDInsuranceTypeId, 
					ModifyDate = GETUTCDATE()
					WHERE ICENUMBER = @MVDId and Name = @InsLastName				
			end
		END TRY
		BEGIN CATCH
			SELECT @Result = -1

			EXEC ImportCatchError	
		END CATCH
	end