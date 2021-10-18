/****** Object:  Procedure [dbo].[spGetExistingPersonInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[spGetExistingPersonInfo]
@IceNumber [nvarchar](15)
AS
BEGIN
SET NOCOUNT ON;

SELECT [LastName],[FirstName],[GenderID] [Gender],[DOB],[Address1] [MissingAddress1],[Address2] [MissingAddress2]
	  ,[City] [MissingCity],[State] [MissingState],[PostalCode] [MissingZip],[BloodTypeID] [BloodType]
      ,[HeightInches],[WeightLbs]
  FROM [dbo].[MainPersonalDetails]  WHERE [IceNumber] = @IceNumber
END