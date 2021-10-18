/****** Object:  Procedure [dbo].[Get_PatientIDType]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 3/10/2009
-- Description:	Returns the list of ID type the patient
--	can be looked up by, e.g. 
--	- MVD ID
--  - Every health plan customer ID existing in the system
--	- Social Security Number
-- =============================================
CREATE Procedure [dbo].[Get_PatientIDType] 
	@Filter varchar(50),
	@Username varchar(50)
as

set nocount on

declare @childrensHospitalID int, @FloridaDelandHospID int

if(@Filter is not null AND @Filter = 'MVD')
begin
	Select ID, Name From LookupPatientIDType where name like 'MyVitalData%' OR name like 'MVD%'
end
else
begin
	declare @tempResult table (recordnumber int identity(1,1),id int, name varchar(50))

	select @childrensHospitalID = Id from mainemshospital where name like 'Children% Medical Center' -- use 'like' because of apostrophe in name 

	select @FloridaDelandHospID = id from  mainemshospital where name = 'Florida Hospital DeLand'

	if( db_name() <> 'MyVitalDataDemo')
	begin

		if not exists (select primarykey from mainems where (email = @username or username = @username) AND (companyID = @childrensHospitalID OR companyID = @FloridaDelandHospID ))
			AND exists (select primarykey from mainems where (email = @username or username = @username))	
		begin
			-- TEMP: since currently we have only one HP customer set it as default
			insert into @tempResult (id, name)
			select Cust_ID, Name + ' ID' from HPCustomer
			where name = 'Health Plan of Michigan'

			insert into @tempResult (id, name)	
			(Select ID, Name From LookupPatientIDType
			union
			select Cust_ID, 
				case Name
					when 'Amerigroup' then Name + ' ID OR Medicaid ID' 
					else Name + ' ID'
				end
			from HPCustomer
			where name <> 'Health Plan of Michigan'
				and Active = 'True'
				and parentID is NULL)
		end
		else if exists (select ID from MDUser where Username = @Username)
		begin
			-- Doctor Link user
			insert into @tempResult (id, name)	
			Select ID, Name From LookupPatientIDType where name = 'Member ID'

			--insert into @tempResult (id, name)	
			--Select ID, Name From LookupPatientIDType where name = 'Medicaid ID'

			--insert into @tempResult (id, name)			
			--select Cust_ID, Name + ' ID' from HPCustomer
			--where (name = 'Amerigroup' OR Name = 'Parkland')
			--	and Active = 'True'
			--	and parentID is NULL
						
		end
		else
		begin
			-- Customized list for Children's Medical Center
			insert into @tempResult (id, name)
			select Cust_ID, Name + ' ID OR Medicaid ID' from HPCustomer
			where name = 'Amerigroup'

			insert into @tempResult (id, name)	
			Select ID, Name From LookupPatientIDType where name = 'Medicaid ID'

			insert into @tempResult (id, name)	
			Select ID, Name From LookupPatientIDType where name = 'MyVitalData ID'

			insert into @tempResult (id, name)	
			Select ID, Name From LookupPatientIDType where name = 'Social Security Number'

			insert into @tempResult (id, name)			
			select Cust_ID, Name + ' ID' from HPCustomer
			where name <> 'Amerigroup'
				and Active = 'True'
				and parentID is NULL
		end
	end
	else
	begin
		-- Demo system has custom list
		insert into @tempResult (id, name)	
		select Cust_ID, Name + ' ID' from HPCustomer
		where name = 'XYZ Health Plan'

		insert into @tempResult (id, name)	
		Select ID, Name From LookupPatientIDType 
		where name = 'Member ID'
		
		
		insert into @tempResult (id, name)	
		select ID, Name from LookupPatientIDType
		where name = 'Medicaid ID'
		
		insert into @tempResult (id, name)	
		select ID, Name from LookupPatientIDType
		where name = 'Social Security Number'

		insert into @tempResult (id, name)	
		select ID, Name from LookupPatientIDType
		where name = 'MyVitalData ID'
		
	end
	
	select id, name from @tempResult order by recordnumber
end