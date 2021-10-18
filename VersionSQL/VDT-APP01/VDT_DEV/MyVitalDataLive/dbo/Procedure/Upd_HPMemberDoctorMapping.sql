/****** Object:  Procedure [dbo].[Upd_HPMemberDoctorMapping]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 08/06/2009
-- Description:	 Saves the linking between HealthPlan/MVD members and doctors.
-- =============================================
CREATE PROCEDURE [dbo].[Upd_HPMemberDoctorMapping]
	@MemberID varchar(50),
	@CustomerId varchar(50),
	@Doctors varchar(max),		-- Comma separated list of doctors
	@Result int out				-- 0 - success, -1 - failed, -2 - cannot lookup doctor ID (NPI)
AS
BEGIN
	SET NOCOUNT ON;

	set @Result = -1

	declare @tempMemberId varchar(50), @tempAgentId varchar(50),
		@tempToDeleteID varchar(50)

	declare @toDeleteList table 
		(
			doctorID varchar(50), 			
			[DoctorFirstName] [varchar](50),
			[DoctorLastName] [varchar](50), 
			isProcessed bit default(0)
		)

	declare @tempDocID varchar(50),
		@tempEntityType varchar(20),
		@tempOrgName varchar(50),
		@tempLastName varchar(50),
		@tempFirstName varchar(50),
		@primaryRoleID int,			-- lookup ID of primary physician
		@otherRoleID int,
		@tempCount int

	-- Used to perform all operations before the final result is saved
	declare @temp_Link_HPMember_Doctor table
		(
			mvdid varchar(15),
			[Doctor_Id] [nvarchar](50),
			[DoctorFirstName] [varchar](50),
			[DoctorLastName] [varchar](50),
			[Created] [datetime]
		)

	declare @tempDoctors table 
		(
			id varchar(50),
			isProcessed bit default(0)
		)

	declare @mvdid varchar(20)

	select @mvdid = mvdid 
	from Link_MemberId_MVD_Ins
	where insmemberid = @memberid and cust_id = @CustomerId

	insert into @temp_Link_HPMember_Doctor
	select mvdid,
			[Doctor_Id],
			[DoctorFirstName],
			[DoctorLastName],
			[Created]
	from dbo.Link_HPMember_Doctor
	where mvdid = @mvdid		

	-- avoid inserting blank record
	if(len(isnull(@Doctors,'')) > 0)
	begin
		insert into @tempDoctors(id) 
			select data from dbo.split(@Doctors,',')
	end


	insert into @toDeleteList (doctorID,DoctorFirstName, DoctorLastName)
	select doctor_id,DoctorFirstName, DoctorLastName from @temp_Link_HPMember_Doctor
	where doctor_id not in
		(
			select id from @tempDoctors
		)

	select @primaryRoleID = RoleID
	from LookupRoleID 
	where RoleName = 'Primary Care Physician'

	select @otherRoleID = RoleID
	from LookupRoleID 
	where RoleName = 'Other'

	-- If doctor exists on specialist list set the role to Other
	while exists(select doctorid from @toDeleteList where isProcessed = 0)
	begin
		select top 1 @tempToDeleteID = doctorID,
			@tempFirstName = DoctorFirstName,
			@tempLastName = DoctorLastName			
		from @toDeleteList where isProcessed = 0


		select @tempCount = count(recordnumber) from MainSpecialist
		where icenumber = @mvdid and lastname = @tempLastName and firstname = @tempFirstName and RoleID = @primaryRoleID

		if(@tempCount = 1)
		begin
			update  MainSpecialist set RoleID = @otherRoleID
			where icenumber = @mvdid and lastname = @tempLastName and firstname = @tempFirstName and RoleID = @primaryRoleID
		end	

		update @toDeleteList set isProcessed = 1 where doctorID = @tempToDeleteID
	end

	-- Delete records which weren't selected from the origial list
	delete from @temp_Link_HPMember_Doctor
	where doctor_id not in
		(
			select id from @tempDoctors
		)

	-- Set process flag for records which already exist in the db
	update @tempDoctors 
	set isProcessed = '1'
	where id in
	(
		select doctor_id from @temp_Link_HPMember_Doctor
	)

	declare @tempDoctorInfo table
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

	-- The remaining doctor(s) are newly added
	while @result <> -2 and exists (select id from @tempDoctors where isProcessed <> 1)
	begin
		select @tempDocID = id from @tempDoctors where isProcessed <> 1

		-- Don't insert duplicate Ids
		if not exists (select doctor_id from @temp_Link_HPMember_Doctor where doctor_id = @tempDocID)
		begin

			-- Get doctors info
			insert into @tempDoctorInfo
			EXEC Get_ProviderByID @ID = @tempDocID

			if exists (select npi from @tempDoctorInfo)
			begin

				select 
					@tempEntityType = [type],
					@tempOrgName = organizationName,
					@tempLastName = lastName,
					@tempFirstName = firstName
				from @tempDoctorInfo

				if(@tempEntityType = '2')
				begin
					-- Organization
					select @tempLastName = @tempOrgName,
						@tempFirstName = ''		
				end

				insert into @temp_Link_HPMember_Doctor
				(
					mvdid,
					[Doctor_Id],
					[DoctorFirstName],
					[DoctorLastName],
					[Created]			
				)
				values 
				(
					@mvdid,
					@tempDocID,
					@tempFirstName,
					@tempLastName,
					getutcdate()
				)

				if(@tempEntityType = '1')
				begin
					-- Add doctor to the list of specialists for that patient
					if not exists (select recordnumber from MainSpecialist where icenumber = @mvdid and lastname = @tempLastName and firstname = @tempFirstName)
					begin
						select @primaryRoleID = RoleID
						from LookupRoleID 
						where RoleName = 'Primary Care Physician'

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
						from @tempDoctorInfo
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
			end
			else
			begin
				set @result = -2
			end		
		end

		delete from @tempDoctorInfo

		update @tempDoctors set isProcessed = 1 where id = @tempDocID		
	end

	if(@result <> -2)
	begin
		-- Store the final list of doctors
		delete from Link_HPMember_Doctor
		where mvdid = @mvdid

		insert into Link_HPMember_Doctor
		(
			mvdid,
			[Doctor_Id],
			[DoctorFirstName],
			[DoctorLastName],
			[Created]
		)
		select mvdid,
			[Doctor_Id],
			[DoctorFirstName],
			[DoctorLastName],
			[Created]
		from @temp_Link_HPMember_Doctor

		set @Result = 0
	end

END