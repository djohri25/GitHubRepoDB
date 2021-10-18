/****** Object:  Procedure [dbo].[IceMR_MainPersonalDetails]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_MainPersonalDetails]  

@ICENUMBER varchar(15),
@LastName varchar(50),
@FirstName varchar(50),
@SSN varchar(9),
@GenderId int,
@DOB smalldatetime,
@Address1 varchar(50),
@City varchar(50),
@State varchar(2),
@PostalCode varchar(5),
@HomePhone varchar(10),
@CellPhone varchar(10),
@WorkPhone varchar(10),
@FaxPhone varchar(10),
@Email varchar(50),
@BloodTypeId int,
@HeightInches int,
@WeightLbs int,
@MaritalStatusId int,
@EconomicStatusId int,
@Occupation varchar(50),
@Hours varchar(50)

AS

SET NOCOUNT ON

DECLARE @Count int

SELECT @Count = COUNT(*) FROM MainPersonalDetails WHERE ICENUMBER = @ICENUMBER

IF @Count = 1

UPDATE MainPersonalDetails SET 
FirstName = @FirstName,
LastName = @LastName,
SSN = @SSN,
GenderId = @GenderId,
DOB = @DOB,
Address1 = @Address1,
City = @City,
State = @State,
PostalCode = @PostalCode,
HomePhone = @HomePhone,
CellPhone = @CellPhone,
WorkPhone = @WorkPhone,
FaxPhone = @FaxPhone,
Email = @Email,
BloodTypeId = @BloodTypeId,
HeightInches = @HeightInches,
WeightLbs = @WeightLbs,
MaritalStatusId = @MaritalStatusId,
EconomicStatusId = @EconomicStatusId,
Occupation = @Occupation,
Hours = @Hours,
ModifyDate = GETUTCDATE()
WHERE ICENUMBER = @ICENUMBER


ELSE

INSERT INTO MainPersonalDetails (ICENUMBER, LastName, FirstName, GenderID,
SSN, DOB, Address1, City, State, PostalCode, HomePhone, CellPhone,
WorkPhone, FaxPhone, Email, BloodTypeID, HeightInches, WeightLbs,
MaritalStatusID, EconomicStatusID, Occupation, Hours, CreationDate, ModifyDate)
VALUES (@ICENUMBER, @LastName, @FirstName, @GenderID, @SSN, @DOB, @Address1,
@City, @State, @PostalCode, @HomePhone, @CellPhone, @WorkPhone,
@FaxPhone, @Email, @BloodTypeID, @HeightInches, @WeightLbs, @MaritalStatusID,
@EconomicStatusID, @Occupation, @Hours, GETUTCDATE(), GETUTCDATE())