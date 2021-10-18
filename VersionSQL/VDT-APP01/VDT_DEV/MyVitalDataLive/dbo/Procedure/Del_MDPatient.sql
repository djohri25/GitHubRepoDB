/****** Object:  Procedure [dbo].[Del_MDPatient]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Del_MDPatient]
	@DoctorID varchar(20),
	@MvdID varchar(20)
as

set nocount on

Delete
From Link_HPMember_Doctor
Where mvdID = @MvdID
	and doctor_ID = @doctorID

-- Delete alert related to that patient
delete
from md_alert 
where mvdID = @MvdID
	and doctorID = @doctorID


-- Set current doctor as 'Other' on specialist list
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

	declare @tempEntityType varchar(20),
			@tempOrgName varchar(50),
			@tempLastName varchar(50),
			@tempFirstName varchar(50),
			@primaryRoleID int,
			@otherRoleID int,
			@tempCount int

	select 
		@tempEntityType = type,
		@tempOrgName = organizationName,
		@tempLastName = lastName,
		@tempFirstName = firstName
	from @tempResult

	if(@tempEntityType = '1')
	begin
		
		select @primaryRoleID = RoleID
		from LookupRoleID 
		where RoleName = 'Primary Care Physician'

		select @otherRoleID = RoleID
		from LookupRoleID 
		where RoleName = 'Other'

		select @tempCount = count(recordnumber) from MainSpecialist
		where icenumber = @mvdid and lastname = @tempLastName and firstname = @tempFirstName and RoleID = @primaryRoleID

		if(@tempCount = 1)
		begin
			update  MainSpecialist set RoleID = @otherRoleID
			where icenumber = @mvdid and lastname = @tempLastName and firstname = @tempFirstName and RoleID = @primaryRoleID
		end	
	end
end