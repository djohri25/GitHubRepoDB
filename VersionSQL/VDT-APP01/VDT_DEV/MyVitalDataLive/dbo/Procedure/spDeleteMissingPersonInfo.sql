/****** Object:  Procedure [dbo].[spDeleteMissingPersonInfo]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[spDeleteMissingPersonInfo]
@PrimaryKey int
AS
BEGIN
DELETE 
  FROM [dbo].[MainMissingPersonInfo] WHERE [PrimaryKey] = @PrimaryKey
END