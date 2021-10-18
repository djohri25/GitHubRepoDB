/****** Object:  Procedure [dbo].[spAddMissingPersonInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[spAddMissingPersonInfo]
@PrimaryKey [int] OUTPUT,
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

INSERT INTO [dbo].[MainMissingPersonInfo]
	(
	[IceNumber],[FirstName],[LastName],[Alias],[Gender],[Race],[DOB],[Height],[Weight],[HairColor],[EyeColor]
    ,[BloodType],[Characteristics],[Clothing],[MedicationTaken],[DiseasesConditions]
    ,[Miscellaneous],[MissingAddress1],[MissingAddress2],[MissingCity],[MissingState],[MissingZip],[MissingDate]
	,[Circumstances],[ContactName],[ContactPhone],[LastModified],[ImageData]
	)
     VALUES
     (
		@IceNumber,@FirstName ,@LastName ,@Alias ,@Gender ,@Race ,@DOB ,@Height,@Weight ,@HairColor,@EyeColor ,@BloodType,
		@Characteristics ,@Clothing ,@MedicationTaken ,	@DiseasesConditions ,@Miscellaneous ,@MissingAddress1 ,@MissingAddress2 ,
		@MissingCity ,@MissingState,@MissingZip,@MissingDate ,@Circumstances ,@ContactName ,@ContactPhone,@LastModified,@ImageData
	 )
SET @PRIMARYKEY = @@IDENTITY;