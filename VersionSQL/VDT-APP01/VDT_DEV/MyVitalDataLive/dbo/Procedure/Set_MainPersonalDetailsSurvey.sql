/****** Object:  Procedure [dbo].[Set_MainPersonalDetailsSurvey]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_MainPersonalDetailsSurvey]  

	@ICENUMBER varchar(15),
	@SSN varchar(9),
	@GenderId int,
	@Address1 varchar(50),
	@City varchar(50),
	@State varchar(2),
	@PostalCode varchar(5),
	@CellPhone varchar(10),
	@WorkPhone varchar(10),
	@FaxPhone varchar(10),
	@BloodTypeId int,
	@OrganDonor varchar(3),
	@HeightInches int,
	@WeightLbs int,
	@MaritalStatusId int,
	@EconomicStatusId int,
	@Occupation varchar(50),
	@Hours varchar(50),
	@ModifyDate datetime = null,
	@UpdatedBy nvarchar(250) = NULL,
	@UpdatedByContact nvarchar(256) = NULL,
	@Organization nvarchar(64) = NULL

AS

SET NOCOUNT ON

UPDATE MainPersonalDetails SET 
	SSN = @SSN,
	GenderId = @GenderId,
	Address1 = @Address1,
	City = @City,
	State = @State,
	PostalCode = @PostalCode,
	CellPhone = @CellPhone,
	WorkPhone = @WorkPhone,
	FaxPhone = @FaxPhone,
	BloodTypeId = @BloodTypeId,
	OrganDonor = @OrganDonor,
	HeightInches = @HeightInches,
	WeightLbs = @WeightLbs,
	MaritalStatusId = @MaritalStatusId,
	EconomicStatusId = @EconomicStatusId,
	Occupation = @Occupation,
	Hours = @Hours,
	ModifyDate = ISNULL(@ModifyDate, GETUTCDATE()),
	UpdatedBy =@UpdatedBy,
	UpdatedByContact = @UpdatedByContact,
	UpdatedByOrganization=@Organization
WHERE ICENUMBER = @ICENUMBER