/****** Object:  Procedure [dbo].[spGetMissingPersonUserProfiles]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[spGetMissingPersonUserProfiles]
@IceNumber [nvarchar](15)
AS
SELECT [PRIMARYKEY],[IceNumber],[FirstName],[LastName],[Gender],[DOB] FROM [dbo].[MainMissingPersonInfo]
WHERE [IceNumber] = @IceNumber