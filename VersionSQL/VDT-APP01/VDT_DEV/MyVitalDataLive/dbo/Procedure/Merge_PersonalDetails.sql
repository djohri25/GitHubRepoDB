/****** Object:  Procedure [dbo].[Merge_PersonalDetails]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/28/2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Merge_PersonalDetails]
	@MVDID_1 varchar(20),
	@MVDID_2 varchar(20)
	--,
	--@Action varchar(50),	-- 'Merge' - new record is created (@NewMVDID) from more recently updated (1 or 2)
	--						-- 'Update' - record 1  is primary record and is updated  from record 2 only
	--						--		if record 2 was more recently updated 
	--@NewMVDID varchar(20)	-- it's values if Action = 'Merge'
AS
BEGIN
	SET NOCOUNT ON;

	declare @modifyDateRec1 datetime,
		@modifyDateRec2 datetime,
		@mostRecentMVDID varchar(20)

	declare 
		@recordID1 int,
		@LastName varchar(50),
		@FirstName varchar(50),
		@GenderID int,
		@SSN varchar(9),
		@DOB smalldatetime,
		@Address1 varchar(50),
		@Address2 varchar(50),
		@City varchar(50),
		@State varchar(2),
		@PostalCode varchar(5),
		@HomePhone varchar(10),
		@CellPhone varchar(10),
		@WorkPhone varchar(10),
		@FaxPhone varchar(10),
		@Email varchar(100),
		@BloodTypeID int,
		@OrganDonor varchar(3),
		@HeightInches int,
		@WeightLbs int,
		@MaritalStatusID int,
		@EconomicStatusID int,
		@Occupation varchar(50),
		@Hours varchar(50),
		@CreationDate datetime,
		@ModifyDate datetime,
		@MaxAttachmentLimit int,
		@CreatedBy varchar(250),
		@CreatedByOrganization varchar(250),
		@UpdatedBy varchar(250),
		@UpdatedByOrganization varchar(250),
		@UpdatedByContact varchar(64),
		@Organization varchar(256),
		@Language varchar(50),
		@Ethnicity varchar(50),
		@CreatedByNPI varchar(20),
		@UpdatedByNPI varchar(20),
		@InCaseManagement bit,
		@NarcoticLockdown bit,
		@MiddleName varchar(50)
		
	select 
		@recordID1 = recordNumber,
		@modifyDateRec1 = modifyDate
	from MainPersonalDetails
	where ICENUMBER = @MVDID_1
			
	select @modifyDateRec2 = modifyDate
	from MainPersonalDetails
	where ICENUMBER = @MVDID_2
	
	if(ISNULL(@recordID1,'') = '')
	begin
		insert into MainPersonalDetails
			(ICENUMBER,LastName,FirstName,GenderID,SSN,DOB,Address1,Address2,City
		   ,State,PostalCode,HomePhone,CellPhone,WorkPhone,FaxPhone,Email
		   ,BloodTypeID,OrganDonor,HeightInches,WeightLbs,MaritalStatusID
		   ,EconomicStatusID,Occupation,Hours,CreationDate,ModifyDate,MaxAttachmentLimit
		   ,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
		   ,UpdatedByContact,Organization,Language,Ethnicity,CreatedByNPI
		   ,UpdatedByNPI,InCaseManagement,NarcoticLockdown,MiddleName)
		select @MVDID_1,LastName,FirstName,GenderID,SSN,DOB,Address1,Address2,City
		   ,State,PostalCode,HomePhone,CellPhone,WorkPhone,FaxPhone,Email
		   ,BloodTypeID,OrganDonor,HeightInches,WeightLbs,MaritalStatusID
		   ,EconomicStatusID,Occupation,Hours,CreationDate,ModifyDate,MaxAttachmentLimit
		   ,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
		   ,UpdatedByContact,Organization,Language,Ethnicity,CreatedByNPI
		   ,UpdatedByNPI,InCaseManagement,NarcoticLockdown,MiddleName
		from MainPersonalDetails 
		where ICENUMBER = @MVDID_2	
	end
	else
	begin
		if (@modifyDateRec1 < @modifyDateRec2)
		begin
			--set @mostRecentMVDID = @MVDID_2
			select 
			   @LastName = LastName
			  ,@FirstName = FirstName
			  ,@GenderID = GenderID
			  ,@SSN = SSN
			  ,@DOB = DOB
			  ,@Address1 = Address1
			  ,@Address2 = Address2
			  ,@City = City
			  ,@State = State
			  ,@PostalCode = PostalCode
			  ,@HomePhone = HomePhone
			  ,@CellPhone = CellPhone
			  ,@WorkPhone = WorkPhone
			  ,@FaxPhone = FaxPhone
			  ,@Email = Email
			  ,@BloodTypeID = BloodTypeID
			  ,@OrganDonor = OrganDonor
			  ,@HeightInches = HeightInches
			  ,@WeightLbs = WeightLbs
			  ,@MaritalStatusID = MaritalStatusID
			  ,@EconomicStatusID = EconomicStatusID
			  ,@Occupation = Occupation
			  ,@Hours = Hours
			  ,@CreationDate = CreationDate
			  ,@ModifyDate = ModifyDate
			  ,@MaxAttachmentLimit = MaxAttachmentLimit
			  ,@CreatedBy = CreatedBy
			  ,@CreatedByOrganization = CreatedByOrganization
			  ,@UpdatedBy = UpdatedBy
			  ,@UpdatedByOrganization = UpdatedByOrganization
			  ,@UpdatedByContact = UpdatedByContact
			  ,@Organization = Organization
			  ,@Language = Language
			  ,@Ethnicity = Ethnicity
			  ,@CreatedByNPI = CreatedByNPI
			  ,@UpdatedByNPI = UpdatedByNPI
			  ,@InCaseManagement = InCaseManagement
			  ,@NarcoticLockdown = NarcoticLockdown
			  ,@MiddleName = MiddleName			
			from MainPersonalDetails
			where icenumber = @mvdid_2
		
		
			update MainPersonalDetails 
			   SET 
			   [LastName] = @LastName
			  ,[FirstName] = @FirstName
			  ,[GenderID] = @GenderID
			  ,[SSN] = @SSN
			  ,[DOB] = @DOB
			  ,[Address1] = @Address1
			  ,[Address2] = @Address2
			  ,[City] = @City
			  ,[State] = @State
			  ,[PostalCode] = @PostalCode
			  ,[HomePhone] = @HomePhone
			  ,[CellPhone] = @CellPhone
			  ,[WorkPhone] = @WorkPhone
			  ,[FaxPhone] = @FaxPhone
			  ,[Email] = @Email
			  ,[BloodTypeID] = @BloodTypeID
			  ,[OrganDonor] = @OrganDonor
			  ,[HeightInches] = @HeightInches
			  ,[WeightLbs] = @WeightLbs
			  ,[MaritalStatusID] = @MaritalStatusID
			  ,[EconomicStatusID] = @EconomicStatusID
			  ,[Occupation] = @Occupation
			  ,[Hours] = @Hours
			  ,[CreationDate] = @CreationDate
			  ,[ModifyDate] = @ModifyDate
			  ,[MaxAttachmentLimit] = @MaxAttachmentLimit
			  ,[CreatedBy] = @CreatedBy
			  ,[CreatedByOrganization] = @CreatedByOrganization
			  ,[UpdatedBy] = @UpdatedBy
			  ,[UpdatedByOrganization] = @UpdatedByOrganization
			  ,[UpdatedByContact] = @UpdatedByContact
			  ,[Organization] = @Organization
			  ,[Language] = @Language
			  ,[Ethnicity] = @Ethnicity
			  ,[CreatedByNPI] = @CreatedByNPI
			  ,[UpdatedByNPI] = @UpdatedByNPI
			  ,[InCaseManagement] = @InCaseManagement
			  ,[NarcoticLockdown] = @NarcoticLockdown
			  ,[MiddleName] = @MiddleName
			where icenumber = @MVDID_1
		end	
	end
END