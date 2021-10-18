/****** Object:  Procedure [dbo].[Import_HL7_NTE_Note_Single]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 6/24/2010
-- Description:	Import single HL7 Note record
-- =============================================
CREATE PROCEDURE [dbo].[Import_HL7_NTE_Note_Single] 
	@RecordID int,						-- MVD generated ID
	@InsPolicyNumber varchar(50),		-- use as member identifier 
	@MSH_ID int,
	@LabDataProviderName varchar(50),
	@LabDataProviderID int,
	@OBX_Ref_ID int,
	@NTE_1_SetID varchar(10),
	@NTE_2_SourceOfComment varchar(50),
	@NTE_3_Comment varchar(100),
	@OrderingPhysicianID varchar(50),
	@OrderingPhysicianFirstname varchar(50),
	@OrderingPhysicianLastname varchar(50),
	@OrderingOrganization varchar(50),
	@ImportResult int	out			-- 0 - success, -1 - failure or unknown item found, -2 - item listed on "ignore list"
AS
BEGIN
	SET NOCOUNT ON;

	declare @mvdid varchar(20),

		-- provider info from LookupNPI table
		@TempUpdatedByNPI varchar(20),
		@TempProvOrgName varchar(50),
		@TempProvLastName varchar(50),
		@TempProvFirstName varchar(50),
		@TempProvCredentials varchar(50),	-- prefix in the individual's name
		@TempProvPhone varchar(50),
		@TempProvType int					-- 1 - individual, 2 - organization

	declare @tempProv table 
	(
		npi varchar(50),
		type char(1),
		organizationName varchar(50),
		lastName varchar(50),
		firstName varchar(50),
		credentials varchar(50),
		address1 varchar(50),
		address2 varchar(50),
		city  varchar(50),
		state  varchar(2),
		zip	 varchar(50),
		Phone varchar(10),
		Fax varchar(50)
	)

	if(isnull(@InsPolicyNumber,'') <> '')
	begin
		select @mvdid = mvdid 
		from dbo.Link_MemberId_MVD_Ins
		where insmemberID = dbo.RemoveLeadChars(@InsPolicyNumber,'0')

		if(isnull(@mvdid,'') <> '')
		begin			

			-- Retrieved provider info if it could be located in lookup NPI table
			insert into @tempProv (npi, type, organizationName, lastName, firstName, credentials, 
					address1, address2,city, state, zip, Phone, Fax)
			exec Get_ProviderByID @ID = @OrderingPhysicianID, @Name = @OrderingPhysicianLastname

			SELECT	TOP 1
				--@TempProvOrgName = organizationName,
				--@TempProvLastName = lastName,
				--@TempProvFirstName = firstName,
				--@TempProvCredentials = credentials,
				@TempProvPhone = Phone
				--@TempProvType = type
			FROM	@tempProv

			-- TODO: check what kind of check in case of same duplicate result
			-- e.g. result not found in lookup table

			if not exists (select recordNumber from MainLabNote where icenumber = @mvdid 
				and resultID = @OBX_Ref_ID
				and note = @NTE_3_Comment)
			begin
				if( isnull(@NTE_3_Comment,'') <> '')
				begin
					INSERT INTO dbo.MainLabNote
					   (ICENUMBER
					   ,ResultID
					   ,Note
					   ,CreatedBy
					   ,CreatedByOrganization
					   ,UpdatedBy
					   ,UpdatedByOrganization
					   ,UpdatedByContact
					   ,CreatedByNPI
					   ,UpdatedByNPI
					   ,SourceName)
					VALUES
						(@mvdid,
						@OBX_Ref_ID,
						@NTE_3_Comment,
						@OrderingPhysicianFirstname + ' ' + @OrderingPhysicianLastname,
						@OrderingOrganization,
						@OrderingPhysicianFirstname + ' ' + @OrderingPhysicianLastname,
						@OrderingOrganization,
						@TempProvPhone,
						@OrderingPhysicianID,
						@OrderingPhysicianID,
						@LabDataProviderName)
				end
			end

			set @ImportResult = 0
		end
		else
		begin
			set @ImportResult = -1
		end
	end
	else
	begin
		set @ImportResult = -1
	end
END