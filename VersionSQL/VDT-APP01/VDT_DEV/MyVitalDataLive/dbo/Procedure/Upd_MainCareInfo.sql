/****** Object:  Procedure [dbo].[Upd_MainCareInfo]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 
-- Description:	Updates Contact record
--	@Result values:
--		0 - update successful
--		-1 - update failed
--		-2 - update failed  - Attempt to set duplicate Primary Contact (At most one can exist per profile)
-- =============================================
CREATE PROCEDURE [dbo].[Upd_MainCareInfo]
	@RecNum int,
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
	@ContactType varchar(20) = null,
	@EmailAddress varchar(100) = null,
	@NotifyByEmail bit = null,
	@NotifyBySMS bit = null,
	@UpdatedBy nvarchar(250) = null,
	@UpdatedByContact nvarchar(256) = NULL,
	@Organization nvarchar(64) = NULL,
	@Result int output

As

SET NOCOUNT ON

declare @PrimContactTypeId int, -- ID of the Primary Contact type
	@OwnerICENUMBER varchar(20)

select top 1 @PrimContactTypeId = CaretypeID from LookupCareTypeID where CareTypeName like '%primary contact%'
select @OwnerICENUMBER = ICENUMBER from MainCareInfo where RecordNumber = @RecNum

set @Result = -1

-- Don't allow to enter duplicate Primary Contacts per profile
if(@PrimContactTypeId is not null and @CareTypeId = @PrimContactTypeId 
	and exists(select lastname from MainCareInfo 
		where Icenumber = @OwnerICENUMBER and CareTypeId = @PrimContactTypeId and RecordNumber != @RecNum))
begin
	set @Result = -2
end
else
begin

	UPDATE MainCareInfo	SET	
		LastName = @LastName,	
		MiddleName = @MiddleName,
		FirstName = @FirstName, 
		Address1 = @Address1, 
		Address2 = @Address2,
		City = @City, 
		State = @State, 
		Postal = @Postal, 
		PhoneHome = @PhoneHome, 
		PhoneCell = @PhoneCell,
		PhoneOther = @PhoneOther, 
		CareTypeId = @CareTypeId, 
		RelationshipId = @RelationshipId, 
		ModifyDate = GETUTCDATE(),
		ContactType = @ContactType, 
		EmailAddress = @EmailAddress,
		NotifyByEmail = @NotifyByEmail,
		NotifyBySMS = @NotifyBySMS,
		UpdatedBy =@UpdatedBy,
		UpdatedByContact = @UpdatedByContact,
		UpdatedByOrganization=@Organization
	WHERE RecordNumber = @RecNum

	set @Result = 0
end