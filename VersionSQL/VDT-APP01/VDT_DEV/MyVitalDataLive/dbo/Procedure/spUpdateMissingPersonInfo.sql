/****** Object:  Procedure [dbo].[spUpdateMissingPersonInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[spUpdateMissingPersonInfo]
@PRIMARYKEY [INT],
@IceNumber [nvarchar](15),
@FirstName [nvarchar](25) = NULL,
@LastName [nvarchar](25) = NULL,
@Alias [nvarchar](50) = NULL,
@Gender [nvarchar](10) = NULL,
@Race [nvarchar](10) = NULL,
@DOB [datetime] = NULL,
@Height [int] = NULL,
@Weight [nvarchar](25) = NULL,
@HairColor [nvarchar](25) = NULL,
@EyeColor [nvarchar](25) = NULL,
@BloodType [nvarchar](10) = NULL,
@Characteristics [nvarchar](500) = NULL,
@Clothing [nvarchar](500) = NULL,
@MedicationTaken [nvarchar](500) = NULL,
@DiseasesConditions [nvarchar](500) = NULL,
@Miscellaneous [nvarchar](1500) = NULL,
@MissingAddress1 [nvarchar](50) = NULL,
@MissingAddress2 [nvarchar](50) = NULL,
@MissingCity [nvarchar](25) = NULL,
@MissingState [nvarchar](10) = NULL,
@MissingZip [nvarchar](10) = NULL,
@MissingDate [datetime] = NULL,
@Circumstances [nvarchar](500) = NULL,
@ContactName [nvarchar](150) = NULL,
@ContactPhone [nvarchar](20) = NULL,
@LastModified [datetime] = NULL,
@ImageData [varbinary](MAX) = NULL

As
IF EXISTS (SELECT * FROM [dbo].[MainMissingPersonInfo]
WHERE [PRIMARYKEY]=@PRIMARYKEY)
	BEGIN
		IF(@ImageData IS NOT NULL)
			BEGIN
				UPDATE [dbo].[MainMissingPersonInfo] SET
					[FirstName]=@FirstName,[LastName]=@LastName,[Alias]=@Alias,[Gender]=@Gender,[Race]=@Race,[DOB]=@DOB,
					[Height]=@Height,[Weight]=@Weight,[HairColor]=@HairColor,[EyeColor]=@EyeColor
					,[BloodType]=@BloodType,[Characteristics]=@Characteristics,[Clothing]=@Clothing
					,[MedicationTaken]=@MedicationTaken,[DiseasesConditions]=@DiseasesConditions
					,[Miscellaneous]=@Miscellaneous,[MissingAddress1]=@MissingAddress1,[MissingAddress2]=@MissingAddress2
					,[MissingCity]=@MissingCity,[MissingState]=@MissingState,[MissingZip]=@MissingZip,[MissingDate]=@MissingDate
					,[Circumstances]=@Circumstances,[ContactName]=@ContactName,[ContactPhone]=@ContactPhone
					,[LastModified]=@LastModified,[ImageData]=@ImageData
					WHERE [IceNumber] = @IceNumber AND [PRIMARYKEY]=@PRIMARYKEY
			END
		ELSE
			BEGIN
				UPDATE [dbo].[MainMissingPersonInfo] SET
					[FirstName]=@FirstName,[LastName]=@LastName,[Alias]=@Alias,[Gender]=@Gender,[Race]=@Race,[DOB]=@DOB,
					[Height]=@Height,[Weight]=@Weight,[HairColor]=@HairColor,[EyeColor]=@EyeColor
					,[BloodType]=@BloodType,[Characteristics]=@Characteristics,[Clothing]=@Clothing
					,[MedicationTaken]=@MedicationTaken,[DiseasesConditions]=@DiseasesConditions
					,[Miscellaneous]=@Miscellaneous,[MissingAddress1]=@MissingAddress1,[MissingAddress2]=@MissingAddress2
					,[MissingCity]=@MissingCity,[MissingState]=@MissingState,[MissingZip]=@MissingZip,[MissingDate]=@MissingDate
					,[Circumstances]=@Circumstances,[ContactName]=@ContactName,[ContactPhone]=@ContactPhone
					,[LastModified]=@LastModified
					WHERE [IceNumber] = @IceNumber AND [PRIMARYKEY]=@PRIMARYKEY
			END
	END