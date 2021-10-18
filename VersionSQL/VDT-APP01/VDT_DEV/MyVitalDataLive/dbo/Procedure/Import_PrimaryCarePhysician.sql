/****** Object:  Procedure [dbo].[Import_PrimaryCarePhysician]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 11/18/2009
-- Description:	Process Primary Care Physician info for specified member
-- Date			Name			Comments
--02/21/2017	PPetluri		Added logic when TIN = XXXXXXXXX
--03/15/2017	PPetluri		Modified proc to fix issue of duplicate ROLEID = 1 for same member with two different TIN and NPI 
-- =============================================
CREATE PROCEDURE [dbo].[Import_PrimaryCarePhysician]
	@MVDId varchar(20),
	@PCPName varchar(150),	-- format "1386618684      | Doe, John"
	@PCPPhone varchar(50),
	@PCP_Tin varchar(50),
	@Result int  output
AS
BEGIN
	SET NOCOUNT ON;

--select @MVDId = N'GR464293',
--		@PCPName = N'APCCTP4001 | ',
--		@PCPPhone = null

	declare @PCPLookupId int, @tempPCPNpi varchar(20), @tempPcpname varchar(150), 
		@tempPcpFName varchar(50), @tempPcpLName varchar(50), @tempIndex tinyInt

	declare @TempPcpOrgName varchar(50),
		@TempPcpLastName varchar(50),
		@TempPcpFirstName varchar(50),
		@TempPcpCredentials varchar(50),	-- prefix in the individual's name
		@TempPcpPhone varchar(50),
		@TempPcpType int,					-- 1 - individual, 2 - organization
		@TempPcpAddress1 varchar(50),
		@TempPcpAddress2 varchar(50),
		@TempPcpCity  varchar(50),
		@TempPcpState  varchar(2),
		@TempPcpZip	 varchar(50),
		@TempPcpFax varchar(50)

	-- Specialist info from LookupNPI table
	declare @tempPCP table 
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

	set @PCPLookupId = null

	select @PCPLookupId = roleID  
	from LookupRoleID 
	where rolename = 'Primary Care Physician'

	set @tempIndex = null
	set @tempIndex = charindex('|', @pcpname)

	if(@tempIndex is not null AND @tempIndex <> 0)
	begin
		set @tempPcpNpi = ltrim(rtrim( left(@pcpName,@tempIndex - 1)))
		set @tempPcpName = substring (@pcpname,@tempIndex + 1,len(@pcpname) - @tempIndex)

		set @tempIndex = null
		set @tempIndex = charIndex(',',@tempPcpName)
		if(@tempIndex is not null AND @tempIndex <> 0)
		begin
			set @tempPcpLName = ltrim(rtrim( left(@tempPcpName,@tempIndex - 1)))
			set @tempPcpFName = ltrim(rtrim(substring (@tempPcpName,@tempIndex + 1,len(@tempPcpName) - @tempIndex)))
		end
	end
		
	if(ISNULL(@tempPcpNPI,'') <> '' OR ISNULL(@tempPcpLName,'') <> '' OR ISNULL(@tempPcpFName,'') <> '')
	begin

		insert into @tempPCP (npi, type, organizationName, lastName, firstName, credentials, 
				address1, address2,city, state, zip, Phone, Fax)
		exec Get_ProviderByID @ID = @tempPcpNpi, @Name = ''

		if exists (select npi from @tempPCP)
		begin	
			-- Info was successfully retrieved from lookup

			select 
				@TempPcpOrgName = organizationName,
				@TempPcpLastName =
					case isnull(@tempPcpLName,'')
					when '' then lastName
					else @tempPcpLName
					end,
				@TempPcpFirstName = 
					case isnull(@tempPcpFName,'')
					when '' then firstName
					else @tempPcpFName
					end,				
				@TempPcpCredentials = credentials,
				@TempPcpPhone = Phone,
				@TempPcpType = type,
				@TempPcpAddress1 = Address1,
				@TempPcpAddress2 = Address2,
				@TempPcpCity  = City,
				@TempPcpState = State,
				@TempPcpZip	 = zip,
				@TempPcpPhone = phone,
				@TempPcpFax = fax
			from @tempPcp
			
			-- If the provider is organization and first and last name wasn't provided then
			-- use organization name as last name
			if(ISNULL(@TempPcpLastName,'') = '' AND ISNULL(@TempPcpFirstName,'') = '' and ISNULL(@TempPcpOrgName,'') <> '')
			begin
				set @TempPcpLastName = @TempPcpOrgName
			end
		end
		else
		begin
		
			select 
				@TempPcpLastName = @tempPcpLName,
				@TempPcpFirstName = @tempPcpFName,
				@TempPcpPhone = @PCPPhone
				
			if exists(select top 1 * from Link_MemberId_MVD_Ins li where MVDId = @MVDId and Cust_ID = 11)
			begin
				-- driscoll record with bad NPI
				select @TempPcpLastName = 'Driscoll provider not found', @TempPcpFirstName = ''
			end			
		end

		if (len(@TempPcpLastName) > 0 OR len(@TempPcpFirstName) > 0)			
		begin
		
			if(not exists(
				Select recordnumber 
				from mainspecialist
				where icenumber = @mvdid 
					AND 
					(
						NPI = @tempPcpNPI 
						--OR 
						and (lastName = @TempPcpLastName AND firstName = @TempPcpFirstName)
					)
				)
			)
			begin
				if ((Select distinct 1 from MainSpecialist where icenumber = @mvdid )= 1 )
				begin
				IF (@PCP_Tin <> 'XXXXXXXXX')
				begin
					update MainSpecialist set RoleID = 3
					where ICENUMBER = @MVDId and RoleID = @PCPLookupId
			
					insert into MainSpecialist([ICENUMBER],[LastName],[FirstName],[Address1],[Address2],[City],	
						[State],[Postal],[Phone],[RoleID],[CreationDate],[ModifyDate],[NPI],TIN)
					values (@mvdid,@TempPcpLastName,@TempPcpFirstName,@TempPcpAddress1,@TempPcpAddress2,@TempPcpCity,
						@TempPcpState,@TempPcpzip,left(@TempPcpPhone,10),@PCPLookupId,getutcdate(),getutcdate(),@tempPcpNPI, @PCP_Tin)
				end
				end
				else --if (Select distinct 1 from MainSpecialist where icenumber = @mvdid )<> 1
				begin
					insert into MainSpecialist([ICENUMBER],[LastName],[FirstName],[Address1],[Address2],[City],	
						[State],[Postal],[Phone],[RoleID],[CreationDate],[ModifyDate],[NPI],TIN)
					values (@mvdid,@TempPcpLastName,@TempPcpFirstName,@TempPcpAddress1,@TempPcpAddress2,@TempPcpCity,
						@TempPcpState,@TempPcpzip,left(@TempPcpPhone,10),@PCPLookupId,getutcdate(),getutcdate(),@tempPcpNPI, @PCP_Tin)
				end
			end
			else
			begin
			IF (@PCP_Tin <> 'XXXXXXXXX')
				begin
					-- Promote to primary
					update MainSpecialist set RoleID = 3
					where ICENUMBER = @MVDId and RoleID = @PCPLookupId
				
					update MainSpecialist set RoleID = @PCPLookupId, TIN = @PCP_Tin, ModifyDate = GETUTCDATE()
					where ICENUMBER = @MVDId and 	
						(
							NPI = @tempPcpNPI 
							--OR 
							and (lastName = @TempPcpLastName AND firstName = @TempPcpFirstName)
						)								
				end
			end
		end
	end
	else if ( len(isnull(@tempPcpLName,'')) > 0 AND len(isnull(@tempPcpFName,'')) > 0 )
	begin

		if not exists(
			Select recordnumber 
			from mainspecialist
			where icenumber = @mvdid 
				AND lastName = @tempPcpLName AND firstName = @tempPcpFName
		)
		begin
		IF (@PCP_Tin <> 'XXXXXXXXX')
				begin
					update MainSpecialist set RoleID = 3
					where ICENUMBER = @MVDId and RoleID = @PCPLookupId

					insert into MainSpecialist([ICENUMBER],[LastName],[FirstName],[Address1],[Address2],[City],	
						[State],[Postal],[Phone],[RoleID],[CreationDate],[ModifyDate],[NPI],TIN)
					values (@mvdid,@tempPcpLName,@tempPcpFName,'','','',
						NULL,'','',@PCPLookupId,getutcdate(),getutcdate(),NULL,@PCP_Tin)
				end
		end
	end
	else
	begin
		set @Result = -1
	end
END