/****** Object:  Procedure [dbo].[Set_NewImportedProfile]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 8/29/2008
-- Description:	Sets a new MVD account/profile
--		based on data imported from external
--		data providers. Currently used by Health
--		Plan claims data import
-- Date			Name				Comments
--01/20/2017	PPetluri			Added Code for StarKids section to showup on ICEReport sectionID's 29 & 30
--11/09/2017	PPetluri			Added a new Param @Occupation to populate the column in MainPersonalDetails
-- =============================================
CREATE PROCEDURE [dbo].[Set_NewImportedProfile]
	@MVDGroup varchar(15),
	@834_GroupId varchar(20),
	@MVDId varchar(15),

	@LastName varchar(50),
	@FirstName varchar(50),
	@MiddleName nvarchar(50) = NULL,

	@IsPrimary bit,

	@Phone varchar(10),
	@Email varchar(100),

	@Address1 varchar(50),
	@Address2 varchar(50),
	@City varchar(50),
	@State char(2),
	@Zip varchar(5),
	@DOB varchar(35),
	@Gender int,
	@SSN varchar(9) = null,

	@Ethnicity varchar(100) = null,
	@Language	varchar(100) = null,

	@MaritalStatus int,
	@EconomicStatus int,
	@Height int,
	@Weight int,

	@InsGroupID varchar(30),
	@InsMemberID varchar(30),
	@LOB	VARCHAR(10)	= null,
	@Occupation	VARCHAR(50) = null,
	@CreatedBy nvarchar(250) = null,		-- Only set when Individual creates a record
	@CreatedByContact nvarchar(50) = null,	-- Common field for CreatedBy and Organization
	@Organization nvarchar(250) = null,
	@HPCustomerId int = null,

	@InCaseManagement bit = null,
	@NarcoticLockdown bit = null,
	@System_Memid varchar(30) = null,
	
	@RecordNumber int OUTPUT,
	@Result int OUTPUT
AS
BEGIN

	SET NOCOUNT ON

	Declare @LOB_ID	INT
--BEGIN TRY 
--BEGIN TRAN 
	-- Check if MVD ID already exists
	IF EXISTS(SELECT ICENUMBER FROM MainICENUMBERGroups  IG JOIN Link_LegacyMemberId_MVD_Ins L ON IG.ICENUMBER = L.MVDID
				WHERE  L.Cust_ID = @HPCustomerId and L.InsMemberId = CAST(@InsMemberID as VARCHAR(20)))
	BEGIN
		SELECT @Result = -1
		print ' IceNumber existed, regenerate new #'
		--Rollback TRAN
		RETURN
	END

	IF NOT EXISTS(SELECT ICEGROUP FROM MainICEGROUP WHERE ICEGROUP = @MVDGroup)
	BEGIN
		-- This is the first profile of the group so create group related records
		INSERT INTO MainICEGROUP (ICEGROUP, GroupName, SoftwareKey, GroupMax, CreationDate, ModifyDate) 
		VALUES (@MVDGroup, 'HEALTHPLAN', NULL, 1, GETUTCDATE(), GETUTCDATE())	

		-- In Health Plan of Michigan there is no groups of members, each record has it's own separate MVD account
		IF LEN(ISNULL(@834_GroupId,'')) > 0

			INSERT INTO dbo.Link_GroupID_MVD_Ins (MVDGroupId, InsGroupId, GroupId_834, Created)
			VALUES(@MVDGroup, @InsGroupId, @834_GroupId, GETUTCDATE())
	END



	INSERT INTO MainICENUMBERGroups (ICEGROUP, ICENUMBER, MainAccount, CreationDate, ModifyDate) 
	VALUES (@MVDGroup, @MVDId, @IsPrimary, GETUTCDATE(), GETUTCDATE())

	-- Link MVD record to HP record
	INSERT INTO Link_LegacyMemberId_MVD_Ins (MVDId,InsMemberId,Cust_ID,System_Memid)
	VALUES(@MVDId, CAST(@InsMemberID as VARCHAR(20)), @HPCustomerId, @System_Memid)

	IF (@LOB is not null)
	BEGIN
		Select @LOB_ID = CodeID from Lookup_Generic_Code WHere Cust_ID = @HPCustomerId and Label = @LOB
	END

	INSERT INTO MainPersonalDetails (ICENUMBER, LastName, FirstName, MiddleName, GenderID, SSN, DOB, Address1, Address2, 
		City, State, PostalCode, HomePhone, Email, HeightInches, WeightLbs, MaritalStatusID,
		EconomicStatusID, CreationDate, ModifyDate, CreatedBy, CreatedByOrganization, UpdatedBy, UpdatedByOrganization, UpdatedByContact,
		InCaseManagement, NarcoticLockdown, Organization, Ethnicity, Language, Occupation)
	VALUES (@MVDId, @LastName, @FirstName, @MiddleName, @Gender, @SSN, @DOB, @Address1, @Address2, 
		@City, @State, @Zip, @Phone, @Email, @Height, @Weight, @MaritalStatus, 
		@EconomicStatus, GETUTCDATE(), GETUTCDATE(), @CreatedBy, @Organization, @CreatedBy, @Organization, @CreatedByContact,
		@InCaseManagement, @NarcoticLockdown, CAST(@LOB_ID as varchar(10)), @Ethnicity, @Language, @Occupation)

	SELECT	@RecordNumber = SCOPE_IDENTITY()

	INSERT INTO UserAdditionalInfo (MVDID,IsPackageSent) 
	VALUES (@MVDId, '0')

	-- Set default section permissions to true
	-- Personal
	EXEC Set_DefaultSectionPermission @IceNumber = @MVDId, @SectionId = 5
	-- Diseases/Conditions
	EXEC Set_DefaultSectionPermission @IceNumber = @MVDId, @SectionId = 8
	-- Insurance polices
	EXEC Set_DefaultSectionPermission @IceNumber = @MVDId, @SectionId = 9
	-- Allergies
	EXEC Set_DefaultSectionPermission @IceNumber = @MVDId, @SectionId = 14
	-- Contact List
	EXEC Set_DefaultSectionPermission @IceNumber = @MVDId, @SectionId = 22
	-- Medication
	EXEC Set_DefaultSectionPermission @IceNumber = @MVDId, @SectionId = 27
	-- Surgeries
	EXEC Set_DefaultSectionPermission @IceNumber = @MVDId, @SectionId = 28
	-- StarKids
	IF (@LOB = 'K')
	BEGIN
		-- StarKids Insurance Detailsm - Driscoll
		EXEC Set_DefaultSectionPermission @IceNumber = @MVDId, @SectionId = 29
		-- StarKids AdditionalInformation - Driscoll
		EXEC Set_DefaultSectionPermission @IceNumber = @MVDId, @SectionId = 30
	END

	SET @Result = 0
--COMMIT Tran
--END TRY
--BEGIN CATCH
--ROLLBACK
----print 'catch'
--Set @Result = -1
--END CATCH
	
END