/****** Object:  Procedure [dbo].[Set_MainPersonalDetailsByEMS]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 8/16/2009
-- Description:	Update member personal info performed
--	by ER personnel and doctors
-- =============================================
CREATE PROCEDURE [dbo].[Set_MainPersonalDetailsByEMS]

	@ICENUMBER varchar(15),
	@Address1 varchar(50),
	@Address2 varchar(50),
	@City varchar(50),
	@State varchar(2),
	@PostalCode varchar(5),
	@HomePhone varchar(10),
	@CellPhone varchar(10),
	@WorkPhone varchar(10),
	@FaxPhone varchar(10),
	@BloodTypeId int,
	@OrganDonor varchar(3),
	@HeightInches int,
	@WeightLbs int,
	@Email varchar(50),
	@Language nvarchar(50),
	@Ethnicity nvarchar(50),
	@UpdatedBy nvarchar(250),
	@UpdaterType nvarchar(50),
	@EMS varchar(50) = null,
	@UserID_SSO varchar(50) = null,
	@Result int out				-- 0 - success, -1 - failure, -2 - user cannot be identified

AS

SET NOCOUNT ON

declare @tempUpdatedBy varchar(250), @tempUpdatedByOrganization varchar(250), 
	@tempUpdatedByNPI  varchar(50), @tempUpdatedByContact varchar(50)

-- Retrieve updater information
if(@UpdaterType = 'EMS')
begin
	select @tempUpdatedBy = (isnull(FirstName,'') + isnull(' ' + LastName,'')),
		@tempUpdatedByContact = Phone,
		@tempUpdatedByOrganization = Company,
		@tempUpdatedByNPI = (select NPI from mainemshospital where id = e.companyID) 
	from mainEMS e where Email = @UpdatedBy OR username = @UpdatedBy
end
else if(@UpdaterType = 'MD')
begin
	declare @tempResult table  
	(	npi varchar(50),
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

	insert into @tempResult
	EXEC Get_ProviderByID @ID = @UpdatedBy, @Name = NULL	

	if exists (select npi from @tempResult)
	begin
		select @tempUpdatedBy = 
				case [Type]
					when '1' then (isnull(FirstName,'') + isnull(' ' + LastName,''))
					else NULL
				end,
			@tempUpdatedByContact = Phone,
			@tempUpdatedByOrganization = 
				case [Type]
					when '2' then isnull(organizationName,'')
					else NULL
				end,
			@tempUpdatedByNPI = NPI 
		from @tempResult
	end
	else
	begin
		if exists(select * from mduser where username = @UpdatedBy	)
		begin
			select @tempUpdatedBy = (isnull(FirstName,'') + isnull(' ' + LastName,'')),
				@tempUpdatedByContact = Phone,
				@tempUpdatedByOrganization = Organization
			from mduser e 
			where username = @UpdatedBy		
		end
		else
		begin
			set @Result = -2
		end
	end	
end
else
begin
	set @Result = -2
end

if(len(isnull(@tempUpdatedBy,'')) > 0 OR len(isnull(@tempUpdatedByOrganization,'')) > 0)
begin

	-- Address
	declare @new varchar(250), @old varchar(250), @history varchar(250)

	select @new = isnull(@address1,'') + isnull(' ' + @address2,'') + isnull(' ' + @city,'') + isnull(' ' + @state,'') + isnull(' ' + @postalcode,'')

	select @old = isnull(address1,'') + isnull(' ' + address2,'') + isnull(' ' + city,'') + isnull(' ' + state,'') + isnull(' ' + postalcode,'')
	from MainPersonalDetails
	WHERE ICENUMBER = @ICENUMBER

	if( @old <> @new)
	begin
		if not exists ( select mvdid 
			from dbo.HPFieldValueHistory
			where mvdid = @icenumber and tableName = 'MainPersonalDetails' and FieldName = 'Address' )
		begin
			-- Backup value provided by HP into history table
			insert into dbo.HPFieldValueHistory (mvdid, tableName, FieldName, FieldValue)
			values (@icenumber, 'MainPersonalDetails', 'Address', @old)
		end

		--Update Address
		UPDATE MainPersonalDetails SET 
			Address1 = @Address1,
			Address2 = @Address2,
			City = @City,
			State = @State,
			PostalCode = @PostalCode
		WHERE ICENUMBER = @ICENUMBER

		-- TODO: Notify HP about address change
	end

	---------------- Start Home Phone
	select @old = '', @history = ''

	select @new = isnull(@HomePhone,'')

	select @old = isnull(HomePhone,'')
	from MainPersonalDetails
	WHERE ICENUMBER = @ICENUMBER

	if( @old <> @new)
	begin
		if not exists( select mvdid from dbo.HPFieldValueHistory
			where mvdid = @icenumber and tableName = 'MainPersonalDetails' and FieldName = 'HomePhone' )
		begin
			-- Backup value provided by HP into history table
			insert into dbo.HPFieldValueHistory (mvdid, tableName, FieldName, FieldValue)
			values (@icenumber, 'MainPersonalDetails', 'HomePhone', @old)
		end

		--Update Phone
		UPDATE MainPersonalDetails SET 
			HomePhone = @HomePhone
		WHERE ICENUMBER = @ICENUMBER

		-- TODO: Notify HP about HomePhone change
	end

	---------------- End Home Phone

	declare @HeightMonitorID int, @WeightMonitorID int, @curDate datetime

	-- Create history of height and weight
	-- Height
	select @HeightMonitorID = MonitoringID from dbo.LookupMonitoring where MonitoringName = 'Height'

	set @curDate = getdate()

	Exec Set_Monitoring
		@ICENUMBER = @icenumber,
		@MonitoringId = @HeightMonitorID,
		@MonitoringDate = @curDate,
		@MonitoringResult = @HeightInches

	-- Weight
	select @WeightMonitorID = MonitoringID from dbo.LookupMonitoring where MonitoringName = 'Weight'

	Exec [Set_Monitoring]
		@ICENUMBER = @icenumber,
		@MonitoringId = @WeightMonitorID,
		@MonitoringDate = @curDate,
		@MonitoringResult = @WeightLbs

	UPDATE MainPersonalDetails SET 
		Email = @Email,
		CellPhone = @CellPhone,
		WorkPhone = @WorkPhone,
		FaxPhone = @FaxPhone,		
		BloodTypeId = @BloodTypeId,
		OrganDonor = @OrganDonor,
		HeightInches = @HeightInches,
		WeightLbs = @WeightLbs,
		Ethnicity = @Ethnicity,
		Language = @Language,
		ModifyDate = GETUTCDATE(),
		UpdatedBy = @tempUpdatedBy,
		UpdatedByContact = @tempUpdatedByContact,
		UpdatedByOrganization = @tempUpdatedByOrganization,
		UpdatedByNPI = @tempUpdatedByNPI
	WHERE ICENUMBER = @ICENUMBER

	set @Result = 0
end
else
begin
	set @Result = -2
end

begin
	-- Record SP Log
	declare @params nvarchar(1000) = null
	set @params = LEFT('@ICENUMBER=' + ISNULL(@ICENUMBER, 'null') + ';' +
				  '@Address1=' + ISNULL(@Address1, 'null') + ';' +
				  '@Address2=' + ISNULL(@Address2, 'null') + ';' +
				  '@City=' + ISNULL(@City, 'null') + ';' +
				  '@State=' + ISNULL(@State, 'null') + ';' +
				  '@PostalCode=' + ISNULL(@PostalCode, 'null') + ';' +
				  '@HomePhone=' + ISNULL(@HomePhone, 'null') + ';' +
				  '@CellPhone=' + ISNULL(@CellPhone, 'null') + ';' +
				  '@WorkPhone=' + ISNULL(@WorkPhone, 'null') + ';' +
				  '@FaxPhone=' + ISNULL(@FaxPhone, 'null') + ';' +
				  '@BloodTypeId=' + CONVERT(varchar(50), @BloodTypeId) + ';' +
				  '@OrganDonor=' + ISNULL(@OrganDonor, 'null') + ';' +
				  '@HeightInches=' + CONVERT(varchar(50), @HeightInches) + ';' +
				  '@WeightLbs=' + CONVERT(varchar(50), @WeightLbs) + ';' +
				  '@Email=' + ISNULL(@Email, 'null') + ';' +
				  '@Language=' + ISNULL(@Language, 'null') + ';' +
				  '@Ethnicity=' + ISNULL(@Ethnicity, 'null') + ';' +
				  '@UpdatedBy=' + ISNULL(@UpdatedBy, 'null') + ';' +
				  '@UpdaterType=' + ISNULL(@UpdaterType, 'null') + ';' +
				  '@Result=' + CONVERT(varchar(50), @Result) + ';', 1000);
	exec [dbo].[Set_StoredProcedures_Log] '[dbo].[Set_MainPersonalDetailsByEMS]', @EMS, @UserID_SSO, @params
end