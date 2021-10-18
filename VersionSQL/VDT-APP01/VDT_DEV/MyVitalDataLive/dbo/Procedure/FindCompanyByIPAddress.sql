/****** Object:  Procedure [dbo].[FindCompanyByIPAddress]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.FindCompanyByIPAddress
	@IPAddress char(15),
	@CompanyName nvarchar(64) OUTPUT
AS
BEGIN
	SELECT @CompanyName = CompanyName
	FROM Companies
	WHERE IPAddressRangeMin <= @IPAddress AND @IPAddress <= IPAddressRangeMax
END