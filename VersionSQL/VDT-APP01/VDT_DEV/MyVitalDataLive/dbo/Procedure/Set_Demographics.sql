/****** Object:  Procedure [dbo].[Set_Demographics]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dbo].[Set_Demographics]
(
	@CustID int,
	@Createdby varchar(100),
	@InsMemberID varchar(30),
	@EffectiveDate varchar(35),
	@TerminationDate varchar(35),
	@LastName varchar(50),
	@FirstName varchar(50),
	@MiddleName	nvarchar(50) = NULL,
	@HomePhone varchar(20),
	@Address1 varchar(55),
	@Address2 varchar(55),
	@City varchar(30),
	@State char(2),
	@Zip varchar(15),
	@Email varchar(100),
	@DOB varchar(35),
	@Gender char(1),
	@SSN varchar(9),
	@Height int,
	@Weight int,
	@InCaseManagement char(1),
	@NarcoticLockdown char(1),
	@IsPrimary bit,
	@Ethnicity [varchar](100) =NULL,
	@MaritalStatus [varchar](100) =NULL,
	@Language [varchar](100) =NULL,
	@LOB	VARCHAR(10) = null,
	@Occupation Varchar(50) = null,
	@NewMVDID varchar(50) output
)
AS
BEGIN
--Declare @CustID int,
--	@Createdby varchar(100),
--	@InsMemberID varchar(30),
--	@EffectiveDate varchar(35),
--	@TerminationDate varchar(35),
--	@LastName varchar(50),
--	@FirstName varchar(50),
--	@MiddleName	nvarchar(50) = NULL,
--	@HomePhone varchar(20),
--	@Address1 varchar(55),
--	@Address2 varchar(55),
--	@City varchar(30),
--	@State char(2),
--	@Zip varchar(15),
--	@DOB varchar(35),
--	@Gender char(1),
--	@SSN varchar(9),
--	@Height varchar(10),
--	@Weight decimal (4,2),
--	@InCaseManagement char(1),
--	@NarcoticLockdown char(1),
--  @IsPrimary = 1,
--	--CCC Additional Info
--	@Ethnicity [varchar](100) =NULL,
--	@MaritalStatus [varchar](100) =NULL,
--	@Language [varchar](100) =NULL,
--	@Homeless [varchar](100)= NULL,
--	@PCP [varchar](100) =NULL,
--	@Household_size [int] =NULL,
--	@Housing_Status [varchar](50) =NULL,
--	@CitizenshipStatus [varchar](50) =NULL,
--	@FPL_Level [varchar](50) =NULL,
--	@ProgramHandle [varchar](50) =NULL,
--  @Occupation [varchar](50) = NULL,
--	@HPCustomerID int,
--	@Customer varchar(50),
--	@System_Memid varchar(30),
	
--	@MemberID_MVDID	VARCHAR(30) = null,
--	@LOB	VARCHAR(10) = null,
	
	SET FMTONLY OFF

Declare	
	@IsNewMember bit,
	@IsDeactivated bit,
	@UpdateResult int,
	@tmp varchar(50)

Declare @Len int, @MVDUpdatedRecordId INT, @MaritalStatusID int, @MVDId varchar(30), @MVDGroupId varchar(30), @Organization varchar(100), @MVDGenderID int , @Action varchar(100), @SOurceName varchar(100)
	set @InsMemberID = dbo.RemoveLeadChars(@InsMemberID,'0')

	SELECT @InCaseManagement =
		CASE @InCaseManagement
			WHEN 'Y' THEN '1'
			WHEN 'N' THEN '0'
			ELSE NULL
		END,
		@NarcoticLockdown =
		case @NarcoticLockdown
			WHEN 'Y' THEN '1'
			WHEN 'N' THEN '0'
			ELSE NULL
		END
	BEGIN TRY
		--BEGIN TRAN

		IF @MVDId IS NULL
		BEGIN
			set @IsNewMember = 1

			-- Generate new MVD GroupID
			EXEC GenerateRandomString 0,0,0,'23456789ABCDEFGHJKLMNPQRSTWXYZ',10, @MVDGroupId output

			-- Repeat generating MVD GroupID until it's unique
			WHILE EXISTS (SELECT ICEGROUP FROM MainICENUMBERGroups WHERE ICEGROUP = @MVDGroupId)
			BEGIN
				EXEC GenerateRandomString 0,0,0,'23456789ABCDEFGHJKLMNPQRSTWXYZ',10, @MVDGroupId output
			END

			select @Len = MAX(LEN(MVDID)) FROM Link_MemberId_MVD_Ins Where Cust_ID = @CustID
			Select @MVDID = ISNULL(max(CAST(Substring(MVDID,5,@Len) as INT)),1000001)+1 FROM Link_MemberId_MVD_Ins Where Cust_ID = @CustID
			select @MVDID =  CAST(@CustID as varchar(3))+Substring(UPPER(@FirstName),1,1)+SUBSTRING(UPPER(@LastName), 1,1)+ @MVDID 
		END
		 --select @MVDID
		------------------------------- Map data
		-- Gender
		SELECT @MVDGenderID = MVDGenderId FROM Link_Gender_MVD_Ins WHERE InsGenderId = @Gender

		-- Matiralstatus 
		Select @MaritalStatusID = MaritalStatusID from [dbo].[LookupMaritalStatusID]  where MaritalStatusName = @MaritalStatus


		-- Empty string for state violates FK
		IF LEN(ISNULL(@State,'')) = 0
			SET @State = NULL

			Select @Organization = Name from HPCustomer where Cust_ID = @CustID
		---------------------------------------

			--IF (@CustID <> 15)
			--BEGIN
			--	SET @MaritalStatusID = ''
			--END
			-- Create new user profile
			EXEC Set_NewImportedProfile
				@MVDGroup = @MVDGroupId,
				@834_GroupId = '',
				@MVDId = @MVDId,
				@LastName = @LastName,
				@FirstName = @FirstName,
				@MiddleName = @MiddleName,
				@IsPrimary = @IsPrimary,
				@Phone = @HomePhone,
				@Email = @Email,
				@Address1 = @Address1,
				@Address2 = @Address2,
				@City = @City,
				@State = @State,
				@Zip = @Zip,
				@DOB = @DOB,
				@Gender = @MVDGenderID,
				@SSN = @SSN,
				@Ethnicity = @Ethnicity,
				@Language = @Language,
				@MaritalStatus = @MaritalStatusID,
				@EconomicStatus = '',
				@Height = @Height,
				@Weight = @Weight,
				@InsGroupID = '',
				@InsMemberID = @InsMemberId,
				@CreatedBy = @CreatedBy,						-- Only set when Individual creates a record
				@CreatedByContact = '',	-- Common field for CreatedBy and Organization
				@Organization = @Organization,
				@HPCustomerId = @CustId,
				@InCaseManagement = @InCaseManagement,
				@NarcoticLockdown = @NarcoticLockdown,
				@System_Memid = NULL,
				@LOB = @LOB,
				@Occupation = @Occupation,
				@RecordNumber = @MVDUpdatedRecordId OUTPUT,
				@Result = @UpdateResult OUTPUT

			IF @UpdateResult = 0
			BEGIN
				Set @SOurceName = @Organization + ' - DEMOGRAPHICS on the fly'
				Select @tmp = @MVDID;
				-- Keep the history of changes
				EXEC Import_SetHistoryLog
					@MVDID = @MVDId,
					@ImportRecordID = NULL,
					@HPAssignedID = '',
					@MVDRecordID = @MVDUpdatedRecordId,
					@Action = 'A',
					@RecordType = 'PERSONAL',
					@Customer = @CUstID,
					@SourceName = @SOurceName
			END
			ELSE 
			BEGIN
				Select @tmp = Case WHen @UpdateResult = -1 then 'MemberID exists' END --select @tmp as '@tmp'
				RAISERROR(@Tmp,16,  1)
			END
		--COMMIT TRAN
	END TRY
	BEGIN CATCH
		--ROLLBACK TRAN
		print 'backback'
		--Set @tmp = 'MemberID Exists'
		Select @tmp = case when @tmp is null then 'MemberID exists' else @tmp end
		DECLARE @addInfo nvarchar(MAX)
		SELECT	@UpdateResult = -1,
				@addInfo = 
					' InsMemberID=' + ISNULL(@InsMemberID, 'NULL') +  ', LastName=' + ISNULL(@LastName, 'NULL') + ', FirstName=' + ISNULL(@FirstName, 'NULL') + ', MiddleName=' + ISNULL(@MiddleName, 'NULL') + 
					', HomePhone=' + ISNULL(@HomePhone, 'NULL') + ', Address1=' + ISNULL(@Address1, 'NULL') + ', Address2=' + ISNULL(@Address2, 'NULL') + 
					', City=' + ISNULL(@City, 'NULL') + ', State=' + ISNULL(@State, 'NULL') + ', Zip=' + ISNULL(@Zip, 'NULL') + ', DOB=' + ISNULL(@DOB, 'NULL') + 
					', Gender=' + ISNULL(@Gender, 'NULL') + ', SSN=' + ISNULL(@SSN, 'NULL')
		EXEC ImportCatchError @addInfo
	END CATCH

	SET @NewMVDID = @tmp
END