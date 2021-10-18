/****** Object:  Procedure [dbo].[spGetCityStateByZipCode]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE
PROCEDURE [dbo].[spGetCityStateByZipCode] --''
	-- Add the parameters for the stored procedure here
	@ZipCode varchar(5)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT PlaceName as City, StateAlphaCode [State] FROM FIPS WHERE ZipCode=@ZipCode
END