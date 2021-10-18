/****** Object:  Procedure [dbo].[Set_NewMergedAccount]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 1/7/2011
-- Description:	Setup new MVD account from 2 provided accounts
-- =============================================
CREATE PROCEDURE [dbo].[Set_NewMergedAccount]
	@MVDID_1 varchar(20),
	@MVDID_2 varchar(20),
	@ResultMVDID varchar(20) out
AS
BEGIN
	SET NOCOUNT ON;

	declare @NewMVDID varchar(20),
		@modifyDateRec1 datetime,
		@firstName1 varchar(50),
		@lastName1 varchar(50),
		@modifyDateRec2 datetime,
		@firstName2 varchar(50),
		@lastName2 varchar(50),
		@firstName varchar(50),
		@lastName varchar(50),
		@NewMVDGroupId varchar(20)

	select @modifyDateRec1 = modifyDate,
		@firstName1 = FirstName,
		@lastName1 = LastName
	from MainPersonalDetails
	where ICENUMBER = @MVDID_1
			
	select @modifyDateRec2 = modifyDate,
		@firstName2 = FirstName,
		@lastName2 = LastName
	from MainPersonalDetails
	where ICENUMBER = @MVDID_2
	
	if(@modifyDateRec1 >= @modifyDateRec2)
	begin
		select @firstName = @firstName1,
			@lastName = @lastName1
	end
	else
	begin
		select @firstName = @firstName2,
			@lastName = @lastName2					
	end

	-- Generate new MVD GroupID
	EXEC GenerateRandomString 0,0,0,'23456789ABCDEFGHJKLMNPQRSTWXYZ',10, @NewMVDGroupId output

	-- Repeat generating MVD GroupID until it's unique
	WHILE EXISTS (SELECT ICEGROUP FROM MainICENUMBERGroups WHERE ICEGROUP = @NewMVDGroupId)
		EXEC GenerateRandomString 0,0,0,'23456789ABCDEFGHJKLMNPQRSTWXYZ',10, @NewMVDGroupId output

	-- Generate new MVD ID
	EXEC GenerateMVDId
		@firstName = @FirstName,
		@lastName = @LastName,
		@newID = @NewMVDID OUTPUT

	-- Repeat generating MVD ID until it's unique
	WHILE EXISTS (SELECT ICENUMBER FROM MainICENUMBERGroups WHERE ICENUMBER = @NewMVDID)
		EXEC GenerateMVDId
			@firstName = @FirstName,
			@lastName = @LastName,
			@newID = @NewMVDID OUTPUT

	INSERT INTO MainICEGROUP (ICEGROUP, GroupName, SoftwareKey, GroupMax, CreationDate, ModifyDate) 
	VALUES (@NewMVDGroupId, 'HEALTHPLAN', NULL, 1, GETUTCDATE(), GETUTCDATE())	
	
	-- PERSONAL			
	INSERT INTO MainICENUMBERGroups (ICEGROUP, ICENUMBER, MainAccount, CreationDate, ModifyDate) 
	VALUES (@NewMVDGroupId, @NewMVDID, 1, GETUTCDATE(), GETUTCDATE())

	
	INSERT INTO UserAdditionalInfo (MVDID,IsPackageSent) 
	VALUES (@NewMVDID, '0')

	-- Link MVD record to HP record
--			INSERT INTO Link_LegacyMemberId_MVD_Ins (MVDId,InsMemberId,Cust_ID)
--			VALUES(@NewMVDID, @InsMemberID, @HPCustomerId)

	-- Set default section permissions to true
	-- Personal
	EXEC Set_DefaultSectionPermission @IceNumber = @NewMVDID, @SectionId = 5
	-- Diseases/Conditions
	EXEC Set_DefaultSectionPermission @IceNumber = @NewMVDID, @SectionId = 8
	-- Insurance polices
	EXEC Set_DefaultSectionPermission @IceNumber = @NewMVDID, @SectionId = 9
	-- Allergies
	EXEC Set_DefaultSectionPermission @IceNumber = @NewMVDID, @SectionId = 14
	-- Contact List
	EXEC Set_DefaultSectionPermission @IceNumber = @NewMVDID, @SectionId = 22
	-- Medication
	EXEC Set_DefaultSectionPermission @IceNumber = @NewMVDID, @SectionId = 27
	-- Surgeries
	EXEC Set_DefaultSectionPermission @IceNumber = @NewMVDID, @SectionId = 28

	set @ResultMVDID = @NewMVDID
END