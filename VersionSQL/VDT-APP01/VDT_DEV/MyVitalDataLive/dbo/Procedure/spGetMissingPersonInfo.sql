/****** Object:  Procedure [dbo].[spGetMissingPersonInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[spGetMissingPersonInfo]
@PrimaryKey int
AS
BEGIN
SELECT [PrimaryKey],[IceNumber],[FirstName],[LastName],[Alias],[Gender],[Race],[DOB],[Height],[Weight],[HairColor],[EyeColor]
      ,[BloodType],[Characteristics],[Clothing],[MedicationTaken],[DiseasesConditions],[Miscellaneous],[MissingAddress1]
      ,[MissingAddress2],[MissingCity],[MissingState],[MissingZip],[MissingDate],[Circumstances],[ContactName],[ContactPhone]
  FROM [dbo].[MainMissingPersonInfo] WHERE [PrimaryKey] = @PrimaryKey
END