/****** Object:  Procedure [dbo].[ImportHP_Facility_837]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 9/17/2008
-- Description:	Import 837 facility info into MVD member record
--		If the record exists, update. Otherwise create new record
--		Return import status: 0 - success, -1 - failure		
-- =============================================
CREATE PROCEDURE [dbo].[ImportHP_Facility_837]
	@MVDId varchar(15),
	@FacLastName varchar (35),
	@FacFirstName varchar(25),
	@FacId varchar(80),
	@FacAddress1 varchar(55),
	@FacAddress2 varchar(55),
	@FacCity varchar(30),
	@FacState char(2),
	@FacZip varchar(15),
	@Result int output

as
	declare @MVDRoleId int

	-- TODO: Check how we can identify if the provided info is valid
	-- Temporarly only check for last name
	if(len(isnull(@FacLastName,'')) <> 0)
	begin

		BEGIN TRY						
			-- TODO: check what type of speciailist should be set for the imported data
			-- Temporarily use Secondary Specialist
			select top 1 @MVDRoleId = RoleId from LookupRoleID
			where RoleName like 'Secondary%'

			-- Check if the facility was already imported
			-- TODO: Check if there is unique identifier which we can use
			--	to link already imported facility and verify if it already exists on record
			if(not exists(select LastName from MainSpecialist where ICENUMBER = @MVDId and LastName = @FacLastName))
			begin
				-- Create new instance
				INSERT INTO MainSpecialist (ICENUMBER, LastName, FirstName, Address1, Address2,
					City, State, Postal, Phone, PhoneCell, FaxPhone, RoleId, 
					CreationDate, ModifyDate) 
				VALUES (@MVDId, @FacLastName, @FacFirstName, @FacAddress1, @FacAddress2, @FacCity, @FacState,
					@FacZip, '', '', '', @MVDRoleId,
					GETUTCDATE(), GETUTCDATE())
			end
			else
			begin
				-- Update existing record
				UPDATE MainSpecialist SET
					FirstName = @FacFirstName, 
					Address1 = @FacAddress1, 
					Address2 = @FacAddress2,
					City = @FacCity, 
					State = @FacState, 
					Postal = @FacZip, 
					RoleId = @MVDRoleId, 
					ModifyDate = GETUTCDATE()
					WHERE ICENUMBER = @MVDId and LastName = @FacLastName				
			end

			SELECT @Result = 0
		END TRY
		BEGIN CATCH
			SELECT @Result = -1

			EXEC ImportCatchError	
		END CATCH
	end