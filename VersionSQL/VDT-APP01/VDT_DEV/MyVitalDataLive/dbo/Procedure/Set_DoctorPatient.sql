/****** Object:  Procedure [dbo].[Set_DoctorPatient]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 6/8/2009
-- Description:	Add new patient to specified doctor
--  @Result values:
--		0 - record successfully created
--		-1 - error creating record
--		-2 - same record already exists
--		-3 - doctor ID not found
--		-4 - patient ID not found
-- =============================================
CREATE PROCEDURE [dbo].[Set_DoctorPatient]
	@DoctorID varchar(50),
	@PatientID varchar(50),		-- Insurance Member ID
	@CustomerID int,
	@Result	int out
AS
BEGIN
	SET NOCOUNT ON;


--select @doctorID = '1003000183',
--	@patientid = 'ble3',
--	@customerid = '1'

	set @Result = -1
	
	declare @mvdid varchar(15),
		@primaryRoleID int,			-- lookup ID of primary physician
		@otherRoleID int

	select @mvdid = mvdid
	from Link_MemberId_MVD_Ins
	where InsMemberID = @PatientID
		and cust_id = @customerID

	if( len(isnull(@mvdid,'')) = 0)
	begin
		-- Record wasn't found
		set @Result = -4
	end
	else if exists (select mvdid from dbo.Link_HPMember_Doctor 
		where mvdid = @mvdid and doctor_id = @DoctorID)
	begin
		set @Result = -2
	end
	else
	begin
		declare @tempEntityType varchar(20),
			@tempOrgName varchar(50),
			@tempLastName varchar(50),
			@tempFirstName varchar(50)

		-- Get doctors info
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
		EXEC Get_ProviderByID @ID = @DoctorID

		if exists (select npi from @tempResult)
		begin

			select 
				@tempEntityType = type,
				@tempOrgName = organizationName,
				@tempLastName = lastName,
				@tempFirstName = firstName
			from @tempResult

			if(@tempEntityType = '2')
			begin
				-- Organization
				select @tempLastName = @tempOrgName,
					@tempFirstName = ''		
			end

			insert into dbo.Link_HPMember_Doctor (mvdid,doctor_Id,doctorFirstName,doctorLastName,created)
			values(@mvdid,@doctorId,@tempFirstName,@tempLastName,getutcdate())
		
			if(@tempEntityType = '1')
			begin
				select @primaryRoleID = RoleID
				from LookupRoleID 
				where RoleName = 'Primary Care Physician'

				-- Add doctor to the list of specialists for that patient
				if not exists (select recordnumber from MainSpecialist where icenumber = @mvdid and lastname = @tempLastName and firstname = @tempFirstName)
				begin

					insert into MainSpecialist ([ICENUMBER]
					   ,[LastName]
					   ,[FirstName]
					   ,[Address1]
					   ,[Address2]
					   ,[City]
					   ,[State]
					   ,[Postal]
					   ,[Phone]
					   ,[RoleID]
					   ,[CreationDate]
					   ,[ModifyDate])
					select @mvdid, lastname,firstname,address1,address2,city,state,zip,phone,@primaryRoleID,getutcdate(),getutcdate()
					from @tempResult
				end
				else
				begin
					select @otherRoleID = RoleID
					from LookupRoleID 
					where RoleName = 'Other'

					-- If the doctor exists with role 'Other' change it to 'Primary Care Phisician'
					update MainSpecialist 
					set roleID = @primaryRoleID
					where icenumber = @mvdid and lastname = @tempLastName and firstname = @tempFirstName and roleID = @otherRoleID
				end
			end

			set @Result = 0
		end
		else
		begin
			set @Result = -3
		end
	end
END