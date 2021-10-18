/****** Object:  Procedure [dbo].[Set_MainCareInfo]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 
-- Description:	Creates Contact record
--	@Result values:
--		0 - insert successful
--		-1 - insert failed
--		-2 - insert failed - Attempt to create duplicate Primary Contact (At most one can exist per profile)
-- =============================================
CREATE PROCEDURE [dbo].[Set_MainCareInfo]

	@ICENUMBER varchar(15),
	@LastName varchar(50),
	@MiddleName varchar(50) = NULL,
	@FirstName varchar(50),
	@Address1 varchar(50),
	@Address2 varchar(50),
	@City varchar(50),
	@State varchar(2),
	@Postal varchar(5),
	@PhoneHome varchar(10),
	@PhoneCell varchar(10),
	@PhoneOther varchar(10),
	@CareTypeId int,
	@RelationshipId int = null,
	@ContactType varchar(20),
	@EmailAddress varchar(100) = null,
	@NotifyByEmail bit = null,
	@NotifyBySMS bit = null,
	@CreatedBy nvarchar(250) = null,
	@UpdatedBy nvarchar(250) = null,
	@UpdatedByContact nvarchar(256) = NULL,
	@Organization nvarchar(64) = NULL,
	@Result int output

as

set nocount on

declare @PrimContactTypeId int -- ID of the Primary Contact type

select top 1 @PrimContactTypeId = CaretypeID from LookupCareTypeID where CareTypeName like '%primary contact%'

set @Result = -1

-- Don't allow to enter duplicate Primary Contacts per profile
if(@PrimContactTypeId is not null and @CareTypeId = @PrimContactTypeId 
	and exists(select lastname from MainCareInfo where Icenumber = @ICENUMBER and CareTypeId = @PrimContactTypeId))
begin
	set @Result = -2
end
else
begin
	INSERT INTO MainCareInfo (ICENUMBER, LastName, MiddleName, FirstName, Address1, Address2,
		City, State, Postal, PhoneHome, PhoneCell, PhoneOther, CareTypeId, 
		RelationshipId, CreationDate, ModifyDate,ContactType, EmailAddress, NotifyByEmail, 
		NotifyBySMS,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByContact,UpdatedByOrganization) 
	VALUES
		(@ICENUMBER, @LastName, @MiddleName, @FirstName, @Address1, @Address2, @City, @State,
		@Postal, @PhoneHome, @PhoneCell, @PhoneOther, @CareTypeId, @RelationshipId,
		GETUTCDATE(), GETUTCDATE(),@ContactType, @EmailAddress, @NotifyByEmail, @NotifyBySMS,
		@CreatedBy,@Organization,@UpdatedBy,@UpdatedByContact,@Organization)

	set @Result = 0
end