/****** Object:  Procedure [dbo].[Lkp_BloodType]    Committed by VersionSQL https://www.versionsql.com ******/

create  PROCEDURE [dbo].[Lkp_BloodType]
	@BloodTypeName varchar(50),
	@BloodTypeId int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT @BloodTypeId = BloodTypeID FROM LookupBloodTypeID WHERE 
	BloodTypeName = @BloodTypeName
	IF @BloodTypeId IS NULL SET @BloodTypeId = 0
END