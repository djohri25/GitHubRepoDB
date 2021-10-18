/****** Object:  Procedure [dbo].[Set_ImportContact]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 
-- Description:	Creates import Contact record
--	@Result values:
--		0 - insert successful
--		-1 - insert failed
--		-2 - insert failed - Attempt to create duplicate Primary Contact (At most one can exist per profile)
-- =============================================
CREATE PROCEDURE [dbo].[Set_ImportContact]

	@ICENUMBER varchar(15),
	@LastName varchar(50),
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
	@RelationshipId int = NULL,
	@ContactType varchar(20),
	@EmailAddress varchar(100) = NULL,
	@NotifyByEmail bit = NULL,
	@NotifyBySMS bit = NULL,
	@CreatedBy nvarchar(250) = NULL,			-- Only set when Individual creates a record
	@CreatedByContact nvarchar(256) = NULL,		-- Common field for CreatedBy AND Organization
	@Organization nvarchar(250) = NULL,
	@RecordNumber int OUTPUT,
	@Result int OUTPUT

AS
BEGIN

	SET NOCOUNT ON

	DECLARE @PrimContactTypeId int -- ID of the Primary Contact type

	SELECT TOP 1 @PrimContactTypeId = CaretypeID FROM LookupCareTypeID WHERE CareTypeName LIKE '%primary contact%'

	SET @Result = -1

	-- Don't allow to enter duplicate Primary Contacts per profile
	IF @PrimContactTypeId IS NOT NULL AND @CareTypeId = @PrimContactTypeId 
		AND EXISTS(SELECT ICENUMBER FROM MainCareInfo WHERE ICENUMBER = @ICENUMBER AND CareTypeId = @PrimContactTypeId)
	BEGIN
		SET @Result = -2
	END
	ELSE
	BEGIN
		INSERT INTO MainCareInfo (ICENUMBER, LastName, FirstName, Address1, Address2,
			City, State, Postal, PhoneHome, PhoneCell, PhoneOther, CareTypeId, 
			RelationshipId, CreationDate, ModifyDate,ContactType, EmailAddress, NotifyByEmail, 
			NotifyBySMS,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact) 
		VALUES
			(@ICENUMBER, @LastName, @FirstName, @Address1, @Address2, @City, @State,
			@Postal, @PhoneHome, @PhoneCell, @PhoneOther, @CareTypeId, @RelationshipId,
			GETUTCDATE(), GETUTCDATE(),@ContactType, @EmailAddress, @NotifyByEmail, @NotifyBySMS,
			@CreatedBy, @Organization, @CreatedBy, @Organization,@CreatedByContact)

		SELECT	@Result = 0, @RecordNumber = SCOPE_IDENTITY()
	END
END