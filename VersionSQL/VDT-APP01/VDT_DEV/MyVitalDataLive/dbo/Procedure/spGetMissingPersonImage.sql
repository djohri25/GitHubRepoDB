/****** Object:  Procedure [dbo].[spGetMissingPersonImage]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[spGetMissingPersonImage]
@PrimaryKey int
AS
BEGIN
SET NOCOUNT ON;

SELECT [ImageData] FROM [dbo].[MainMissingPersonInfo]
WHERE [PrimaryKey] = @PrimaryKey
END