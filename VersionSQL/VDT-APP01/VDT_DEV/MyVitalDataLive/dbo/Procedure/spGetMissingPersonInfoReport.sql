/****** Object:  Procedure [dbo].[spGetMissingPersonInfoReport]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[spGetMissingPersonInfoReport]
@PrimaryKey int
AS
BEGIN
SELECT [PrimaryKey],[IceNumber],[FirstName],[LastName],[Alias]
	   ,[Gender] = CASE [Gender]
						WHEN NULL THEN ''
						WHEN 0 THEN ''
						ELSE (SELECT [GenderName] FROM [LookupGenderID] WHERE [GenderId] = [Gender])
				   END
	  ,[Race]    = CASE [Race]
						WHEN NULL THEN ''
						WHEN 0 THEN ''
						ELSE (SELECT [RaceName] FROM [LookupRace] WHERE [RaceId] = [Race])
				   END
      ,[DOB],[Height],[Weight],[HairColor],[EyeColor]
      ,[BloodType] = CASE [BloodType]
						WHEN NULL THEN ''
						WHEN 0 THEN ''
						ELSE (SELECT [BloodTypeName] FROM [LookupBloodTypeID] WHERE [BloodTypeId] = [BloodType])
				     END	  
	  ,[Characteristics],[Clothing],[MedicationTaken],[DiseasesConditions],[Miscellaneous],[MissingAddress1]
      ,[MissingAddress2],[MissingCity]
	  ,[MissingState] = CASE [MissingState]
							WHEN NULL THEN ''
							WHEN '0' THEN ''
							ELSE [MissingState]
				        END	
	  ,[MissingZip],[MissingDate],[Circumstances],[ContactName],[ContactPhone],[ImageData]
  FROM [dbo].[MainMissingPersonInfo] WHERE [PrimaryKey] = @PrimaryKey
END